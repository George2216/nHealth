//
//  SettingsCell.swift
//  AppointmentProject
//
//  Created by George on 07.08.2021.
//

import UIKit

class SettingsCell: UITableViewCell {
  
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var titleCell: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
