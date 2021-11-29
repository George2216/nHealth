//
//  NotificationCell.swift
//  AppointmentProject
//
//  Created by George on 20.10.2021.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class NotificationCell: UITableViewCell {
    
    private let disposeBag = DisposeBag()
    
    var changeSwitchDelegate:ChangeVulueSwitchProtocol?
    var content:NotificationCellModel? {
        didSet {
            guard let content = content else { return }
            switchNotification.rx.isOn.onNext(content.isSelect)
            var contentConfig = self.defaultContentConfiguration()
            contentConfig.text = content.title
            self.contentConfiguration = contentConfig
            self.contentView.addSubview(switchNotification)
            self.selectionStyle = .none
            layouts()
            subscribeOnChangeSwitchValue()
        }
    }
    private var indexPath:IndexPath?
    
    
    func saveIndexPath(_ indexPath:IndexPath) {
        self.indexPath = indexPath
    }
    private let switchNotification:UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        return mySwitch
    }()
    
    private func layouts() {
        switchNotification.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
        }
    }
    
    private func subscribeOnChangeSwitchValue() {

      switchNotification.rx.controlEvent(.valueChanged).subscribe(onNext: {[weak self] _ in
        guard let self = self else { return }
          self.changeSwitchDelegate?.change(ChangeSwitchCaseModel(indexPath: self.indexPath ?? IndexPath(), isOn: self.switchNotification.isOn))
        }).disposed(by: disposeBag)

    }
}
