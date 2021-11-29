//
//  CityTVC.swift
//  AppointmentProject
//
//  Created by George on 06.10.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class CityTVC: UITableViewController , Storyboarded {
    internal let nvEvents = PublishSubject<Event>()
    private let cellIdentifier = "CityCellIdentifier"
    private let disposeBag = DisposeBag()
    private let viewModel = CityViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.transform(CityViewModel.Input(selectIndexCell: tableView.rx.itemSelected.map{$0.row}))
        createTable(output)
        showClinic(output)
        getTitle(output)
        createSearchController(output)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       super.viewDidDisappear(animated)
        nvEvents.onNext(.finish)
    }
   
    
    private func createSearchController(_ output:CityViewModel.Output) {
//        let searchController = UISearchController()
//
//        output.searchControllerTitle.drive(onNext: {[weak self] searchControllerTitle in
//            guard let self = self else { return }
//            searchController.searchBar.becomeFirstResponder()
//            searchController.searchBar.placeholder = searchControllerTitle
//            self.nvEvents.onNext(.searchController(searchController))
//        }).disposed(by: disposeBag)
        
       
        
    }
    private func createTable(_ output:CityViewModel.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rx.setDelegate(self).disposed(by: disposeBag)

        tableView.register(SelectCityClinicCell.self, forCellReuseIdentifier: cellIdentifier)
        let dataSourse = GeneralDataSource.dataSource(type: SelectCityClinicCell())
        output.items.drive(tableView.rx.items(dataSource: dataSourse)).disposed(by: disposeBag)
        
       
    }
    
    private func showClinic(_ output:CityViewModel.Output) {
        output.showClinicForIndex.drive(onNext: {  [weak self] index in
            guard let self = self else { return }
            self.nvEvents.onNext(.showClinics(index))
        }).disposed(by: disposeBag)
    }
    
    private func getTitle(_ output:CityViewModel.Output) {
        output.title.drive(onNext: { [weak self] titleText in
            guard let self = self else { return }
            self.nvEvents.onNext(.title(titleText))
        }).disposed(by: disposeBag)
    }
    
    
}

extension CityTVC {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return  50
    }
    
    enum Event {
    case showClinics(_ index:Int)
    case title(_ text:String)
    case searchController(_ searchController:UISearchController)
    case finish
    }
}
