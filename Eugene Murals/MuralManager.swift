//
//  MuralManager.swift
//  Eugene Murals
//
//  Created by Andrew on 3/14/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import Foundation
import UIKit

class MuralManager {
    static let sharedInstance = MuralManager()
    private init() {}
    
    private let muralJsonUrl = URL(string:"https://s3-us-west-2.amazonaws.com/eugene-murals/murals.json")
    private var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var murals: [Mural] = []
    var dataReadyForUse: Bool = false
    
    func muralFrom(uid: String) -> Mural? {
        for mural in murals {
            if mural.uid == uid {
                return mural
            }
        }
        return nil
    }
    
    //MARK: - Save user data to disk
    //called in AppDelegate on background & termination
    func saveUserData() {
        DispatchQueue.global(qos: .background).async {
            var visitedMurals: [String] = []
            var favoritedMurals: [String] = []
            for mural in self.murals {
                if mural.visited {visitedMurals.append(mural.uid)}
                if mural.favorited {favoritedMurals.append(mural.uid)}
            }
            UserDefaults.standard.set(visitedMurals, forKey: "visitedMurals")
            UserDefaults.standard.set(favoritedMurals, forKey: "favoritedMurals")
        }
    }
    
    
    //MARK: - Mural Data Request
    func getMuralData() {
        let url = muralJsonUrl
        var request = URLRequest(url: url!)
        request.httpMethod = "Get"
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let apiResponse = response as? HTTPURLResponse {
                if apiResponse.statusCode == 200 {
                    if let returnedData = data {
                        //print("json returned")
                        self.parseMuralsFrom(returnedData)
                    }
                } else {
                    //handle error
                }
            }
        }).resume()
    }
    
    //MARK: - Data Processing Functions
    private func parseMuralsFrom(_ data: Data) {
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
            if let muralData = jsonData as? [AnyObject] {
                for mural in muralData {
                    guard let uid = mural["uid"] as? String else {parseFalureOn(value: "uid");return}
                    guard let name = mural["name"] as? String else {parseFalureOn(value: "name");return}
                    guard let artist = mural["artist"] as? String else {parseFalureOn(value: "artist");return}
                    guard let sponsors = mural["sponsors"] as? String else {parseFalureOn(value: "sponsors");return}
                    guard let address = mural["address"] as? String else {parseFalureOn(value: "address");return}
                    guard let latitude = mural["latitude"] as? Double else {parseFalureOn(value: "latitude");return}
                    guard let longitude = mural["longitude"] as? Double else {parseFalureOn(value: "longitude");return}
                    guard let note = mural["note"] as? String else {parseFalureOn(value: "note");return}
                    guard let imageUrl = mural["imageUrl"] as? String else {parseFalureOn(value: "imageUrl");return}
                    let newMural = Mural.init(muralUniqueID: uid, muralName: name, artistName: artist, sponsorNames: sponsors, muralAddress: address, latitudeCoordinate: latitude, longitudeCoordinate: longitude, muralNote: note, imageAddress: imageUrl)
                    murals.append(newMural)
                }
                
            }
        }
        //print("json parsed")
        generateStatuses()
    }
    
    private func parseFalureOn(value: String) {
        print("Parse failure on value: \(value)")
        print("Object index: \(murals.count)")
    }
    
    private func generateStatuses() {
        let savedVisitedMurals = UserDefaults.standard.value(forKey: "visitedMurals") as? [String] ?? []
        let savedFavoritedMurals = UserDefaults.standard.value(forKey: "favoritedMurals") as? [String] ?? []

        for mural in murals {
            mural.visited = savedVisitedMurals.contains(mural.uid)
            mural.favorited = savedFavoritedMurals.contains(mural.uid)
        }
        downloadMuralImages()
        //print("statuses generated")
    }
    
    private func downloadMuralImages() {
        let dispatchGroup = DispatchGroup()
        
        for mural in murals {
            //get cached copy if exists
            if localImageExistsWith(uid: mural.uid) {
                mural.image = getSavedImageFor(uid: mural.uid)
                continue
            }
            
            //set placeholder image if url is empty
            if mural.imageUrl == " " {
                if let placeholderImage = UIImage(named: "comingSoon") {
                    mural.image = placeholderImage
                }
                continue
            }
            //Add to dispatch group if image url is available
            dispatchGroup.enter()
            let url = URL(string: mural.imageUrl)
            var request = URLRequest(url: url!)
            request.httpMethod = "Get"
            
            URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
                if let imageData = data {
                    guard let downloadedImage = UIImage(data: imageData) else {
                        if let placeholderImage = UIImage(named: "comingSoon") {
                            mural.image = placeholderImage
                        }
                        return
                    }
                    mural.image = downloadedImage
                    self.saveMural(image: mural.image, with: mural.uid)
                }
                dispatchGroup.leave()
            }).resume()
        }
        dispatchGroup.notify(queue: .main) {
            self.dataReadyForUse = true
            NotificationCenter.default.post(name: .muralDataReady, object: nil)
            //print("image download complete")
        }
        //cleanup any saved images for murals that no longer exist
        purgeUnusedSavedImages()
    }
    
    private func localImageExistsWith(uid: String) -> Bool {
        let imagePath = documentsUrl.appendingPathComponent(uid).path
        return FileManager.default.fileExists(atPath:imagePath)
    }
    
    private func saveMural(image: UIImage, with muralUid: String) {
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            let fileName = documentsUrl.appendingPathComponent(muralUid)
            try? imageData.write(to: fileName)
        }
    }
    
    private func getSavedImageFor(uid: String) -> UIImage {
        do {
            let imageData = try Data(contentsOf: documentsUrl.appendingPathComponent(uid))
            return UIImage(data: imageData) ?? UIImage()
        } catch {
        
        }
        return UIImage()
    }
    
    private func purgeUnusedSavedImages() {
        for mural in murals {
            if !localImageExistsWith(uid: mural.uid) {
                do {
                    try FileManager.default.removeItem(at: documentsUrl.appendingPathComponent(mural.uid))
                } catch {
                    print("Error deleting saved image")
                }
            }
        }
    }
}

//MARK: - Notification Name Extension
extension Notification.Name {
    static let muralDataReady = Notification.Name("muralDataReady")
}

