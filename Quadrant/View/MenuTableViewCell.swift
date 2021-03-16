//
//  MenuTableViewCell.swift
//  Uber
//
//  Created by Marwan Osama on 12/22/20.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    static let identifier = "MenuCell"
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var settingsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(model: SettingsMenu) {
        icon.image = model.icon
        settingsLabel.text = model.title
    }

}
