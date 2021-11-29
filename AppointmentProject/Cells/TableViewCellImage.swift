//
//  TableViewCellImage.swift
//  AppointmentProject
//
//  Created by George on 27.10.2021.
//

import UIKit
import SnapKit
struct TVCellImageModel {
    let imageName:String
    let imageColor:UIColor
    let titleText:String
    let textSize:TextSize
    
    enum TextSize {
    case big
    case little
    }
}

class TableViewCellImage: UITableViewCell {
    var data:TVCellImageModel? {
        didSet {
            guard let data = data else {
                return
            }
            cellImage.image = UIImage(systemName: data.imageName)
            backgroundImageView.backgroundColor = data.imageColor
            cellTitle.text = data.titleText
            additingSettings()
            
        }
    }
   private let cellImage:UIImageView =  {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .white
        image.backgroundColor = .clear
        image.contentMode = .center
        return image
    }()
    
    private let cellTitle:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backgroundImageView:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func additingSettings() {
        selectionStyle = .none
        switch data!.textSize {
        case .little:
            cellTitle.font = .systemFont(ofSize: 12)
        case .big:
            cellTitle.font = .systemFont(ofSize: 17)

        }
        backgrountImageViewLayout()
        imageLayout()
        labelLayout()
    }
    private func imageLayout() {
        backgroundImageView.addSubview(cellImage)
        cellImage.snp.makeConstraints { make in
            make.centerX.equalTo(backgroundImageView)
            make.centerY.equalTo(backgroundImageView)
            make.bottom.equalTo(backgroundImageView)
            make.top.equalTo(backgroundImageView)
        }

    }
    private func labelLayout() {
        contentView.addSubview(cellTitle)
        cellTitle.snp.makeConstraints { make in
            make.leading.equalTo(backgroundImageView.snp.trailing).inset(-15)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
        }

    }
    
    private func backgrountImageViewLayout() {
        contentView.addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.height.equalTo(30)
            make.width.equalTo(30)
            make.centerY.equalToSuperview()

        }
      
    }
}
