//
//  InitialTableVC.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


final class InitialTableVC: UITableViewController ,Storyboarded  {
    internal let nvContent = PublishSubject<Event>()
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var collectionFilter: UICollectionView!
    
    private let doctorCellIdentifier = "DoctorCell"
    private let filterCellIdentifier = "FilterCellIdentifier"
    private let disposeBag = DisposeBag()
    private var searchTable = TableDoctors()
    private var selfView = UIView()
    private var selectDate = PublishSubject<Date>()
    private var filterCollectionLayout = UICollectionViewFlowLayout()
    private let filterData = PublishSubject<(clinicId:String,professions:[String])>()
    private let viewModel = InitialTableViewModel()
    private let refreshTableView = PublishSubject<Void>()
    private let searchText = PublishSubject<String>()
    private let selectedSlot = PublishSubject<SelectedTimeSlotModel>()
    private let selectedDoctorFromSearch = PublishSubject<Int>()
    
    private lazy var selectDoctorCell:Observable<Int> = {
        tableView.rx.itemSelected.map{$0.section}
    }()
    private lazy var refreshActiont:Observable<Void> = {
        tableView.refreshControl!.rx.controlEvent(.valueChanged).asObservable()
    }()
    private lazy var selectFilterCell:Observable<Int> = {
        collectionFilter.rx.itemSelected.map{$0.row}
    }()
    
    private lazy var dataSourse: RxTableViewSectionedReloadDataSource<InitialTableSection> =  .init(configureCell: { [unowned self] (dataSource, tableView, indexPath, item) in
        switch item {
        case .defaultItem(let dataCell):
        return defaultCell(indexPath: indexPath, data: dataCell)
        }
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        selfView = self.view
        tableView.refreshControl = UIRefreshControl()
        

        let output  = viewModel.transform(InitialTableViewModel.Input(indexSelectFilterCell: selectFilterCell, selectedDate: selectDate.asObservable(), textDidBeginEditing: searchBar.rx.textDidBeginEditing.asObservable(),textDidEndEditing: searchBar.rx.textDidEndEditing.asObservable(), cancelButtonClicked: searchBar.rx.cancelButtonClicked.asObservable(), selectedDoctorIndex: selectDoctorCell, refreshControl: refreshActiont, filterData: filterData, refreshTableView: refreshTableView, searchBarText: searchText, selectedSlot: selectedSlot, selectedDoctorFromSearch: selectedDoctorFromSearch))
        
        
    
        addTableView(output)
        addFilterCollection(output)
        addSearchTable(output)
        addSearchBar(output)

        
        showAppointment(output)
        showSubdvisions(output)
        showCalendar(output)
        showDoctor(output)

        textDidBeginEditing(output)
        textDidEndEditing(output)
        
        cancelButtonClicked(output)
        selectSearchTableCell(output)
        

        reloadTable(output)
        
        subscribeOnSearchString()
        filterLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            selectDate.onNext(Date())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.setPlaseholderPosition(.center)
    }
    
    
    
    private func reloadTable(_ output:InitialTableViewModel.Output) {
        output.reloadTable.drive(onNext:{ [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }).disposed(by: disposeBag)
    }
    
   
    
    private func selectSearchTableCell(_ output:InitialTableViewModel.Output) {
        searchTable.selectedCell.subscribe(onNext: {[weak self] index in
            guard let self = self else { return }
            self.nvContent.onNext(.dismissKeyboard)
            self.selectedDoctorFromSearch.onNext(index)
        }).disposed(by: disposeBag)
    }
    
    // create search bar
    private func cancelButtonClicked(_ output:InitialTableViewModel.Output) {
        output.cancelButtonClicked.drive(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.nvContent.onNext(.dismissKeyboard)

        }).disposed(by: disposeBag)
    }
    
    private func textDidBeginEditing(_ output:InitialTableViewModel.Output) {
        output.textDidBeginEditing.withLatestFrom(output.canselButtonTitle).drive(onNext: { [weak self] titleButton in
                guard let self = self else { return }
            self.view = self.searchTable
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }

            self.searchBar.setPlaseholderPosition(.left)
            let uiButton = self.searchBar.value(forKey: "cancelButton") as! UIButton
            uiButton.rx.title().onNext(titleButton)
            self.searchBar.layoutIfNeeded()
        }
        }).disposed(by: disposeBag)
    }
    
    private func textDidEndEditing(_ output:InitialTableViewModel.Output) {
        output.textDidEndEditing.drive(onNext: {[weak self] _ in
            guard let self = self else { return }

             self.view = self.selfView
            
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }

            self.searchBar.setPlaseholderPosition(.center)
            self.searchBar.layoutIfNeeded()
        }
        }).disposed(by: disposeBag)
    }
    
    private func subscribeOnSearchString() {
        searchBar.rx.text.subscribe(onNext: {[weak self] text in
            guard let self = self else { return }
            self.searchText.onNext(text ?? "" )
        }).disposed(by: disposeBag)
        
    }
    
  
    
