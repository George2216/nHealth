//
//  MyAppointmentsTVC.swift
//  AppointmentProject
//
//  Created by George on 31.07.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol SelectMenuCell:AnyObject {
    func selectAction(action:SelectAction)
}

final class MyAppointmentsTVC: UITableViewController, Storyboarded  {
    internal let nvContent = PublishSubject<Event>()

    private let disposeBag = DisposeBag()
    private let viewModel = MyAppointmentsTViewModel()
    private let cellIdentifier = "AppointmentIdentifierCell"
    private let footerIdentifier = "MyAppointmentFooterIdentifier"
    private let refreshContent = BehaviorSubject<Void>(value: ())
    private let itemSelectedOn = PublishSubject<ModelCellPosition>() // data for valid present menu
    private let selectCellAction = PublishSubject<SelectAction>() // delete or go to doc
    private lazy var tableHeaderViewLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        label.center = self.view.center
        label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.tableView.tableHeaderView = label
        return label
    }()
    
    private lazy var dataSourse: RxTableViewSectionedReloadDataSource<MyAppointmentSection> =  .init(configureCell: { [unowned self] (dataSource, tableView, indexPath, item) in
        switch item {
        case .myAppointmentModel(info: let info):
        let cell = myAppiontmentCell(indexPath: indexPath, content: info)
        return cell
        }
       
    }, titleForHeaderInSection: { dataSource, sectionIndex in
        
        return dataSource[sectionIndex].model.headerFooter.header
        
        })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.transform(MyAppointmentsTViewModel.Input(refreshContent: refreshContent, itemSelectedOn: itemSelectedOn, selectAction: selectCellAction))
        
        mainTitle(output)
        createTableView(output)
        presentMenu(output)
        detailTitle(output)
        showDoctor(output)
        showReloadIndicator(output)
        hideReloadIndicator(output)
        cellSelected()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshContent.onNext(())
        self.tableView.scrollToBottom()
    }
    
    private func showDoctor(_ output:MyAppointmentsTViewModel.Output) {
        output.selectDoc.drive(onNext: {[weak self] parametrs in
            guard let self = self else { return }
            self.nvContent.onNext(.tapDoctor(parametrs))
        }).disposed(by: disposeBag)
    }
    
    private func mainTitle(_ output:MyAppointmentsTViewModel.Output) {
        output.myAppointmentsTitle.drive(onNext: {[weak self] titleText in
            guard let self = self else { return }
            self.nvContent.onNext(.title(titleText))
        }).disposed(by: disposeBag)

    }
    
    private func detailTitle(_ output:MyAppointmentsTViewModel.Output) {
        output.historyTitle.drive(onNext: {[weak self] historyTitle in
            guard let self = self else { return }
            self.tableHeaderViewLabel.text = historyTitle
            self.tableView.tableHeaderView = self.tableHeaderViewLabel
        }).disposed(by: disposeBag)
    }
    
  
    
    private func createTableView(_ output:MyAppointmentsTViewModel.Output)  {
        tableView.delegate = nil
        tableView
          .rx.setDelegate(self)
          .disposed(by: disposeBag)
        tableView.dataSource = nil
        tableView.register(AppointmentCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.register(MyAppointmentFooterView.self, forHeaderFooterViewReuseIdentifier: footerIdentifier)
        output.contentTable.drive(tableView.rx.items(dataSource: dataSourse)).disposed(by: disposeBag)
    }
    
    private func cellSelected() {
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            let cellCenterY = self?.tableView.cellForRow(at: indexPath)!.frame.maxY ?? 0
            self?.itemSelectedOn.onNext(ModelCellPosition(topY: cellCenterY, indexPath: indexPath))
        }).disposed(by: disposeBag)
    }
    
    
    private func presentMenu(_ output:MyAppointmentsTViewModel.Output) {
        output.presentMenuOn.drive(onNext: { [weak self](rect , size) in
            guard let self = self else { return }

            self.nvContent.onNext(.showMenu(rect, size: size))
        }).disposed(by: disposeBag)}
    
   
    
    private func showReloadIndicator(_ output:MyAppointmentsTViewModel.Output) {
        output.showReloadIndicator.drive(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.nvContent.onNext(.showIndicator)
        }).disposed(by: disposeBag)
    }
    
    private func hideReloadIndicator(_ output:MyAppointmentsTViewModel.Output) {
        output.hideReloadIndicator.drive(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.nvContent.onNext(.hideReloadIndicator)
        }).disposed(by: disposeBag)
    }
    
    private func myAppiontmentCell(indexPath:IndexPath,content:ModelAppointmentCell) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AppointmentCell else {
            return UITableViewCell()
              }
        
        cell.selectionStyle = .none
        cell.data = content
        return cell
    }
}

extension MyAppointmentsTVC : UIPopoverPresentationControllerDelegate , SelectMenuCell {
    
    func selectAction(action: SelectAction) {
        selectCellAction.onNext(action)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = .center
        header.textLabel?.text = header.textLabel?.text?.lowercased()
    }
    

    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerIdentifier) as! MyAppointmentFooterView
        footer.timeLabel.text = dataSourse[section].model.headerFooter.footer
        return footer
    }
    
}

// events 
extension MyAppointmentsTVC {
    
    enum Event {
        case title(_ text :String)
        case showIndicator
        case showMenu(_ position:CGRect,size:CGSize)
        case hideReloadIndicator
        case tapDoctor(_ parametrs:DoctorContent)
    }
    
}

