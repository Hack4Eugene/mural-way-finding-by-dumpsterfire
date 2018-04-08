//
//  MuralTableViewCell.swift
//  Eugene Murals
//
//  Created by Andrew on 3/26/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import UIKit

class MuralTableViewCell: UITableViewCell {
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var muralNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setBackgroundGradient()
    }
    
    func setBackgroundGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = labelBackgroundView.bounds
        gradient.colors = [UIColor(white: 0.2, alpha: 0.0).cgColor, UIColor.black.cgColor]
        gradient.locations = [0.2, 1.0]
        labelBackgroundView.layer.insertSublayer(gradient, at: 0)
        labelBackgroundView.alpha = 0.25
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
