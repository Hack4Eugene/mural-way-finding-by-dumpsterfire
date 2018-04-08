//
//  Murall.swift
//  Eugene Murals
//
//  Created by Andrew on 4/2/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import Foundation
import UIKit

class Mural {
    let uid: String
    let name: String
    let artist: String
    let sponsors: String
    let address: String
    let latitude: Double
    let longitude: Double
    let note: String
    let imageUrl: String
    
    var image: UIImage = UIImage()
    var visited: Bool = false
    var favorited: Bool = false
    
    init(muralUniqueID: String, muralName: String, artistName: String, sponsorNames: String, muralAddress: String,latitudeCoordinate: Double, longitudeCoordinate: Double, muralNote: String, imageAddress: String) {
        uid = muralUniqueID
        name = muralName
        artist = artistName
        sponsors = sponsorNames
        address = muralAddress
        latitude = latitudeCoordinate
        longitude = longitudeCoordinate
        note = muralNote
        imageUrl = imageAddress
    }
    
    init() {
        uid = ""
        name = ""
        artist = ""
        sponsors = ""
        address = ""
        latitude = 0.0
        longitude = 0.0
        note = ""
        imageUrl = ""
    }
}
