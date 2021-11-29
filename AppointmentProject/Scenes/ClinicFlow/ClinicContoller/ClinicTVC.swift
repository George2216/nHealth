//
//  ClinicTVC.swift
//  AppointmentProject
//
//  Created by George on 07.10.2021.
//

import UIKit
import RxCocoa
import RxSwift

final class ClinicTVC: UITableViewController , Storyboarded {
    internal let nvEvents = PublishSubject<Event>()
    private let cellIdentifier = "ClinicCellIdentifier"
    private let disposeBag = DisposeBag()
    private let viewModel = ClinicViewModel()
    internal let cityIndex = BehaviorSubject<Int>(value: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        let output = viewModel.transform(ClinicViewModel.Input(cityIndex: cityIndex, clinicSelectIndex: tableView.rx.itemSelected.map{$0.row}))
               
        createTable(output)
        getTitle(output)
        goToMainFlow(output)
        
        showActivityIndicatior(output)
        hideActivityIndicatior(output)
        }
   
   
   
    override func viewDidDisappear(_ animated: Bool) {
       super.viewDidDisappear(animated)
        nvEvents.onNext(.finish)

    }
    private func createTable(_ output:ClinicViewModel.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        tableView.register(SelectCityClinicCell.self, forCellReuseIdentifier: cellIdentifier)
        
        
        let dataSourse = GeneralDataSource.dataSource(type: SelectCityClinicCell())
        output.items.drive(tableView.rx.items(dataSource: dataSourse)).disposed(by: disposeBag)
    }
    private func getTitle(_ output:ClinicViewModel.Output) {
        output.title.drive(onNext: { [weak self] titleText in
            guard let self = self else { return }
            self.nvEvents.onNext(.title(titleText))
        }).disposed(by: disposeBag)
    }
    private func goToMainFlow(_ output:ClinicViewModel.Output) {
        output.goToMainFlow.drive(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.nvEvents.onNext(.goToMainFlow)
        }).disposed(by: disposeBag)
    }
    private func showActivityIndicatior(_ output:ClinicViewModel.Output) {
        output.showActivityIndicatior.drive(onNext:{ [weak self] _ in
            guard let self = self else { return }
            self.nvEvents.onNext(.showActivityIndicatior)
        }).disposed(by: disposeBag)
    }
    private func hideActivityIndicatior(_ output:ClinicViewModel.Output) {
        output.hideActivityIndicatior.drive(onNext:{ [weak self] _ in
            guard let self = self else { return }
            self.nvEvents.onNext(.hideActivityIndicatior)
        }).disposed(by: disposeBag)
        
    }
}


extension ClinicTVC {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        60
    }
}
extension ClinicTVC {
    enum Event {
    case finish
    case searchController(_ searchController:UISearchController)
    case title(_ title:String)
    case goToMainFlow
    case showActivityIndicatior
    case hideActivityIndicatior
    }
}



