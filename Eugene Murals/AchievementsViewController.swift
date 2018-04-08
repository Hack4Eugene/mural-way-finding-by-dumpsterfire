//
//  AchievementsViewController.swift
//  Eugene Murals
//
//  Created by Andrew on 4/7/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import UIKit

class AchievementsViewController: UIViewController {

    @IBOutlet var backgroundContainerViews: [UIView]!
    
    @IBOutlet weak var visitedMuralsLabel: EFCountingLabel!
    @IBOutlet weak var favoritedMuralsLabel: EFCountingLabel!
    @IBOutlet weak var notVisitedMuralsLabel: EFCountingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundCorners()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        generateCounts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func roundCorners() {
        for backgroundView in backgroundContainerViews {
            backgroundView.layer.cornerRadius = 5.0
            backgroundView.clipsToBounds = true
        }
    }

    func generateCounts() {
        var visitedCount: Int = 0
        var notVisitedCount: Int = 0
        var favoritedCount: Int = 0
        
        for mural in MuralManager.sharedInstance.murals {
            if mural.favorited {favoritedCount += 1}
            if mural.visited {
                visitedCount += 1
            } else {
                notVisitedCount += 1
            }
        }
        populateLabels(visited: visitedCount, favorited: favoritedCount, notVisited: notVisitedCount)
    }
    
    func populateLabels(visited: Int, favorited: Int, notVisited: Int) {
        
        visitedMuralsLabel.format = "%d"
        visitedMuralsLabel.method = .easeInOut
        visitedMuralsLabel.countFromZeroTo(CGFloat(visited))
        
        favoritedMuralsLabel.format = "%d"
        favoritedMuralsLabel.method = .easeInOut
        favoritedMuralsLabel.countFromZeroTo(CGFloat(favorited))
        
        notVisitedMuralsLabel.format = "%d"
        notVisitedMuralsLabel.method = .easeInOut
        notVisitedMuralsLabel.countFromZeroTo(CGFloat(notVisited))
    }

}
