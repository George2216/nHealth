//
//  DiscountCell.swift
//  AppointmentProject
//
//  Created by George on 12.11.2021.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class DiscountCell: UITableViewCell {
    private let disposeBag = DisposeBag()
    internal var data:DiscountItemModel? {
            didSet {
                guard let data = data else { return }
                priceLabel.rx.text.onNext(String(data.price) + " " + "₴")
                titleLabel.rx.text.onNext(data.name)
                contenLabel.rx.text.onNext(data.description)

                self.titleLabelLayout()
                self.contenLabelLayout()
                self.priceLabelLayout()
            }
        }
    
    private let priceLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textColor = .red
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Verdana-Bold", size: 15)
        label.numberOfLines = 0
        label.textAlignment = .left

        return label
    }()
    
    private let contenLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir Book", size: 13)

        return label
    }()

    private func priceLabelLayout() {
        self.contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(contenLabel.snp.bottom).inset(-5)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)

        }
    }
    
    private func titleLabelLayout() {
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(10)

            
            
        }
    }
    
    private func contenLabelLayout() {
        self.contentView.addSubview(contenLabel)
        contenLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-10)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)

        }
    }
   
}
