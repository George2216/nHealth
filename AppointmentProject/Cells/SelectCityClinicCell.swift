//
//  CityCell.swift
//  AppointmentProject
//
//  Created by George on 06.10.2021.
//

import UIKit

class SelectCityClinicCell: CustomTVCell {
    override var data: ModelCell? {
        didSet {
            guard let data = data as? ModelCityCell else { return }
            var content = self.defaultContentConfiguration()
            content.text = data.text
//            content.secondaryText = data.secondaryText
            content.secondaryTextProperties.color = .gray
            self.contentConfiguration = content
            self.generalCellContent()
    }
    
}
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value2 , reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func generalCellContent() {
        self.selectionStyle = .none
        self.accessoryType = .disclosureIndicator
        }
    
    
}
