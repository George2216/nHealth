//
//  MyAppointmentFooterView.swift
//  AppointmentProject
//
//  Created by George on 27.10.2021.
//

import Foundation
import UIKit
import SnapKit

class MyAppointmentFooterView: UITableViewHeaderFooterView {
    var timeLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir Book", size: 12)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var bubleImage:UIImageView =  {
        let bubble = UIImage(systemName: "bubble.right.fill")
        let imageView = UIImageView(image: bubble)
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
       return imageView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        createImage()
        timeLabelLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func createImage() {
    
        self.contentView.addSubview(bubleImage)
        
        bubleImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(50)
        }
    }
    
    private func timeLabelLayout() {
        self.bubleImage.addSubview(timeLabel)
        timeLabel.fillEqual(bubleImage)
        
        
    }
    
}
