//
//  LocationTableViewCell.swift
//  Uber
//
//  Created by Marwan Osama on 11/29/20.
//

import UIKit
import Hero

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationFullLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell() {
//        self.hero.isEnabled = true
//        self.hero.modifiers = [.translate(x: 50, y: 50, z: 0)]
        locationLabel.text = "123 St, main"
        locationFullLabel.text = "123 St, main, washington DC"
        locationFullLabel.alpha = 0.6
    }


}
