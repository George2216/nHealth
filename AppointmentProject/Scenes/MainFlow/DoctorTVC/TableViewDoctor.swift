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
import Foundation

final class TableViewDoctor: UITableViewController , Storyboarded {
    
    internal let nvContent = PublishSubject<Event>()
    @IBOutlet weak var doctorImage: UIImageView!
    private let disposeBag = DisposeBag()
    private let cellIdentifier = "CalendarCellIdentifier"
    private let timeCellIdentifier = "DoctorTimeCellDoctor"
    
    @IBOutlet weak var calendarScopeButton: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var collectionSlots: DynamicHeightCollectionView!
    
    @IBOutlet weak var localeTitle: UILabel!
    @IBOutlet weak var doctorName: UILabel!
    @IBOutlet weak var doctorProfessions: UILabel!

    @IBOutlet weak var adressButton: UIButton!
    @IBOutlet weak var appointmentTitle: UILabel!
   
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    internal let paramDoctor = BehaviorSubject<DoctorContent>(value: DoctorContent(id: "", name: "", professions: ""))
    
    private let tapImageGesture = UITapGestureRecognizer()
    private let tapImageEvent = PublishSubject<Void>()
    private let viewModel = TableViewDoctorViewModel()
    private let showRefresh = PublishSubject<Void>()
    private let tapBackButton = PublishSubject<Void>()
    private var selectDate = BehaviorSubject<Date>(value: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.transform(TableViewDoctorViewModel.Input(doctorParametrs: paramDoctor, selectDate: selectDate, selectAdress: adressButton.rx.tap.asObservable(), tapBackButton: tapBackButton, tapDoctorImage: tapImageEvent, selectSlot: collectionSlots.rx.itemSelected.map{$0.row}, showRefresh: showRefresh))
        

        createCalendar(output)
        contentDoctor(output)
        createCollection(output)
        showMap(output)
        createBackButton(output)
        pop(output)
        reloadTable(output)
        pushPagesDoctor(output)
        selectTimeSlot(output)
        createTapOnImage()
        refreshStates(output)
     }
   
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        nvContent.onNext(.finish)
    }
    
    private func refreshStates(_ output:TableViewDoctorViewModel.Output) {
        output.showRefresh.drive(onNext:{ [weak self] _ in
            guard let self = self else { return }
            self.nvContent.onNext(.showRefresh)
        }).disposed(by: disposeBag)
        
        output.hideRefresh.drive(onNext:{ [weak self] _ in
            guard let self = self else { return }
            self.nvContent.onNext(.hideRefresh)
        }).disposed(by: disposeBag)
    }
    
    private func createTapOnImage() {
        doctorImage.layer.borderWidth = 1
        doctorImage.layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.3)
        doctorImage.isUserInteractionEnabled = true
        doctorImage.addGestureRecognizer(tapImageGesture)
        
        tapImageGesture.rx.event.subscribe(onNext:{ _ in
//            self.tapImageEvent.onNext(())
            // not now
        }).disposed(by: disposeBag)
    }
    private func pushPagesDoctor(_ output:TableViewDoctorViewModel.Output) {
        output.pushPagesForId.drive(onNext:{ [weak self] idArray in
            guard let self = self else { return }

            self.nvContent.onNext(.fullScreenPhoto)
        }).disposed(by: disposeBag)
    }
    private func reloadTable(_ output:TableViewDoctorViewModel.Output) {
        output.reloadTable.drive(onNext: { [weak self]_ in
            guard let self = self else { return }
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {[weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }

                    self.tableView.reloadData()
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func pop(_ output:TableViewDoctorViewModel.Output) {
        output.popBack.drive(onNext: { [weak self]_ in
            guard let self = self else { return }

            self.nvContent.onNext(.tapBack)
        }).disposed(by: disposeBag)
    }
    
    private func showMap(_ output:TableViewDoctorViewModel.Output) {
        output.coordinateData.drive(onNext:{ [weak self] contentMap in
            guard let self = self else { return }

            self.nvContent.onNext(.showMap(content: contentMap))
        }).disposed(by: disposeBag)
    }
    
    
    @IBAction func calendarScopeButtonAction(_ sender: Any) {

        switch calendar.scope {
        case .month :
            calendar.setScope(.week, animated: true)
            calendarScopeButton.transform = .identity

        case .week :
            calendar.setScope(.month, animated: true)
            calendarScopeButton.transform =  CGAffineTransform(rotationAngle: (CGFloat(Double.pi)))

        @unknown default:
            print("New calendar style!!!")
        }
    }
    
    private func contentDoctor(_ output:TableViewDoctorViewModel.Output) {
        output.doctorData.drive(onNext:{ [weak self] doctorData in
            guard let self = self else { return }
            self.doctorName.rx.text.onNext(doctorData.name)
            self.doctorProfessions.rx.text.onNext(doctorData.professions)
            self.adressButton.rx.title().onNext(doctorData.subdivisionAdress)
        }).disposed(by: disposeBag)
        
        output.localeText.drive(onNext:{ [weak self] localeText in
            guard let self = self else { return }
            self.localeTitle.rx.text.onNext(localeText)
        }).disposed(by: disposeBag)
        
        output.singUpText.drive(onNext:{ [weak self] singUpText in
            guard let self = self else { return }
            self.appointmentTitle.rx.text.onNext(singUpText)
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
        
        output.localeKey.drive(onNext: { [weak self] identifier in
            guard let self = self else { return }
            self.calendar.locale = Locale(identifier: identifier)
        }).disposed(by: disposeBag)
      
        
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    private func createCollection(_ output:TableViewDoctorViewModel.Output) {
        
        let layout = CollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 90, height: 50)
        layout.scrollDirection = .vertical
        collectionSlots.setCollectionViewLayout(layout, animated: true)
        
        collectionSlots.showsHorizontalScrollIndicator = false
        
        output.collectionData.drive(collectionSlots.rx.items(cellIdentifier: timeCellIdentifier, cellType: DoctorTimeCell.self)) {  row , titleLabel , cell in
            cell.textLabel.text = titleLabel
            cell.textLabel.backgroundColor =  #colorLiteral(red: 0.9335836768, green: 0.9536595941, blue: 0.9832097888, alpha: 1)
            cell.textLabel.textColor =  #colorLiteral(red: 0.182285279, green: 0.4131350517, blue: 0.7902112007, alpha: 1)
        }.disposed(by: disposeBag)
        
        
    }
    private func selectTimeSlot(_ output:TableViewDoctorViewModel.Output) {
        output.appointmentContent.drive(onNext: { [weak self] appointmentContent in
            guard let self = self else { return }
            self.nvContent.onNext(.appointmentContent(appointmentContent))
            self.collectionSlots.reloadData()
        }).disposed(by: disposeBag)
        
    }
    
    private func createBackButton(_ output:TableViewDoctorViewModel.Output) {
        output.titleText.drive(onNext: { [weak self] titleText in
            guard let self = self else { return }
            self.nvContent.onNext(.titleText(titleText))
        }).disposed(by: disposeBag)
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: nil, action: nil)
        
        nvContent.onNext(.backButton(backButton))
        
        backButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.tapBackButton.onNext(())
        }).disposed(by: disposeBag)
        
    }
    
}
extension TableViewDoctor : FSCalendarDelegate ,FSCalendarDataSource, FSCalendarDelegateAppearance
{
    
    func calendar (_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        // FSCalendar "display" completely first , and at a low height, a small cell size is burst
        calendarHeight.constant = bounds.height
        tableView.reloadData()
    }
    
    // select date
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectDate.onNext(date)
        showRefresh.onNext(())
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        Date()
    }
   
}

extension TableViewDoctor {
    enum Event {
        case finish
        case fullScreenPhoto
        case showMap(content:CoordinateModel)
        case tapBack
        case backButton(_ button:UIBarButtonItem)
        case showRefresh
        case hideRefresh
        case titleText(_ title:String)
        case appointmentContent( _ model:AppointmentModel)

    }
}

