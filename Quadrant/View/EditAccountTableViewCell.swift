//
//  EditAccountTableViewCell.swift
//  Uber
//
//  Created by Marwan Osama on 12/22/20.
//

import UIKit

class EditAccountTableViewCell: UITableViewCell {

    static let identifier = "EditAccountCell"
    
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(model: EditAccountOptions) {
        mainLabel.text = model.mainLabel
        secondaryLabel.text = model.secondaryLabel
    }

}
