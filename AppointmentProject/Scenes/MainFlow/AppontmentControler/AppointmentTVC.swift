//
//  AppointmentTVC.swift
//  AppointmentProject
//
//  Created by George on 29.07.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class AppointmentTVC: UITableViewController ,Storyboarded , SwipingViewControllerProtocol {
    private let disposeBag = DisposeBag()

    var emptyText = Observable<String>.just("")
    var viewController: UIViewController?
    var contentOffset: CGPoint?
    
    internal let nvContent = PublishSubject<Event>()

    private let doctorCellIdentifier = "appointmentDoctorHeaderCellIdentifier"
    private let contentCellIdentifier = "appointmentContentCellIdentifier"
    private let patientDataCellIdentifier = "appointmentPatientDataCellIdentifier"
    private let saveCellIdentifier = "appointmentSaveCellIdentifier"
    

    let appointmentModel = BehaviorSubject<AppointmentModel>(value: AppointmentModel())
    
    private let tapCancel = PublishSubject<Void>()
    private let viewModel = AppointmentTViewModel()
    private let textFieldsData = PublishSubject<(String,IndexPath)>()
    
    private lazy var dataSourse: RxTableViewSectionedReloadDataSource<AppointmentSection> =  .init(configureCell: { [unowned self] (dataSource, tableView, indexPath, item) in
        switch item {
        case .doctorItem(title: let titleText, subtitle: let doctorName):
            let cell =  doctorHeaderCell(textLabel: titleText, subtitle: doctorName, indexPath: indexPath)
              return cell
        case .staticItem(imageName: let imageName, text: let titleText):
            
            switch indexPath.row {
            case 0 :
            let cell =  contentCell(cellData: TVCellImageModel(imageName: imageName, imageColor: #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1), titleText: titleText, textSize: .big), indexPath: indexPath)
            return cell
            case 1 :
            let cell =  contentCell(cellData: TVCellImageModel(imageName: imageName, imageColor: #colorLiteral(red: 0.9946255088, green: 0.3231649399, blue: 0.5513989925, alpha: 1), titleText: titleText, textSize: .big), indexPath: indexPath)
            return cell
            case 2 :
            
            let cell = contentCell(cellData: TVCellImageModel(imageName: imageName, imageColor: #colorLiteral(red: 0, green: 0.744449079, blue: 0.9403274655, alpha: 1), titleText: titleText, textSize: .little), indexPath: indexPath)
            cell.accessoryType = .disclosureIndicator
            return cell
                default:
            return UITableViewCell()

            }
            
        case .patientDataItem(imageName: let imageName, placeholder: let placeholder):
            switch indexPath.row {
            case 0 :
            let cell = patientDataCell(cellData: AppointmentFillCellModel(imageName: imageName, imageColor: #colorLiteral(red: 0.4073300958, green: 0.5701116323, blue: 0.9469365478, alpha: 1), plaseholderTextField: placeholder, indexPath: indexPath))
            return cell
            case 1:
            let cell = patientDataCell(cellData: AppointmentFillCellModel(imageName: imageName, imageColor: #colorLiteral(red: 0.3141100407, green: 0.8278055787, blue: 0.444432497, alpha: 1), plaseholderTextField: placeholder, indexPath: indexPath))
            return cell

            default:break
            }
            
        case .saveItem(title: let titleText):
            return saveCell(textLabel: titleText, indexPath: indexPath)
    }
       return UITableViewCell()
    }, titleForHeaderInSection: { dataSource, sectionIndex in
        
        return ""
        
        } , titleForFooterInSection: { dataSource, sectionIndex in

        return  ""
    })
    
    
    override func loadView() {
        super.loadView()
        viewController = self
        contentOffset = tableView.contentOffset
        self.addSwipeGesture()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        let output = viewModel.transform(AppointmentTViewModel.Input(appointmentModel: appointmentModel, selectCell: tableView.rx.itemSelected.asObservable(),patientFullName:emptyText,patientPhoneNumber:emptyText, tapCancel: tapCancel, textFieldsData: textFieldsData))
        
        createTable(output)
        presentMap(output)
        appointmentCycle(output)
        alertError(output)
        dismiss(output)
        navigationSettings(output)
        
    }
    

    override func viewDidDisappear(_ animated: Bool) {
       super.viewDidDisappear(animated)
        nvContent.onNext(.finish)

    }
    private func createTable(_ output:AppointmentTViewModel.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        tableView.register(AppointmentDoctorHeaderCell.self, forCellReuseIdentifier: doctorCellIdentifier)
        tableView.register(TableViewCellImage.self, forCellReuseIdentifier: contentCellIdentifier)
        tableView.register(AppointmentFillCell.self, forCellReuseIdentifier: patientDataCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: saveCellIdentifier)
        
        output.items.drive(tableView.rx.items(dataSource: dataSourse)).disposed(by: disposeBag)
    }
    
    private func doctorHeaderCell(textLabel:String,subtitle:String,indexPath:IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: doctorCellIdentifier, for: indexPath) as? AppointmentDoctorHeaderCell else {
            return UITableViewCell()
              }
        cell.selectionStyle = .none
        cell.data = AppointmentDoctorCellModel(title: textLabel, subtitle: subtitle)
        return cell
    }
    
    
    private func contentCell(cellData:TVCellImageModel,indexPath:IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: contentCellIdentifier, for: indexPath) as? TableViewCellImage else {
            return UITableViewCell()
              }
    
        cell.data = cellData
        return cell
    }
    
    private func patientDataCell(cellData:AppointmentFillCellModel) -> UITableViewCell  {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: patientDataCellIdentifier, for: cellData.indexPath) as? AppointmentFillCell else {
            return UITableViewCell()
              }
        cell.data = cellData
        cell.selectionStyle = .none
        cell.textFieldDelegate = self
        return cell
    }
    
    private func saveCell(textLabel:String,indexPath:IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: saveCellIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = textLabel
        content.textProperties.alignment = .center
        content.textProperties.color = .systemBlue
        cell.contentConfiguration = content
        cell.selectionStyle = .none

        return cell
        
    }
    
    private func presentMap(_ output:AppointmentTViewModel.Output) {
        output.locationData.drive(onNext: {[self] location in
            nvContent.onNext(.showMap(content: location))
        }).disposed(by: disposeBag)
    }
    
    private func appointmentCycle(_ output:AppointmentTViewModel.Output) {
        output.startAppointment.drive(onNext: { _ in
            self.nvContent.onNext(.showActivityInicator)
        }).disposed(by: disposeBag)
        
        output.finishAppointment.drive(onNext: { _ in
            self.nvContent.onNext(.goBack)
            self.nvContent.onNext(.goToInitialVC)

        } ).disposed(by: disposeBag)
    }
    private func alertError(_ output:AppointmentTViewModel.Output) {
        output.alertErrorMessage.drive(onNext: { [weak self] message in
            guard let self = self else { return }
            self.nvContent.onNext(.showErrorMessage(title: message))
        }).disposed(by: disposeBag)
    }
    
    private func navigationSettings(_ output:AppointmentTViewModel.Output) {
        output.singUpTitle.drive(onNext:{[self] titleText in
            nvContent.onNext(.title(titleText))
        }).disposed(by: disposeBag)
        let backButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: nil, action: nil)
        backButton.tintColor = .black
        backButton.rx.tap.subscribe(tapCancel).disposed(by: disposeBag)
        nvContent.onNext(.backButton(backButton))
    }
    
    private func dismiss(_ output:AppointmentTViewModel.Output) {
        output.dismiss.drive(onNext: { _ in
            self.nvContent.onNext(.goBack)
        }).disposed(by: disposeBag)
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}


extension AppointmentTVC {
    enum Event {
        case finish
        case goBack
        case showMap(content:CoordinateModel)
        case showActivityInicator
        case backButton(_ batton:UIBarButtonItem)
        case title(_ title:String)
        case showErrorMessage(title:String)
        case goToInitialVC
    }
}


extension AppointmentTVC : PatientDataProtocol {
    func changeText(text: String, on indexPath: IndexPath) {
        textFieldsData.onNext((text, indexPath))
    }
}
