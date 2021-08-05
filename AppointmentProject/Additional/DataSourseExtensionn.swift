//
//  DataSourseExtensionn.swift
//  AppointmentProject
//
//  Created by George on 01.08.2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import UIKit

struct TableViewSection {
    let items: [ModelCell]
    let header: String
    
    init(items: [ModelCell], header: String) {
        self.items = items
        self.header = header
    }
}

extension TableViewSection: SectionModelType {
    typealias Item = ModelCell
    
    init(original: Self, items: [Self.Item]) {
        self = original
    }
}

struct IntermediateDataSource  {
    
    typealias DataSource = RxTableViewSectionedReloadDataSource
    static func dataSource() -> DataSource<TableViewSection> {
        return .init(configureCell: { dataSource, tableView, indexPath, item -> UITableViewCell in
            let cell = AppointmentCell()
            cell.data = item
            cell.selectionStyle = .none
            
            
            return cell
        }, titleForHeaderInSection: { dataSource, index in
            
            return dataSource.sectionModels[index].header
        })
    }
}


// required type cell model
protocol ModelCell {

}
