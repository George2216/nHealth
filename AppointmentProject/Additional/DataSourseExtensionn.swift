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


protocol ModelCell { }

struct TableViewSection {
    var items: [ModelCell]
    let header: String?
    let footer: String?
    init(items: [ModelCell], header: String?, footer:String?) {
        self.items = items
        self.header = header
        self.footer = footer
    }
}

extension TableViewSection: SectionModelType {
    typealias Item = ModelCell
    
    init(original: Self, items: [Self.Item]) {
        self = original
    }
}

struct GeneralDataSource  {
    
    typealias DataSource = RxTableViewSectionedReloadDataSource
    static func dataSource<T:CustomTVCell>(type:T) -> DataSource<TableViewSection> {
        
        return .init(configureCell: { dataSource, tableView, indexPath, item -> UITableViewCell in
            let cell = T()
            cell.data = item
            return cell
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].header
        }, titleForFooterInSection: { dataSource, index in
            return dataSource.sectionModels[index].footer
        })
    }
}
protocol TableCellProtocol {
    var data: ModelCell? { get set }
}
class CustomTVCell: UITableViewCell, TableCellProtocol  {
    var data: ModelCell?
}

