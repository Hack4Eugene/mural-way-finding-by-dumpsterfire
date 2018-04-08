//
//  MuralAnnotationView.swift
//  Eugene Murals
//
//  Created by Andrew on 3/22/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import UIKit
import MapKit

class MuralAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            self.canShowCallout = true
            
            let button = UIButton.init(type: .detailDisclosure)
            button.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
            self.rightCalloutAccessoryView = button
            
            if let muralAnnotation = newValue as? MuralAnnotation {
                clusteringIdentifier = "mural"
                
                switch muralAnnotation.visitedStatus {
                    case .notVisited:
                        markerTintColor = UIColor.orange
                        glyphText = " ⃝"
                        glyphTintColor = UIColor.white
                        //glyphImage = UIImage(named:"first")
                    case .visited:
                        markerTintColor = UIColor.cyan
                        glyphText = "✓"
                        glyphTintColor = UIColor.white
                        //glyphImage = UIImage(named:"first")
                    case .favorite:
                        markerTintColor = UIColor(displayP3Red: 242.0/255.0, green: 196.0/255.0, blue: 7.0/255.0, alpha: 1.0) //marigold
                        glyphText = "☆"
                        glyphTintColor = UIColor.white
                        //glyphImage = UIImage(named:"first")
                }
            }
        }
    }
}
