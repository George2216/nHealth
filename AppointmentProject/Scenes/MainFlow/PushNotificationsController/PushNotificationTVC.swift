//
//  PushNotificationTVC.swift
//  AppointmentProject
//
//  Created by George on 19.10.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol ChangeVulueSwitchProtocol {
    func change(_ configuration:ChangeSwitchCaseModel)
}

final class PushNotificationTVC: UITableViewController {
    internal let nvContent = PublishSubject<Event>()

    private let disposeBag = DisposeBag()
    private let notificationCellIdentifier = "notificationCellIdentifier"
    private let goToSettingsCellIdentifier = "goToSettingsCellIdentifier"
    private let viewModel = PushNotificationVM()
    private let changeSwithCase = PublishSubject<ChangeSwitchCaseModel>()
    
    private lazy var dataSourse: RxTableViewSectionedReloadDataSource<NotificationSection> = .init(configureCell: { [unowned self] (dataSource, tableView, indexPath, item) in
        switch item {
        case .switchModelData(info: let info):
            let cell = configureNotificationCell(indexPath: indexPath, content: info)
            return cell
        case .goToSettingsModel(title: let titleText, imageName: let imageName):
            let settingsCell = SettingsCell()
            let cell = creteSettingsCell(indexPath: indexPath, titleText: titleText, imageName: imageName)
            return cell
        }
        } , titleForHeaderInSection: { dataSource, sectionIndex in
        
        return dataSource[sectionIndex].model.headerFooter.header
        
        } , titleForFooterInSection: { dataSource, sectionIndex in
        
        return dataSource[sectionIndex].model.headerFooter.footer
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.transform(PushNotificationVM.Input(changeValueIndex: changeSwithCase, selectCell: tableView.rx.itemSelected.asObservable()))
        createTable(output)
        output.title.drive(rx.title).disposed(by: disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nvContent.onNext(.isLargeTitle(false))
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        nvContent.onNext(.finish)
    }
    private func createTable(_ output:PushNotificationVM.Output) {
     
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rx.setDelegate(self).disposed(by: disposeBag)

        tableView.register(NotificationCell.self, forCellReuseIdentifier: notificationCellIdentifier)
        tableView.register(TableViewCellImage.self, forCellReuseIdentifier: goToSettingsCellIdentifier)
        
        output.items.drive(tableView.rx.items(dataSource: dataSourse)).disposed(by: disposeBag)
       
    }
    
    
    private func configureNotificationCell(indexPath:IndexPath,content:NotificationCellModel) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: notificationCellIdentifier, for: indexPath) as? NotificationCell else {
            return UITableViewCell()
              }
        cell.content = content
        cell.changeSwitchDelegate = self
        cell.saveIndexPath(indexPath)
        return cell
    }
    
    private func creteSettingsCell(indexPath:IndexPath,titleText:String,imageName:String) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: goToSettingsCellIdentifier, for: indexPath) as? TableViewCellImage else {
            return UITableViewCell()
              }
    
        let imageColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        cell.data = TVCellImageModel(imageName: imageName, imageColor: imageColor, titleText: titleText, textSize: .big)
        cell.accessoryType = .disclosureIndicator
            return cell
        
    }
    enum Event {
        case isLargeTitle(_ bool:Bool)
        case finish
    }
}
extension PushNotificationTVC:ChangeVulueSwitchProtocol {
    func change(_ configuration:ChangeSwitchCaseModel) {
        changeSwithCase.onNext(configuration)
    }
    
}