// create collection filter layout
    private func filterLayout() {
        filterCollectionLayout.scrollDirection = .horizontal
        filterCollectionLayout.minimumLineSpacing = 15
        filterCollectionLayout.minimumInteritemSpacing = 15
        filterCollectionLayout.sectionInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 10)
        filterCollectionLayout.estimatedItemSize = CGSize(width: 200, height: 30)
        filterCollectionLayout.itemSize = CGSize(width: 100, height: 30)
    }
    
    
    private func addSearchTable(_ output:InitialTableViewModel.Output) {
        
        output.searchBarPlaceholder.drive(onNext:{ [weak self] placeholder in
            guard let self = self else { return }
            self.searchBar.rx.placeholder.onNext(placeholder)
        }).disposed(by: disposeBag)
        
        output.searchTableData.drive(onNext:{ [weak self] searchTableContent in
            guard let self = self else { return }
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0)
            self.searchTable.contentTable.onNext(searchTableContent)
            self.searchTable.frame = frame
            
        }).disposed(by: disposeBag)
       
    }
    
    private func addFilterCollection(_ output:InitialTableViewModel.Output) {
        collectionFilter.showsHorizontalScrollIndicator = false
        collectionFilter.setCollectionViewLayout(filterCollectionLayout, animated: true)
        output.cellData.drive(collectionFilter.rx.items(cellIdentifier: filterCellIdentifier, cellType: FilterCell.self)) { $2.data = $1 }.disposed(by: disposeBag)
    }
    
    private func addSearchBar(_ output:InitialTableViewModel.Output) {
        nvContent.onNext(.navBarView(searchBar))
    }
    
    private func addTableView(_ output:InitialTableViewModel.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView
            .rx.setDelegate(self).disposed(by: disposeBag)
        output.tableItems.drive(tableView.rx.items(dataSource: dataSourse)).disposed(by: disposeBag)
    }
  
    
    
    private func showDoctor(_ output:InitialTableViewModel.Output) {

        output.selectDoctor.drive(onNext: {[weak self]  doctor in
            guard let self = self else { return }
            self.nvContent.onNext(.tapDoctor(doctor))
            
        }).disposed(by: disposeBag)
    }
    
    private func showAppointment(_ output:InitialTableViewModel.Output) {
        output.appointmentModel.drive(onNext:  {[weak self] model in
            guard let self = self else { return }
            self.nvContent.onNext(.appointmentContent(model))
        }).disposed(by: disposeBag)
        
    }

    private func showCalendar(_ output:InitialTableViewModel.Output) {
        output.presentCalendar.drive(onNext:{[weak self] _ in
            guard let self = self else { return }
            self.nvContent.onNext(.tapCalendar)
        }).disposed(by: disposeBag)
     }
   
    private func showSubdvisions(_ output:InitialTableViewModel.Output) {
        output.presentClinic.withLatestFrom(output.subdivisionId).drive(onNext: {[weak self] clinicId in
            guard let self = self else { return }
            self.nvContent.onNext(.tapProfessions(clinicId))
        }).disposed(by: disposeBag)
    }
    
    
    // create DoctorCell
    private func defaultCell(indexPath:IndexPath,data:DoctorModelCell) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: doctorCellIdentifier, for: indexPath) as? DoctorCell else {
            return UITableViewCell()
              }
        cell.selectSlot.subscribe(onNext: {[weak self] index in
            guard let self = self else { return }
        
            self.selectedSlot.onNext(SelectedTimeSlotModel(indexSlot: index, indexPathDoc: indexPath))
            
        }).disposed(by: cell.externalDisposeBag)
        
        cell.data = data
        cell.selectionStyle = .none
        
        return cell
    }
    
}
   
extension InitialTableVC:CalendarDateProtocol   {
    
    func refreshContent() {
        refreshTableView.onNext(())
    }
    
    // tap save on calendar controller
    func selectDate(_ date: Date) {
        selectDate.onNext(date)
    }
    
    // get filter data from ProfessionTVC
    @IBAction func unwindToInitialVC(sender: UIStoryboardSegue) {
        if let profVC = sender.source as? ProfessionTVC {
            profVC.saveData.subscribe(filterData).disposed(by: disposeBag)
         }
    }
        
}

// events
extension InitialTableVC {
    
    enum Event {
    case dismissKeyboard
    case navBarView(_ view:UIView)
    case appointmentContent( _ model:AppointmentModel)
    case tapDoctor(_ parametrs:DoctorContent)
    case tapProfessions(_ clinicId:String)
    case tapCalendar
    
    }
}
