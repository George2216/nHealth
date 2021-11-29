//
//  MenuEventsTableVC.swift
//  AppointmentProject
//
//  Created by George on 02.08.2021.
//

import UIKit
import RxSwift
import RxCocoa
final class MenuEventsTableV: UITableViewController, Storyboarded {
    internal weak var selectedDelegate:SelectMenuCell?
    internal let navEvents = PublishSubject<Event>()
    private let cellIdentifier = "MenuCellIdentifier"
    private let disposeBag = DisposeBag()
    private let viewModel = MenuEventTableViewModel()
    
    private lazy var selectIndex:Observable<Int> = {
        return tableView.rx.itemSelected
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map{$0.row}
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.transform(MenuEventTableViewModel.Input(selectIndex: selectIndex))
        createTable(output)
        sharAction(output)
        bindDataToCell(output)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navEvents.onNext(.finish)
    }
    private func createTable(_ output:MenuEventTableViewModel.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
       
    }
    
    private func bindDataToCell(_ output:MenuEventTableViewModel.Output) {
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
    
  
    // get action to delegate
    private func sharAction(_ output:MenuEventTableViewModel.Output) {
        output.myAction.drive(onNext: { [weak self] action in
            guard let self = self else { return }
            self.navEvents.onNext(.selectItem(action))
        }).disposed(by: disposeBag)
    }
 
    enum Event {
    case finish
    case selectItem(_ action:SelectAction)
    }
}


