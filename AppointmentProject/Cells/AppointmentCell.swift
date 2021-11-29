//
//  AppointmentCell.swift
//  AppointmentProject
//
//  Created by George on 01.08.2021.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class AppointmentCell: UITableViewCell {
    private let disposeBag =  DisposeBag()
    var data:ModelAppointmentCell? {
        didSet {
            guard let data = data else {
                return
            }
            subdivisionLabel.text = data.subdivision
            doctorNameLabel.text = data.doctorName
            professionsLabel.text = data.doctorProfession
            createLabelsLayout()
            createIsActiveImage(isActive: data.isActive)

        }
    }
    private var professionsLabel = UILabel()
    private var doctorNameLabel = UILabel()
    private var subdivisionLabel = UILabel()
    private var isActiveImage = UIImageView()
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    private func createIsActiveImage(isActive:Bool) {
        
        let image =  isActive ?  UIImage(systemName: "timer") :   UIImage(systemName: "checkmark.circle.fill")

        isActiveImage.image = image
        
        isActiveImage.translatesAutoresizingMaskIntoConstraints = false
        isActiveImage.tintColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        
        contentView.addSubview(isActiveImage)
        isActiveImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
       

    }
    private func createLabelsLayout() {
        
        staticLabelCharacteristics(label: &subdivisionLabel, font: 16, textColor: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
        staticLabelCharacteristics(label: &doctorNameLabel, font: 16, textColor: .black)

        staticLabelCharacteristics(label: &professionsLabel, font: 16, textColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))
        
        doctorNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
        }
        subdivisionLabel.snp.makeConstraints { make in
            make.top.equalTo(doctorNameLabel.snp.bottom)
        }
        professionsLabel.snp.makeConstraints { make in
            make.top.equalTo(subdivisionLabel.snp.bottom)
            make.bottom.equalToSuperview().inset(15)

        }
     
    }
    
   private func staticLabelCharacteristics(label: inout UILabel,font:CGFloat,textColor:UIColor) {
        label.numberOfLines = 0
       label.font =  UIFont.monospacedDigitSystemFont(ofSize: font, weight: .medium)
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
       
       label.snp.makeConstraints { make in
           make.leading.equalToSuperview().inset(20)
           make.trailing.equalToSuperview().inset(35)

       }

    }
    


}
