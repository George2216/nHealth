//
//  InitialTableVC.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import UIKit
import RxSwift
import RxCocoa
import XMLCoder

protocol CalendarDateProtocol {
    func selectDate(_ date:Date)
}
protocol SelectDoctorProtocol {
    func selectDoctor(id:String,pushFrom:UIViewController?)
}

protocol SelectTimeSlotProtocol {
    func selectSlot(docId:String,rowSlot:Int)
}
protocol SelectTimeSlotOnDocTVCProtocol:SelectTimeSlotProtocol {
    func selectDateDocTVC(date:Date)
}

protocol RefreshContentTVProtocol {
    func refreshContent()
}

class InitialTableVC: UITableViewController {
    private let disposeBag = DisposeBag()
    private let searchTable = TableDoctors()
    private var selfView = UIView()
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var collectionFilter: UICollectionView!
    private let viewModel = InitialTableViewModel()
    private var selectDate = PublishSubject<Date>()
    private var layout = UICollectionViewFlowLayout()
    private var selectSubdivisionCell = PublishSubject<(name: String, id: String)>()
    private let selectDoctorId = PublishSubject<String>()
    private let filterData = PublishSubject<(clinicId:String,professions:[String])>()
    private let selectTimeSlot = PublishSubject<(docId:String,indexSlot:Int)>() //  select time slot
    private let pushDocFrom = BehaviorSubject<UIViewController>(value: UIViewController())
    
    private let refreshTableView = PublishSubject<Void>()
    private let searchText = PublishSubject<String>()
    override func viewDidLoad() {
        super.viewDidLoad()
        selfView = self.view
        tableView.refreshControl = UIRefreshControl()
        let output = viewModel.transform(InitialTableViewModel.Input(indexSelectFilterCell: collectionFilter.rx.itemSelected.map{$0.row}, selectDate: selectDate.asObservable(), textDidBeginEditing: searchBar.rx.textDidBeginEditing.asObservable(),textDidEndEditing: searchBar.rx.textDidEndEditing.asObservable(), cancelButtonClicked: searchBar.rx.cancelButtonClicked.asObservable(), selectDoctorId: selectDoctorId, refreshControl: tableView.refreshControl!.rx.controlEvent(.valueChanged).asObservable(), filterData: filterData, selectTimeSlot: selectTimeSlot, refreshTableView: refreshTableView, searchBarText: searchText))
        
        createTableView(output)
        createFilterCollection(output)
        createSearchTable(output)
        pushDetailDoctor(output)
        appointmentAction(output)
        navigationSettings(output)
        textDidBeginEditing(output)
        
        output.presentCalendar.drive(onNext: presentCalendar).disposed(by: disposeBag)
        output.presentClinic.drive(onNext: presentSubdvision).disposed(by: disposeBag)
        output.textDidEndEditing.drive(onNext:textDidEndEditing).disposed(by: disposeBag)
        output.cancelButtonClicked.drive(onNext:cancelButtonClicked).disposed(by: disposeBag)
        output.reloadTable.drive(onNext: reloadTable).disposed(by: disposeBag)
        subscribeOnSearchString()
        sharDocDataToAppointments()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
            DispatchQueue.main.async {
                print("Reload")
                self.tableView.reloadData()
            }
        }
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        filterLayout()
        self.searchBar.setPlaseholderPosition(.center)
    }
    
    private func reloadTable() {
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
        
    }
    
    private func createSearchTable(_ output:InitialTableViewModel.Output) {
        
        searchTable.doctorDelegate = self
        output.searchBarPlaseholder.drive(searchBar.rx.placeholder).disposed(by: disposeBag)
        
        output.searchTableData.drive(searchTable.contentTable)
            .disposed(by: disposeBag)
        
        let startSearchFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0)
        searchTable.frame = startSearchFrame
    }
    
    // create search bar
    private func cancelButtonClicked() {
        self.tabBarController?.view.endEditing(true)
       
    }
    
    private func textDidBeginEditing(_ output:InitialTableViewModel.Output) {
        output.textDidBeginEditing.withLatestFrom(output.canselButtonTitle).drive(onNext: { [self] titleButton in
        view = searchTable
        UIView.animate(withDuration: 0.2) { [self] in
            searchBar.setPlaseholderPosition(.left)
            self.searchBar.showsCancelButton = true

            let uiButton = self.searchBar.value(forKey: "cancelButton") as! UIButton
            
            uiButton.rx.title().onNext(titleButton)
            self.searchBar.layoutIfNeeded()
    }
        }).disposed(by: disposeBag)
    }
    private func textDidEndEditing() {
        view = selfView
        UIView.animate(withDuration: 0.2) { [self] in
            searchBar.setPlaseholderPosition(.center)
            searchBar.showsCancelButton = false
            searchBar.layoutIfNeeded()
        }
    }
    
    private func subscribeOnSearchString() {
        searchBar.rx.text.subscribe(onNext: {[self] text in
            searchText.onNext(text ?? "" )
        }).disposed(by: disposeBag)
        
    }
    
    // create filters collection view
    private func createFilterCollection(_ output:InitialTableViewModel.Output) {
        collectionFilter.showsHorizontalScrollIndicator = false
        collectionFilter.setCollectionViewLayout(layout, animated: true)
        
        output.cellData.drive(collectionFilter.rx.items(cellIdentifier: "FilterCellIdentifier", cellType: FilterCell.self)) { $2.data = $1 }.disposed(by: disposeBag)
    }
    
