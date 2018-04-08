//
//  MuralAnnotation.swift
//  Eugene Murals
//
//  Created by Andrew on 3/24/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import MapKit

class MuralAnnotation: MKPointAnnotation {
    
    var uid: String = ""
    enum MuralStatus: Int {
        case notVisited
        case visited
        case favorite
    }
    
    
    
    var visitedStatus: MuralStatus = .notVisited
    
    class func mapAnnotations(fromMurals murals: [Mural]) -> [MuralAnnotation] {
        let annotations = murals.map { currentMural -> MuralAnnotation in
            let annotation = MuralAnnotation()
            annotation.uid = currentMural.uid
            annotation.title = currentMural.name
            annotation.subtitle = "by " + currentMural.artist
            annotation.coordinate = CLLocationCoordinate2DMake(currentMural.latitude, currentMural.longitude)
            if currentMural.visited {
                annotation.visitedStatus = .visited
            }
            if currentMural.favorited {
                annotation.visitedStatus = .favorite
            }
            //annotation.visitedStatus = VisitedMural.init(rawValue: Int(arc4random_uniform(2)))!
            return annotation
        }
        return annotations
    }

}
