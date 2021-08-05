//
//  AppointmentTVC.swift
//  AppointmentProject
//
//  Created by George on 29.07.2021.
//

import UIKit
import RxSwift
import RxCocoa
class AppointmentTVC: UITableViewController {
let disposeBag = DisposeBag()
    
    @IBOutlet weak var docTitle: UILabel!
    @IBOutlet weak var docName: UILabel!
    @IBOutlet weak var appointmentDate: UILabel!
    @IBOutlet weak var appointmentTime: UILabel!
    @IBOutlet weak var selfFullName: UITextField!
    @IBOutlet weak var subdivisionLabel: UILabel!
    @IBOutlet weak var selfPhone: UITextField!
    @IBOutlet weak var saveCell: UILabel!
    let appointmentModel = BehaviorSubject<AppointmentModel>(value: AppointmentModel())
    private let tapCancel = PublishSubject<Void>()
    private let viewModel = AppointmentTViewModel()
    
    var refreshDelegate:RefreshContentTVProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        let output = viewModel.transform(AppointmentTViewModel.Input(appointmentModel: appointmentModel, selectCell: tableView.rx.itemSelected.asObservable(),patientFullName:selfFullName.rx.text.orEmpty.asObservable(),patientPhoneNumber:selfPhone.rx.text.orEmpty.asObservable(), tapCancel: tapCancel))
        
        contentFill(output)
        presentMap(output)
        appointmentCycle(output)
        alertError(output)
        dismiss(output)
        navigationSettings(output)
    }
   

    private func contentFill(_ output:AppointmentTViewModel.Output) {

        output.startTime
            .drive(appointmentTime.rx.text).disposed(by: disposeBag)
        output.date
            .drive(appointmentDate.rx.text).disposed(by: disposeBag)
        output.subdivisionContent
            .drive(subdivisionLabel.rx.text).disposed(by: disposeBag)
        output.doctorName
            .drive(onNext: {[self] text in
                docName.text = text
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        output.doctorTitleText
            .drive(docTitle.rx.text).disposed(by: disposeBag)
        output.fullNameText
            .drive(selfFullName.rx.placeholder).disposed(by: disposeBag)
        output.saveTitle.drive(saveCell.rx.text).disposed(by: disposeBag)
    }
    
    private func presentMap(_ output:AppointmentTViewModel.Output) {
        output.locationData.drive(onNext: {[self] location in
            let mapController  = self.storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
            mapController.coordinate.onNext(location)
            self.show(mapController, sender: nil)
        }).disposed(by: disposeBag)
    }
    
    private func appointmentCycle(_ output:AppointmentTViewModel.Output) {
        output.startAppointment.drive(onNext: { _ in
            let refreshVC = ActivityVC()
            refreshVC.modalPresentationStyle = .overFullScreen
            self.present(refreshVC, animated:false , completion: nil)
        }).disposed(by: disposeBag)
        
        output.finishAppointment.drive(onNext: { _ in
            self.performSegue(withIdentifier: "unwindToInitialFromAppointment", sender: self)
            self.refreshDelegate?.refreshContent()

        } ).disposed(by: disposeBag)
       
        
    }
    private func alertError(_ output:AppointmentTViewModel.Output) {
        output.alertErrorMessage.drive(onNext: { message in
            let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
            let alerAction = UIAlertAction(title: "×", style: .destructive, handler: nil)
            alertController.addAction(alerAction)
            self.present(alertController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    private func navigationSettings(_ output:AppointmentTViewModel.Output) {
        output.singUpTitle.drive(rx.title).disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close)
        self.navigationItem.rightBarButtonItem!.rx.tap.bind(to: tapCancel).disposed(by: disposeBag)
    }
    private func dismiss(_ output:AppointmentTViewModel.Output) {
        output.dismiss.drive(onNext: { _ in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
}
