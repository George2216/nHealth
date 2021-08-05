//
//  MenuEventsTableVC.swift
//  AppointmentProject
//
//  Created by George on 02.08.2021.
//

import UIKit
import RxSwift
import RxCocoa
class MenuEventsTableV: UITableViewController {
    let cellIdentifier = "MenuCellIdentifier"
    let disposeBag = DisposeBag()
    let viewModel = MenuEventTableViewModel()
    var selectedDelegate:SelectMenuCell?
    let selectIndex = PublishSubject<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = nil
        tableView.dataSource = nil
        let output =  viewModel.transform(MenuEventTableViewModel.Input(selectIndex: selectIndex))
        createTable(output: output)
        selectCell()
        sharAction(output)
    }
    
    private func createTable(output:MenuEventTableViewModel.Output) {
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        output.cellsData.drive(tableView.rx.items(cellIdentifier: cellIdentifier)) { row,model,cell in
            cell.imageView!.contentMode = .right
            cell.textLabel!.text = model.title
            cell.imageView!.image = UIImage(systemName: model.image)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            let color:UIColor = row % 2 == 0 ? .systemRed : .systemBlue
            cell.imageView?.tintColor = color
            cell.textLabel?.textColor = color
        }.disposed(by: disposeBag)
    }
    private func selectCell() {
        tableView.rx.itemSelected
            .throttle(.seconds(1), scheduler: MainScheduler.instance).map{$0.row}.subscribe(selectIndex).disposed(by: disposeBag)
    }
    
    // get action to delegate
    private func sharAction(_ output:MenuEventTableViewModel.Output) {
        output.myAction.drive(onNext: { [self] action in
            self.dismiss(animated: true, completion: nil)
            self.selectedDelegate?.selectAction(action: action)
        }).disposed(by: disposeBag)
    }
}


