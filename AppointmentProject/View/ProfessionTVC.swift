//
//  ProfessionTVC.swift
//  AppointmentProject
//
//  Created by George on 16.07.2021.
//

import UIKit
import RxSwift
import RxCocoa

class ProfessionTVC: UITableViewController {
    private let cellIdentifier = "SpecialityCellIdentifier"
    private let disposeBag = DisposeBag()
    let clinicId = BehaviorSubject<String>(value: "")
    @IBOutlet weak var segmentControl: UISegmentedControl!
    private  let viewModel =  ProfessionViewModel()
    private  let tapSave = PublishSubject<Void>()
    let saveData = BehaviorSubject<(clinicId:String,professions:[String])>(value: (clinicId: String(), professions: []))

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSettings()
        
        let output =  viewModel.transform(ProfessionViewModel.Input(idClinic: clinicId, segmentIndex: segmentControl.rx.selectedSegmentIndex.asObservable(), selectCellIndex: tableView.rx.itemSelected.map{$0.row}, tapSave:  tapSave))
        
        navigationSettings()
        createTableView(output)
        cellIsEnuble(output)
        saveAndDismiss(output)
    }
    
    
    private  func saveAndDismiss(_ output:ProfessionViewModel.Output) {
        output.saveData.drive(onNext: {[self] data in
            saveData.onNext(data)
            performSegue(withIdentifier: "unwindToInitialVCWithSender", sender: self)
        }).disposed(by: disposeBag)
    }
    
    private  func createTableView(_ output:ProfessionViewModel.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        output.specialties.drive(tableView.rx.items(cellIdentifier: cellIdentifier, cellType: UITableViewCell.self)) { row , model , cell in
            
            cell.textLabel?.text = model.name
            cell.imageView?.image = model.isSelected ? UIImage(systemName: "largecircle.fill.circle") : UIImage(systemName: "circle")
            cell.contentView.alpha = model.alpha
            
        }.disposed(by: disposeBag)
    }
    
    private   func navigationSettings() {
        title = "Professions"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: nil, action: nil)
        self.navigationItem.titleView = segmentControl
        self.navigationItem.rightBarButtonItem?.rx.tap.subscribe(onNext: {_ in
            self.tapSave.onNext(())
        }).disposed(by: disposeBag)
    }
    
    private  func cellIsEnuble(_ output:ProfessionViewModel.Output) {
        output.cellIsEnuble.drive(tableView.rx.allowsSelection).disposed(by: disposeBag)
    }
}
