//
//  SubdivisionTableVC.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import UIKit
import RxSwift
import RxCocoa

protocol MapDelegate {
    func showMap(longitude:String,latitude:String, title:String,subtitle:String)
}

class SubdivisionTableVC: UITableViewController {

    private let subdivisionCellIdentifier = "subdivisionCellIdentifier"
    private let disposeBag = DisposeBag()
    private let viewModel = SubdivisionViewModel()
    private let tapCancel = PublishSubject<Void>()
    override func viewDidLoad() {
        super.viewDidLoad()

        let output = viewModel.transform(SubdivisionViewModel.Input(selectCell: tableView.rx.itemSelected.map{$0.row}, tapCancel: tapCancel))
        createTable(output)
        selectCell(output)
        selfDismiss(output)
        navigationSettings(output)

        
    }
    private func createTable(_ output:SubdivisionViewModel.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        
        output.subdvisionContent.drive(tableView.rx.items(cellIdentifier: subdivisionCellIdentifier, cellType: SubdivisionCell.self)) { row, model ,cell in
            cell.model = model
            cell.delegate = self
        }.disposed(by: disposeBag)
    }
    
    private func selectCell(_ output:SubdivisionViewModel.Output) {
        
        output.selectCellData.drive(onNext: {[self] text , id in
            let professions = storyboard?.instantiateViewController(identifier: "ProfessionTVC") as! ProfessionTVC
            professions.clinicId.onNext(id)
            show(professions, sender: nil)
            
        }).disposed(by: disposeBag)
    }
    
    private func navigationSettings(_ output:SubdivisionViewModel.Output){
        output.subdivisionTitle.drive(rx.title).disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close)
        self.navigationItem.rightBarButtonItem!.rx.tap.bind(to: tapCancel).disposed(by: disposeBag)
    }
    
    private func selfDismiss(_ output:SubdivisionViewModel.Output) {
        output.tapCancel.drive(onNext: { _ in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
}

extension SubdivisionTableVC : MapDelegate {
   
    func showMap(longitude: String, latitude: String, title: String, subtitle: String) {
        let mapController  = storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
        mapController.coordinate.onNext((latitude: latitude, longitude: longitude, title: title, subtitle: subtitle))
        show(mapController, sender: nil)
    }
    
}
