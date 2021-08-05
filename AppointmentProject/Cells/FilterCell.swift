//
//  FilterCell.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import UIKit

class FilterCell: UICollectionViewCell {
    var data:ModelFilterCell? {
        didSet {
            labelAction.text =  data?.text
            imageAction.image = UIImage(systemName: data?.systemImageName ?? "")
            uiAdditional()
        }
    }
    @IBOutlet weak var labelAction: UILabel!
    @IBOutlet weak var imageAction: UIImageView!
    
    func uiAdditional(){
        contentView.backgroundColor = #colorLiteral(red: 0.9610242248, green: 0.9553111196, blue: 0.9654156566, alpha: 1)
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.24)
    }
}
