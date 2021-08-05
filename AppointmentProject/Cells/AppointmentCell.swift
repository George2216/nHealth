//
//  AppointmentCell.swift
//  AppointmentProject
//
//  Created by George on 01.08.2021.
//

import UIKit
import RxSwift
import RxCocoa

class AppointmentCell: UITableViewCell {
    private let disposeBag =  DisposeBag()

    var data:ModelCell? {
        didSet {
        guard let data = data as? ModelAppointmentCell else {
            return
        }
            professionsLabel.text = data.doctorProfession
            doctorNameLabel.text = data.doctorName
            subdivisionLabel.text = data.subdivision
            createLabelsLayout()

        }
    }
    
    private var professionsLabel = UILabel()
    private var doctorNameLabel = UILabel()
    private var subdivisionLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func createLabelsLayout() {
        staticLabelCharacteristics(label: &subdivisionLabel, font: 18, textColor: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        staticLabelCharacteristics(label: &doctorNameLabel, font: 20, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))

        staticLabelCharacteristics(label: &professionsLabel, font: 16, textColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
        

        subdivisionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
       
        doctorNameLabel.topAnchor.constraint(equalTo: subdivisionLabel.bottomAnchor).isActive = true
        professionsLabel.topAnchor.constraint(equalTo: doctorNameLabel.bottomAnchor).isActive = true
        professionsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
    }
    
    func staticLabelCharacteristics(label: inout UILabel,font:CGFloat,textColor:UIColor) {
        label.numberOfLines = 0
        
        label.font = UIFont.systemFont(ofSize: font, weight: .medium)
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
    }
    


}
