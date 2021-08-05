//
//  MyAppointmentsTVC.swift
//  AppointmentProject
//
//  Created by George on 31.07.2021.
//

import UIKit
import RxSwift
import RxCocoa

protocol SelectMenuCell {
    func selectAction(action:SelectAction)
}

class MyAppointmentsTVC: UITableViewController {

    private let disposeBag = DisposeBag()
    private let viewModel = MyAppointmentsTViewModel()
    private let callIdentifier = "AppointmentIdentifierCell"
    private let refreshContent = BehaviorSubject<Void>(value: ())
    private let itemSelectedOn = PublishSubject<ModelCellPosition>() // data for valid present menu
    var delegateSelectDoctor:SelectDoctorProtocol?
    private let selectCellAction = PublishSubject<SelectAction>() // delete or go to doc

    override func viewDidLoad() {
        super.viewDidLoad()
        cellSelected()

        let output = viewModel.transform(MyAppointmentsTViewModel.Input(refreshContent: refreshContent, itemSelectedOn: itemSelectedOn, selectAction: selectCellAction))
        navigationSettings(output)
        createTableView(output)
        presentMenu(output)
        createHistoryTitle(output)
        docIdForDelegate(output)
        reloadSettings(output)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshContent.onNext(())
      
    }
    private func docIdForDelegate(_ output:MyAppointmentsTViewModel.Output) {
        output.selectDoc.drive(onNext: {[self] docId in
            print(docId)
            delegateSelectDoctor?.selectDoctor(id: docId, pushFrom: self)
        }).disposed(by: disposeBag)
//        output.selectDoc.drive(onNext: delegateSelectDoctor?.selectDoctor).disposed(by: disposeBag)
    }
    private func createHistoryTitle(_ output:MyAppointmentsTViewModel.Output) {
        let label = UILabel()
        label.text = "История"
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        label.center = view.center
        label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        output.historyTitle.drive(label.rx.text).disposed(by: disposeBag)
        tableView.tableHeaderView = label
    }
    
    private func navigationSettings(_ output:MyAppointmentsTViewModel.Output) {
        output.myAppointmentsTitle.drive(navigationItem.rx.title).disposed(by: disposeBag)
    }
    
    private func createTableView(_ output:MyAppointmentsTViewModel.Output)  {
       
        tableView.delegate = nil
        tableView
          .rx.setDelegate(self)
          .disposed(by: disposeBag)
        tableView.dataSource = nil
        tableView.register(AppointmentCell.self, forCellReuseIdentifier: callIdentifier)
        let dataSourse = IntermediateDataSource.dataSource()
        output.contentTable.drive(tableView.rx.items(dataSource: dataSourse)).disposed(by: disposeBag)
        
            
    }
    
    private func cellSelected() {
        tableView.rx.itemSelected.subscribe(onNext: {[self] indexPath in
            let cellCenterY = tableView.cellForRow(at: indexPath)!.frame.maxY
            itemSelectedOn.onNext(ModelCellPosition(topY: cellCenterY, indexPath: indexPath))
        }).disposed(by: disposeBag)
    }
    
    private func presentMenu(_ output:MyAppointmentsTViewModel.Output) {
        output.presentMenuOn.drive(onNext: {[self](rect , size) in
        let menu = storyboard?.instantiateViewController(identifier: "menuEventsTVC") as! MenuEventsTableV
        menu.modalPresentationStyle = .popover
        menu.selectedDelegate = self
       let popoverVC =  menu.popoverPresentationController
        popoverVC?.delegate = self
        popoverVC?.sourceView = self.tableView
        popoverVC?.sourceRect = rect
        menu.preferredContentSize = size
        self.present(menu, animated: true, completion: nil)
        }).disposed(by: disposeBag)}
    
    private func reloadSettings(_ output:MyAppointmentsTViewModel.Output) {

        output.presentReloadIndicator.drive(onNext: { _ in
            print("Start")
            let refreshVC = ActivityVC()

            refreshVC.modalPresentationStyle = .overFullScreen
            self.present(refreshVC, animated: false, completion: nil)
        }).disposed(by: disposeBag)
        
        
        output.dismissReloadIndicator.drive(onNext: {[self] _ in
        self.dismiss(animated: false, completion: nil)
        }).disposed(by: disposeBag)
        
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
    }
}
