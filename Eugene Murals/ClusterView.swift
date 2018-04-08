/*
 Copyright © 2017 Apple Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import MapKit

class ClusterView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let notVisitedColor = UIColor.orange//UIColor.init(displayP3Red: 242/255, green: 169/255, blue: 80/255, alpha: 1.0)
    let visitedColor = UIColor.cyan//UIColor.init(displayP3Red: 5/255, green: 242/255, blue: 242/255, alpha: 1.0)//UIColor.init(displayP3Red: 171/255, green: 217/255, blue: 102/255, alpha: 1.0)
    let favoritedColor = UIColor.init(displayP3Red: 242/255, green: 196/255, blue: 7/255, alpha: 1.0)
    
    override var annotation: MKAnnotation? {
        willSet {
            if let cluster = newValue as? MKClusterAnnotation {
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
                let count = cluster.memberAnnotations.count
                let notVisitedCount = cluster.memberAnnotations.filter { member -> Bool in
                    return (member as! MuralAnnotation).visitedStatus == .notVisited
                }.count
                //let favoriteCount = cluster.memberAnnotations.filter { member -> Bool in
                  //  return (member as! MuralAnnotation).visitedStatus == .favorite
                   // }.count
                image = renderer.image { _ in
                    // Fill full circle with tricycle color
                    visitedColor.setFill()
                    UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).fill()
                    
                    // Fill pie with unvisited color
                    notVisitedColor.setFill()
                    let piePath = UIBezierPath()
                    piePath.addArc(withCenter: CGPoint(x: 20, y: 20), radius: 20,
                                   startAngle: 0, endAngle: (CGFloat.pi * 2.0 * CGFloat(notVisitedCount)) / CGFloat(count),
                                   clockwise: true)
                    piePath.addLine(to: CGPoint(x: 20, y: 20))
                    piePath.close()
                    piePath.fill()
                    
                    // Fill inner circle with white color
                    let textColor = UIColor.black
                    UIColor.white.setFill()
                    
                    
                    UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 24, height: 24)).fill()
                    
                    // Finally draw count text vertically and horizontally centered
                    let attributes = [ NSAttributedStringKey.foregroundColor: textColor,
                                       NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20)] as [NSAttributedStringKey : Any]
                    let text = "\(count)"
                    let size = text.size(withAttributes: attributes)
                    let rect = CGRect(x: 20 - size.width / 2, y: 20 - size.height / 2, width: size.width, height: size.height)
                    text.draw(in: rect, withAttributes: attributes)
                }
            }
        }
    }

}