// create collection filter layout
    private func filterLayout() {
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 15
    layout.minimumInteritemSpacing = 15
    layout.sectionInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 10)
    layout.estimatedItemSize = CGSize(width: 200, height: 30)
    layout.itemSize = CGSize(width: 100, height: 30)
    }
    
    // navigation
    private func navigationSettings(_ output:InitialTableViewModel.Output) {
        
        self.navigationItem.titleView = searchBar
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    
    // present calendar controller
    private func presentCalendar() {
        let calendarController = storyboard?.instantiateViewController(identifier: "CalendarController") as! CalendarController
        calendarController.delegate = self
        present(calendarController, animated: true, completion: nil)
     }
    
    private func presentSubdvision() {
        let subdivisionTableVC = storyboard?.instantiateViewController(identifier: "SubdivisionTableVC") as! SubdivisionTableVC
        
        let navController = UINavigationController(rootViewController: subdivisionTableVC)
        show(navController, sender: nil)
    }
    
 
    private func createTableView(_ output:InitialTableViewModel.Output) {
        tableView.delegate = nil
        tableView.dataSource = nil
        
        output.doctorData.drive(tableView.rx.items(cellIdentifier: "DoctorCell", cellType: DoctorCell.self)) { [self] row , data , cell in
            cell.data = data
            cell.tag = row
            cell.delegateSelect = self
        }.disposed(by: disposeBag)
    }
    
    private func pushDetailDoctor(_ output:InitialTableViewModel.Output) {

        output.selectDoctor.asObservable().withLatestFrom(Observable.combineLatest(pushDocFrom, output.selectDoctor.asObservable())).subscribe(onNext: {[self] controller , doctor in
            let tableDoctor = storyboard?.instantiateViewController(identifier: "TableViewDoctor") as! TableViewDoctor

            
            tableDoctor.selectTimeSlotDelegate = self
            tableDoctor.paramDoctor.onNext(doctor)
        
            controller.navigationController?.pushViewController(viewController: tableDoctor, animated: true, completion: {
                tableDoctor.paramDoctor.onNext(doctor)
            })
           
        
        }).disposed(by: disposeBag)
    }
    
    private func appointmentAction(_ output:InitialTableViewModel.Output) {
        output.appointmentModel.drive(onNext:  {[self] model in
            let appointmentTVC = self.storyboard?.instantiateViewController(identifier: "AppointmentTVC") as! AppointmentTVC
            
            let nav = UINavigationController(rootViewController: appointmentTVC)
            appointmentTVC.appointmentModel.onNext(model)
            appointmentTVC.refreshDelegate = self
            self.present(nav, animated: true) {
                appointmentTVC.appointmentModel.onNext(model)
            }
            
        }).disposed(by: disposeBag)
        
    }

    private func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
   
    private func sharDocDataToAppointments() {
        let tapBar = storyboard?.instantiateViewController(withIdentifier: "MyTapBar") as? UITabBarController
        var appointmentsNavigation = tapBar?.viewControllers![1] as? UINavigationController
        let appointmentsController =         appointmentsNavigation?.topViewController as? MyAppointmentsTVC
        appointmentsController!.delegateSelectDoctor = self
        appointmentsNavigation = UINavigationController(rootViewController: appointmentsController!)
        let myImage =         self.tabBarController?.viewControllers![1].tabBarItem.image
        self.tabBarController?.viewControllers![1] = appointmentsNavigation!
        self.tabBarController?.viewControllers![1].tabBarItem.image = myImage
        }
    }
   
// custom delegates
extension InitialTableVC:CalendarDateProtocol  ,SelectDoctorProtocol , SelectTimeSlotProtocol , RefreshContentTVProtocol ,SelectTimeSlotOnDocTVCProtocol {
    
    func selectDateDocTVC(date: Date) {
        selectDate.onNext(date)
    }
    
    func refreshContent() {
        refreshTableView.onNext(())
    }
    
    func selectSlot(docId: String, rowSlot: Int) {
        selectTimeSlot.onNext((docId: docId, indexSlot: rowSlot))
        }
    
    func selectDoctor(id: String,pushFrom:UIViewController?) {
        pushDocFrom.onNext(pushFrom ?? self)
        self.tabBarController?.view.endEditing(true)
        selectDoctorId.onNext(id)
        
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

