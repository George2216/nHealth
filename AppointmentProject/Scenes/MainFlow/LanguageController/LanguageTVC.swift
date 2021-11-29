//
//  LanguageTVC.swift
//  AppointmentProject
//
//  Created by George on 05.08.2021.
//

import UIKit
import RxSwift
import RxCocoa
final class LanguageTVC: UITableViewController {
    internal let nvContent = PublishSubject<Event>()

    private let disposeBag = DisposeBag()
    private let cellIdentifier = "LanguageSettingCell"
    private let viewModel = LanguageTVM()
    override func viewDidLoad() {
        super.viewDidLoad()
        let output = viewModel.transform(LanguageTVM.Input(selectCell: tableView.rx.itemSelected.map{$0.row}))
        createTable(output)
        navigationSettings(output)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        nvContent.onNext(.finish)
    }
    
    private func createTable(_ output:LanguageTVM.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        output.tableData.drive(tableView.rx.items(cellIdentifier: cellIdentifier, cellType: UITableViewCell.self)) { row , data , cell in
            cell.textLabel?.text = data.nameLanguage
            cell.accessoryType = data.isSelect ? .checkmark : .none
        }.disposed(by: disposeBag)
    }
    
    private func navigationSettings( _ output:LanguageTVM.Output){
        output.titleSettings.drive(navigationItem.rx.title).disposed(by: disposeBag)
    }
}

extension LanguageTVC {
    enum Event {
        case finish
    }
}
