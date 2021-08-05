//
//  TableViewSearch.swift
//  AppointmentProject
//
//  Created by George on 21.07.2021.
//

import UIKit
import RxSwift
import RxCocoa

class TableDoctors: UITableView {
    let disposeBag = DisposeBag()
    let cellIdentifier = "DoctorSearchForName"
    let contentTable = BehaviorSubject<[ParamDoctor]>(value: [])
    var doctorDelegate:SelectDoctorProtocol?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        createTable()
        subscribeOnSelect()
    }
    
    func createTable() {
        self.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        contentTable.bind(to: self.rx.items(cellIdentifier: cellIdentifier, cellType: UITableViewCell.self)) { row , model , cell in
            print(model)
            
            cell.textLabel?.text = model.name
            cell.selectionStyle = .none
        }.disposed(by: disposeBag)
    }
    
    func subscribeOnSelect() {
        self.rx.modelSelected(ParamDoctor.self).subscribe(onNext: {  doctor in
            self.doctorDelegate?.selectDoctor(id: doctor.id, pushFrom: nil)
        }).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
