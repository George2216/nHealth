//
//  TableViewDoctor.swift
//  AppointmentProject
//
//  Created by George on 22.07.2021.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa
class TableViewDoctor: UITableViewController {
    private let disposeBag = DisposeBag()
    private let cellIdentifier = "CalendarCellIdentifier"
    @IBOutlet weak var calendarScopeButton: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var collectionSlots: DynamicHeightCollectionView!
    @IBOutlet weak var doctorProfessionsTitle: UILabel!
    @IBOutlet weak var doctorName: UILabel!
    @IBOutlet weak var doctorProfessions: UILabel!
    @IBOutlet weak var subdivisionTitle: UILabel!
    @IBOutlet weak var subdivision: UILabel!
    @IBOutlet weak var adressButton: UIButton!
    @IBOutlet weak var appointmentTitle: UILabel!
    private let tapBackButton = PublishSubject<Void>()
    var selectTimeSlotDelegate:SelectTimeSlotOnDocTVCProtocol?
    
    var index = Int()
    var selectDate = BehaviorSubject<Date>(value: Date())
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    let paramDoctor = BehaviorSubject<ParamDoctor>(value: ParamDoctor(id: "", name: "", CenterId: "", SpecId: []))
    private let viewModel = TableViewDoctorViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.transform(TableViewDoctorViewModel.Input(doctorParametrs: paramDoctor, selectDate: selectDate, selectAdress: adressButton.rx.tap.asObservable(), tapBackButton: tapBackButton))
        createCalendar(output)
        contentDoctor(output)
        createCollection(output)
        showMap(output)
        createNavigation(output)
        pop(output)
     }
    
    private func pop(_ output:TableViewDoctorViewModel.Output) {
        output.popBack.drive(onNext: {[self]_ in
            navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func showMap(_ output:TableViewDoctorViewModel.Output) {
        output.coordinateData.drive(onNext:{[self] contentMap in
            let mapController  = storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
            mapController.coordinate.onNext(contentMap)
            show(mapController, sender: nil)
        }).disposed(by: disposeBag)
    }
    
    
    @IBAction func calendarScopeButtonAction(_ sender: Any) {
        switch calendar.scope {
        case .month :
            calendar.setScope(.week, animated: true)
            calendarScopeButton.setImage(UIImage(systemName: "arrow.down.left.square.fill"), for: .normal)
        case .week :
            calendar.setScope(.month, animated: true)
            calendarScopeButton.setImage(UIImage(systemName: "arrow.up.right.square.fill"), for: .normal)
        @unknown default:
            print("New calendar style!!!")
        }
        
        UIView.animate(withDuration: 0.5) {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }
    
    private func contentDoctor(_ output:TableViewDoctorViewModel.Output) {
        output.doctorData.drive(onNext:{ [self] doctorData in
            doctorName.rx.text.onNext(doctorData.name)
            doctorProfessions.rx.text.onNext(doctorData.professions)
            subdivision.rx.text.onNext(doctorData.subdivision)
            adressButton.rx.title().onNext(doctorData.subdivisionAdress)
            
            output.subdivisionText.drive(subdivisionTitle.rx.text).disposed(by: disposeBag)
            output.professionsText.drive(doctorProfessionsTitle.rx.text).disposed(by: disposeBag)
            output.singUpText.drive(appointmentTitle.rx.text).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
    }
    private func createCalendar(_ output:TableViewDoctorViewModel.Output) {
        calendar.delegate = self
        calendar.dataSource = self
        
        calendar.scope = .week
        calendar.appearance.borderRadius = 2
        calendar.firstWeekday = 2
        calendar.appearance.caseOptions = [.weekdayUsesUpperCase,.headerUsesCapitalized]
        calendar.appearance.selectionColor = .systemBlue
        
        output.localeKey.drive(onNext: {identifier in
            self.calendar.locale = Locale(identifier: identifier)
        }).disposed(by: disposeBag)
      
        
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    private func createCollection(_ output:TableViewDoctorViewModel.Output) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 90, height: 50)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionSlots.setCollectionViewLayout(layout, animated: true)
        collectionSlots.showsHorizontalScrollIndicator = false
        output.collectionData.drive(collectionSlots.rx.items(cellIdentifier: "DoctorTimeCellDoctor", cellType: DoctorTimeCell.self)) { [self] row , titleLabel , cell in
            cell.textLabel.text = titleLabel
            let isSelected = index == row
            cell.textLabel.backgroundColor = isSelected ? .systemBlue : #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.1698313328)
            cell.textLabel.textColor = isSelected ? .white : .systemBlue
        }.disposed(by: disposeBag)
        
        collectionSlots.rx.itemSelected.withLatestFrom(Observable.combineLatest(paramDoctor, collectionSlots.rx.itemSelected,selectDate)).subscribe(onNext: { [self] docData , indexPath ,date in
            index = indexPath.row
            collectionSlots.reloadData()
            selectTimeSlotDelegate?.selectSlot(docId: docData.id, rowSlot: indexPath.row)
        }).disposed(by: disposeBag)
        
    }
    private func createNavigation(_ output:TableViewDoctorViewModel.Output) {
        output.titleText.drive(rx.title).disposed(by: disposeBag)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: nil, action: nil)
        navigationItem.leftBarButtonItem?.rx.tap.subscribe(tapBackButton).disposed(by: disposeBag)
        
        
    }

}
extension TableViewDoctor : FSCalendarDelegate ,FSCalendarDataSource, FSCalendarDelegateAppearance
{
    
    func calendar (_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        // FSCalendar "display" completely first , and at a low height, a small cell size is burst
        calendarHeight.constant = bounds.height
        self.view.layoutIfNeeded()
        tableView.layoutSubviews()
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
    
    // select date
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        index = 0
        selectTimeSlotDelegate?.selectDateDocTVC(date: date)
        selectDate.onNext(date)
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        Date()
    }
    
}
