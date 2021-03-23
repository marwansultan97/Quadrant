//
//  ProfileInfosTableViewCell.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/20/21.
//

import UIKit

class ProfileInfosTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(user: User) {
        let firstChar = user.firstname.first!.lowercased()
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.image = UIImage(named: "SF_\(firstChar)_circle")
        fullnameLabel.text = "\(user.firstname) \(user.surname)"
        phoneNumberLabel.text = user.phonenumber
    }
    
}
