//
//  AppointmentFillCell.swift
//  AppointmentProject
//
//  Created by George on 28.10.2021.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

struct AppointmentFillCellModel {
    let imageName:String
    let imageColor:UIColor
    let plaseholderTextField:String
    let indexPath:IndexPath
}
protocol PatientDataProtocol {
    func changeText(text:String,on indexPath:IndexPath)
}

class AppointmentFillCell: UITableViewCell  {
    
    private let disposeBag = DisposeBag()
    internal var data:AppointmentFillCellModel? {
        didSet {
            guard let data = data else {
                return
            }
            cellImage.image = UIImage(systemName: data.imageName)
            backgroundImageView.backgroundColor = data.imageColor
            myTextField.placeholder = data.plaseholderTextField
            backgrountImageViewLayout()
            imageLayout()
            textFieldLayout()
            subscribeOnTextField()
        }
    }
    internal var textFieldDelegate:PatientDataProtocol?
    
    private let cellImage:UIImageView =  {
         let image = UIImageView()
         image.translatesAutoresizingMaskIntoConstraints = false
         image.tintColor = .white
         image.backgroundColor = .clear
         image.contentMode = .center
         return image
     }()
    
    private let myTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let backgroundImageView:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
  
    private func subscribeOnTextField() {
        myTextField.rx.text.subscribe(onNext: {[weak self] text in
            guard let self = self else { return }
            self.textFieldDelegate?.changeText(text: text ?? "" , on: self.data!.indexPath)
        }).disposed(by: disposeBag)
    }
    
    private func textFieldLayout() {
        contentView.addSubview(myTextField)
        myTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalTo(backgroundImageView.snp.trailing).inset(-15)
        }
    }
    
    private func imageLayout() {
        backgroundImageView.addSubview(cellImage)
        cellImage.fillEqual(backgroundImageView)
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
