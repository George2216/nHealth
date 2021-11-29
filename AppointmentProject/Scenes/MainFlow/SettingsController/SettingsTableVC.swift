//
//  SettingsTableVC.swift
//  AppointmentProject
//
//  Created by George on 31.07.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
final class SettingsTableVC: UITableViewController , Storyboarded {
    internal var nvContent = PublishSubject<Event>()
    
    private let cellIdentifier = "settingsCellIdentifier"
    private let disposeBag = DisposeBag()
    private let viewModel = SettingsTableViewModel()
    private lazy var itemSelectedIndex:Observable<Int> = {
        return tableView.rx.itemSelected.map{$0.row}
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let output = viewModel.transform(SettingsTableViewModel.Input(selectCell: itemSelectedIndex))
        navigationSettings(output)
        createTable(output)
        output.pushLanguage.drive(onNext:pushLanguageTVC).disposed(by: disposeBag)
        output.pushServer.drive(onNext:pushServerSettings).disposed(by: disposeBag)
        output.pushAboutUs.drive(onNext:presentDetailWebView).disposed(by: disposeBag)
        output.pushPushNotification.drive(onNext:pushPushNotificatios).disposed(by: disposeBag)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nvContent.onNext(.prefersLargeTitles(true))
        tableView.contentOffset = CGPoint(x: 0, y: -150)
    }
    
   
    private func navigationSettings( _ output:SettingsTableViewModel.Output){
        output.titleSettings.drive(onNext: {titleText in
            self.nvContent.onNext(.title(titleText))
        }).disposed(by: disposeBag)

    }
    private func pushLanguageTVC() {
        nvContent.onNext(.tapLanguage)
    }
    
    private func presentDetailWebView() {
        nvContent.onNext(.tapAboutUs)
    }
    private func pushServerSettings() {
        nvContent.onNext(.tapServer)
    }
    private func pushPushNotificatios() {
        nvContent.onNext(.tapPushNotification)
    }
    
    private func createTable(_ output:SettingsTableViewModel.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(TableViewCellImage.self, forCellReuseIdentifier: cellIdentifier)
        output.tableData.drive(tableView.rx.items(cellIdentifier: cellIdentifier, cellType: TableViewCellImage.self)) {  row , data , cell in
            
            var iconColor:UIColor = .white
            switch row {
            case 0: iconColor = #colorLiteral(red: 0.8161486983, green: 0.465211153, blue: 0.9023320079, alpha: 1)
            case 1: iconColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            case 2: iconColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
            case 3: iconColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            default:
                break
            }
            cell.accessoryType = .disclosureIndicator
            cell.data = TVCellImageModel(imageName: data.systeimageName, imageColor: iconColor, titleText: data.textLabel, textSize: .big)
            
        }.disposed(by: disposeBag)
    }
    override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0.0
    }
}
// events
extension SettingsTableVC {
    enum Event {
        case title(_ text :String)
        case prefersLargeTitles(_ large:Bool)
        case tapLanguage
        case tapServer
        case tapAboutUs
        case tapPushNotification
    }
}
