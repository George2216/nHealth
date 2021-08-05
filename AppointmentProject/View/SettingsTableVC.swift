//
//  SettingsTableVC.swift
//  AppointmentProject
//
//  Created by George on 31.07.2021.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsTableVC: UITableViewController {
    let cellIdentifier = "LanguageSettingCell"
    private let disposeBag = DisposeBag()
    private let viewModel = SettingsTableViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.transform(SettingsTableViewModel.Input(selectCell: tableView.rx.itemSelected.map{$0.row}))
        createTable(output)
        navigationSettings(output)
        
    }
    func navigationSettings( _ output:SettingsTableViewModel.Output){
        output.titleSettings.drive(navigationItem.rx.title).disposed(by: disposeBag)
    }
    func createTable(_ output:SettingsTableViewModel.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        output.tableData.drive(tableView.rx.items(cellIdentifier: cellIdentifier, cellType: UITableViewCell.self)) { row , data , cell in
            cell.textLabel?.text = data.nameLanguage
            cell.accessoryType = data.isSelect ? .checkmark : .none
        }.disposed(by: disposeBag)
    }
    
}
