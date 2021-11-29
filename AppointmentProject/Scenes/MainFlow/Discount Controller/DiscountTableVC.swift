//
//  StockTableVC.swift
//  AppointmentProject
//
//  Created by George on 11.11.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class DiscountTableVC: UITableViewController {
    internal let nvContent = PublishSubject<Event>()
    private let disposeBag = DisposeBag()
    private let cellIdentifier = "discountCellIdentifier"

    private let viewModel = DiscountViewModel()
    
    private lazy var dataSourse: RxTableViewSectionedReloadDataSource<DiscountSection> =  .init(configureCell: { [unowned self] dataSource, tableView, indexPath, item in
        
        switch item {
        case .discountModel(info: let data):
            return discountCell(indexPath: indexPath, content: data)
        }
    },titleForFooterInSection: { dataSource , sectionIndex in
//        return dataSource[sectionIndex].model.headerFooter.footer
        return ""

    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.transform(DiscountViewModel.Input())
        createTable(output)
        titleLabel(output)
    }
    
    private func createTable(_ output:DiscountViewModel.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rx
            .setDelegate(self).disposed(by: disposeBag)
        tableView.register(DiscountCell.self, forCellReuseIdentifier: cellIdentifier)

        output.contentTable.drive(tableView.rx.items(dataSource: dataSourse)).disposed(by: disposeBag)

    }

    private func discountCell(indexPath:IndexPath,content:DiscountItemModel) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DiscountCell else {
            return UITableViewCell()
              }
        cell.selectionStyle = .none
        cell.data = content
        return cell
    }
    
    private func titleLabel(_ output:DiscountViewModel.Output) {
        output.titleText.drive(onNext:{[weak self] text in
            guard let self = self else { return }
            self.nvContent.onNext(.title(text))
        }).disposed(by: disposeBag)
    }
    
    enum Event {
        case title(_ text:String)
    }
}

extension DiscountTableVC {
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.textLabel?.textAlignment = .right
        footer.textLabel?.textColor =  #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        footer.textLabel?.font = UIFont(name: "Verdana-Bold", size: 15)
    }
}
