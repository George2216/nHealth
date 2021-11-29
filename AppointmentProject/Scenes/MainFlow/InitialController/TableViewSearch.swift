//
//  TableViewSearch.swift
//  AppointmentProject
//
//  Created by George on 21.07.2021.
//

import UIKit
import RxSwift
import RxCocoa


class TableDoctors: UITableView
{
    private let disposeBag = DisposeBag()
    private let cellIdentifier = "DoctorSearchForName"
    let contentTable = BehaviorSubject<[ParamDoctor]>(value: [])
    
    lazy var selectedCell:Observable<Int> = {
        self.rx.itemSelected.map{$0.row}
    }()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        createTable()
    }
    
    
  private func createTable() {
      
        self.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
      self.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        contentTable.bind(to: self.rx.items(cellIdentifier: cellIdentifier, cellType: UITableViewCell.self)) { row , model , cell in
            cell.textLabel?.text = model.name
            cell.selectionStyle = .none
        }.disposed(by: disposeBag)
    }
    
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
