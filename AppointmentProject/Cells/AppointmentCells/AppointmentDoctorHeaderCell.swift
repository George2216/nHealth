//
//  AppointmentDoctorHeaderCell.swift
//  AppointmentProject
//
//  Created by George on 28.10.2021.
//

import UIKit

class AppointmentDoctorHeaderCell: UITableViewCell {

    var data:AppointmentDoctorCellModel? {
        didSet {
            guard let data = data else {
                return
            }
            var content =  self.defaultContentConfiguration()
            content.text = data.title
            content.secondaryText = data.subtitle
            content.textProperties.color = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            content.secondaryTextProperties.color = .black
            content.textProperties.font = .systemFont(ofSize: 15)
            content.secondaryTextProperties.font = .systemFont(ofSize: 25)
            contentConfiguration = content
        
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:.subtitle,reuseIdentifier:reuseIdentifier)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
