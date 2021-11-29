//
//  NewInitialViewModel.swift
//  AppointmentProject
//
//  Created by George on 16.08.2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum InitialTableSectionType {
    case defaultSection(header:String,footer:String)
    var headerFooter:(header:String,footer:String) {
        switch self {
        case .defaultSection(let header, let footer):
            return (header,footer)
        }
    }
}

enum InitialTableItem {
    case defaultItem(_ model:DoctorModelCell)
}

typealias InitialTableSection = SectionModel<InitialTableSectionType,InitialTableItem>



final class InitialTableViewModel: ViewModelProtocol {
    private var items = BehaviorSubject<[InitialTableSection]>(value: [])
    private var fullItemsData = BehaviorSubject<[FullItemsDataModel]>(value:[])
    
    private let presentCalendarFilter = PublishSubject<Void>()
    private let presentClinicFilter = PublishSubject<Void>()
    private let textDidBeginEditing = PublishSubject<Void>()
    private let textDidEndEditing = PublishSubject<Void>()
    private let cancelButtonClicked = PublishSubject<Void>()
    private let selectDoctor = PublishSubject<DoctorContent>()
    private let reloadTable = PublishSubject<Void>()

    private let filterCellData = BehaviorSubject<[ModelFilterCell]>(value: [])
    private let subdivisionId = BehaviorSubject<String>(value: "")
    private let filterData = BehaviorSubject<FilterType>(value: .none)
    private let disposeBag = DisposeBag()
    private let selectedDate = BehaviorSubject<Date>(value: Date())
    private let doctorsList = BehaviorSubject<[ParamDoctor]>(value: [])
    private let doctorItem = PublishRelay<ParamDoctor>()
    private let validWindows = BehaviorSubject<[WindowsModel]>(value: [])
    private let newWindows = PublishSubject<WindowsModel>()
    private let doctorDataCell = BehaviorRelay<[DoctorModelCell]>(value: [])
    private let appointmentModel = PublishSubject<AppointmentModel>()
    private let dataSearchTable = BehaviorSubject<DoctorsModel>(value: DoctorsModel(Doctor: []))

    
    func transform(_ input: Input) -> Output {
        
        subscribeOnFilter(input)
        touchFilterCells(input)
        subscribeOnRefresh(input)
        input.selectedDate.subscribe(selectedDate).disposed(by: disposeBag)
        createFilterCollectionData(input)
        subscribeOnSearchVoids(input)
        filterSearchTable(input)
        selectDocAction(input)
        subscribeOnSelectedSlot(input)
        subscribeOnSelectSearchDoc(input)
        
        return Output(tableContentData: tableContentDataDriver,cellData:filterDataDriver,presentCalendar:presentCalendarFilterDriver,presentClinic:presentClinicFilterDriver,textDidBeginEditing:textDidBeginEditingDriver,textDidEndEditing:textDidEndEditingDriver,cancelButtonClicked:cancelButtonClickedDriver,reloadTable:reloadTableDriver,selectDoctor:selectDoctorDriver,appointmentModel:appointmentModelDriver,searchBarPlaceholder:searchBarPlaceholderDriver,titleSelf:titleSelf,searchTableData:searchTableDataDriver,canselButtonTitle:canselButtonTitle,subdivisionId:subdivisionIdDriver, tableItems: itemsDriver)
    }
    private func reloadTableFromNotificationCenter() {
        NotificationCenter.default.rx.notification(.reloadInitialVCData, object: nil).subscribe(onNext: {[weak self]
            notification in
            guard let self = self else { return }
            if notification.name == .reloadInitialVCData {
                self.selectedDate.onNext(Date())
            }
        }).disposed(by: disposeBag)

    }
    
    private func subscribeOnRefresh(_ input:Input) {
    
        input.refreshControl.withLatestFrom(selectedDate).subscribe(selectedDate).disposed(by: disposeBag)
        input.refreshTableView.withLatestFrom(selectedDate).subscribe(selectedDate).disposed(by: disposeBag)
    }
    private func createFilterCollectionData(_ input:Input) {
        Observable.combineLatest(Localizable.localize(.clear), Localizable.localize(.filters),selectedDate)
            .flatMapLatest({ clear , filters , date -> Observable<[ModelFilterCell]> in
                return  Observable<[ModelFilterCell]>.just([ModelFilterCell(text: date.stringDF(), systemImageName: "calendar"),ModelFilterCell(text: filters, systemImageName: "slider.horizontal.3"),ModelFilterCell(text: clear, systemImageName: "xmark")])
        }).subscribe(filterCellData).disposed(by: disposeBag)
    }
    private func touchFilterCells(_ input:Input) {
        
        input.indexSelectFilterCell.withLatestFrom(Observable.combineLatest(input.indexSelectFilterCell, filterData)).subscribe(onNext: {[weak self] row , filter in
            guard let self = self else { return }

            switch row {
            case 0 : self.presentCalendarFilter.onNext(())
            case 1 : self.presentClinicFilter.onNext(())
            case 2 : self.filterData.onNext(.none)
            default:break
            }
        }).disposed(by: disposeBag)
    }
    
    private func subscribeOnFilter(_ input:Input) {
        input.filterData.subscribe(onNext: {[weak self] filterContent in
            guard let self = self else { return }

            self.filterData.onNext(.active(clinicId: filterContent.clinicId, professions: filterContent.professions))
        }).disposed(by: disposeBag)
    }
    
    private func getDoctors() {
        Observable.combineLatest(selectedDate, filterData,subdivisionId)
            .flatMapLatest { [weak self] date , _ ,subdivisionId -> Observable<DoctorsModel> in
                guard let self = self else { return .just(DoctorsModel(Doctor: []))}

                self.validWindows.onNext([])
            let getDoctorsManager = XMLMultiCoder<DoctorsModel>()
            let  inputCenterId = subdivisionId
            

            let value = InputModelDoctors(Token: SingletonData.shared.token, CenterId: inputCenterId)
            
            return  getDoctorsManager.parsData(input: value, metod: .POST, phpFunc: .DoctorList, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil)).map {$0.0 ?? DoctorsModel(Doctor: [])
            }
        }.subscribe(onNext: { [self] doctorsModel in
                doctorsList.onNext(doctorsModel.Doctor)
        }).disposed(by: disposeBag)
    }
    
    private func additingLoadingDoctors() {
        
        doctorsList.withLatestFrom(Observable.combineLatest(doctorsList, filterData))
            .subscribe(onNext: {[weak self] doctorsArray , filter  in
                
            guard let self = self else { return }
            for doctor in doctorsArray {

                switch filter {
                case .none:
                    self.doctorItem.accept(doctor)
                case .active(clinicId: let clinicId, professions: let professionsID):
                    // sorted
                    if clinicId == doctor.CenterId {
                        let docSpecArray = doctor.SpecId.map{$0.value}
                        
                        if professionsID.isHaveEqual(array: docSpecArray) {
                            DispatchQueue.global().sync {
                                
                            
                                self.doctorItem.accept(doctor)

                            }
                        }
                    }
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func getDoctorSlots() {
        
        doctorItem.withLatestFrom(Observable.combineLatest(doctorItem, selectedDate))
            .flatMap { doctor , date  ->         Observable<(SlotsByDocDayModel?,String?)>  in
            let apiManager = XMLMultiCoder<SlotsByDocDayModel>()
            let dateSTR = date.stringDateSpase()
            let apiInput = InputModelSlots(Token: SingletonData.shared.token, CenterId: doctor.CenterId, Date: dateSTR, DoctorId: doctor.id, Duration: "30")
           return apiManager.parsData(input: apiInput, metod: .POST, phpFunc: .SlotsByDocDay, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil))
                
            }.subscribe(onNext: { [weak self] windows , _  in
                guard let self = self else { return }
                if windows != nil , !(windows?.Windows.isEmpty)! , !windows!.Windows[0].Window.isEmpty {
                    let windows = windows!.Windows[0]
                    let filterWindows =  windows.Window.filter { item in
                    let time = item.Start.changeSymbol("T", on: " ").fullDateSpase() ?? Date()
                        return time > Date()
                    }
                    guard !filterWindows.isEmpty else { return }
                    
                    self.newWindows.onNext(WindowsModel(name: windows.name, DoctorName: windows.DoctorName, DoctorId: windows.DoctorId, Date: windows.Date, Window: filterWindows))
                }
            }).disposed(by: disposeBag)
    }
    
    
    private func addSlotsToList(){
        newWindows.withLatestFrom(Observable.combineLatest(newWindows, validWindows))
            .subscribe(onNext: { [weak self] newWindows , validWindows in
                guard let self = self else { return }
                var newArrayValidWindows = validWindows
                newArrayValidWindows.append(newWindows)

                self.validWindows.onNext(newArrayValidWindows)
        }).disposed(by: disposeBag)
    }
    
    private func combineMainCellsData() {
        validWindows.withLatestFrom(Observable.combineLatest(validWindows,doctorsList))
                .subscribe(onNext: { [weak self] windows ,doctorsList in
                    
            guard let self = self else { return }

            guard let _ :CentersListModel = SingletonData.shared.getCentersListData() else { return }

            var newContent:[FullItemsDataModel] = []
                    
            for window in windows {
                
            let doctorId = window.DoctorId
            let filterDoc = doctorsList.filter{ $0.id == doctorId }
                
            guard !filterDoc.isEmpty else { return }
                let doc = filterDoc[0]
                
                let myWindows = window.Window.map { item -> WindowItem in
                    return WindowItem(fullTime: item.Start, roomId: item.RoomId)
                }
                
                newContent.append(FullItemsDataModel(doctorId: doctorId, doctorName: doc.name, professions: doc.SpecId.map{ $0.name }.joined(separator: ", "), windows: myWindows))
                
            }
            self.fullItemsData.onNext(newContent)

        }).disposed(by: disposeBag)
    }
    
    private func createCellData() {
        fullItemsData.subscribe(onNext: {[weak self] fullData in
            
        guard let self = self else { return }
            
           let itemsData =  fullData.map { item -> InitialTableSection in
                let windows = item.windows.map{ timeModel -> TimeSlotModel in
                    TimeSlotModel(time: timeModel.fullTime.cutString(from: "T").cutString(to:5))
                }
                
                
                let item =  DoctorModelCell(docId: item.doctorId, name: item.doctorName,  profession: item.professions, arrayCollection: windows)
               
                    return InitialTableSection(model: .defaultSection(header: "", footer: ""), items: [.defaultItem(item)])
            }

            self.items.onNext(itemsData)
            self.reloadTable.onNext(())

        }).disposed(by: disposeBag)
    }
    
    private func getSubdvisionId() {
            guard let subdivision = CentersListModel.getData(for: .Subdivisions) else {
                return
            }
            if !subdivision.Center.isEmpty {
                subdivisionId.onNext(subdivision.Center[0].id)
            }
    }
    
    private func subscribeOnSearchVoids(_ input:Input) {
        input.textDidEndEditing.bind(to: textDidEndEditing).disposed(by: disposeBag)
        input.textDidBeginEditing.bind(to: textDidBeginEditing).disposed(by: disposeBag)
        input.cancelButtonClicked.bind(to: cancelButtonClicked).disposed(by: disposeBag)
    }
    
    private func filterSearchTable(_ input:Input) {
        // default search table content
        doctorsList.subscribe(onNext: {docsArray in
            self.dataSearchTable.onNext(DoctorsModel(Doctor: docsArray))
        }).disposed(by: disposeBag)
        
        input.searchBarText.withLatestFrom(Observable.combineLatest(input.searchBarText, doctorsList)).subscribe(onNext: {[self] searchText , searchContent in
            
            guard !searchText.isEmpty else {
                self.dataSearchTable.onNext(DoctorsModel(Doctor: searchContent))
                return
            }
            
           let newContent = searchContent.filter {  doctor in
                return doctor.name.localizedLowercase.contains(searchText.localizedLowercase)
            }
            self.dataSearchTable.onNext(DoctorsModel(Doctor: newContent))
            
        }).disposed(by: disposeBag)
    }
    
    
    
    private func selectDocAction(_ input:Input) {
        input.selectedDoctorIndex.withLatestFrom(Observable.combineLatest(input.selectedDoctorIndex, fullItemsData)).subscribe(onNext: { [weak self] index , data in
            guard let self = self else { return }
            let doctor = data[index]
            self.selectDoctor.onNext(DoctorContent(id: doctor.doctorId, name: doctor.doctorName, professions: doctor.professions))
        }).disposed(by: disposeBag)
    }
    
    private func subscribeOnSelectSearchDoc(_ input:Input) {
        input.selectedDoctorFromSearch.withLatestFrom(Observable.combineLatest(input.selectedDoctorFromSearch,doctorsList)).subscribe(onNext:{[weak self] index , list in
            guard let self = self else { return }
            let doctor = list[index]
            let professions = doctor.SpecId.map{ $0.name }.joined(separator: ", ")
            self.selectDoctor.onNext(DoctorContent(id: doctor.id , name: doctor.name, professions: professions))

        }).disposed(by: disposeBag)
        
    }
   
    
    private func subscribeOnSelectedSlot(_ input:Input) {
        input.selectedSlot
            .withLatestFrom(Observable.combineLatest(input.selectedSlot,fullItemsData))
                .subscribe(onNext: { [weak self] selectedInfo , fullData  in
            guard let self = self else { return }
            
            let doctorData = fullData[selectedInfo.indexPathDoc.section]
                    
            guard let subdivisions = CentersListModel.getData(for: .Subdivisions) , !subdivisions.Center.isEmpty else { return }
                    
            let subdivision = subdivisions.Center[0]
            let window = doctorData.windows[selectedInfo.indexSlot]
                    
            let appointmenData = AppointmentModel(doctor: AppointmentDoctor(id: doctorData.doctorId, name: doctorData.doctorName, professions: doctorData.professions), appointmentLockation: AppointmentCenter(id: subdivision.id, latitude: subdivision.latitude, longitude: subdivision.longitude, name: subdivision.name, city: subdivision.city, adress: subdivision.address), appointmentTime: AppointmentTime(time: window.fullTime, roomId: window.roomId))
                    
                self.appointmentModel.onNext(appointmenData)
                    
        }).disposed(by: disposeBag)
    }
    
    init() {
        getDoctors()
        additingLoadingDoctors()
        getDoctorSlots()
        combineMainCellsData()
        addSlotsToList()
        getSubdvisionId()
        createCellData()
        reloadTableFromNotificationCenter()
    }
    
    struct Input {
        let indexSelectFilterCell:Observable<Int>
        let selectedDate:Observable<Date>
        let textDidBeginEditing:Observable<Void>
        let textDidEndEditing:Observable<Void>
        let cancelButtonClicked:Observable<Void>
        let selectedDoctorIndex:Observable<Int>
        let refreshControl:Observable<Void>
        let filterData:Observable<(clinicId:String,professions:[String])>
        let refreshTableView:Observable<Void>
        let searchBarText:Observable<String>
        let selectedSlot:Observable<SelectedTimeSlotModel>
        let selectedDoctorFromSearch:Observable<Int>
    }
    
    struct Output {
        let tableContentData:Driver<[DoctorModelCell]>
        let cellData:Driver<[ModelFilterCell]>
        let presentCalendar:Driver<Void>
        let presentClinic:Driver<Void>
        let textDidBeginEditing:Driver<Void>
        let textDidEndEditing:Driver<Void>
        let cancelButtonClicked:Driver<Void>
        let reloadTable:Driver<Void>
        let selectDoctor:Driver<DoctorContent>
        let appointmentModel:Driver<AppointmentModel>
        let searchBarPlaceholder:Driver<String>
        let titleSelf:Driver<String>
        let searchTableData:Driver<[ParamDoctor]>
        let canselButtonTitle:Driver<String>
        let subdivisionId:Driver<String>
        let tableItems:Driver<[InitialTableSection]>
    }
    
    enum FilterType {
        case none
        case active(clinicId:String,professions:[String])
    }
}



extension InitialTableViewModel {
    private var itemsDriver:Driver<[InitialTableSection]> {
        items.asDriverOnErrorJustComplete()
    }
    private var tableContentDataDriver:Driver<[DoctorModelCell]> {
        return doctorDataCell.asDriverOnErrorJustComplete()
    }
    private  var presentCalendarFilterDriver:Driver<Void> {
        return presentCalendarFilter.asDriverOnErrorJustComplete()
    }
    private  var presentClinicFilterDriver:Driver<Void> {
        return presentClinicFilter.asDriverOnErrorJustComplete()
    }
    
    private var filterDataDriver:Driver<[ModelFilterCell]> {
        return filterCellData.asDriverOnErrorJustComplete()
    }
    private var textDidBeginEditingDriver:Driver<Void> {
        return textDidBeginEditing.asDriverOnErrorJustComplete()
    }
    private var textDidEndEditingDriver:Driver<Void> {
        return textDidEndEditing.asDriverOnErrorJustComplete()
    }
    private  var cancelButtonClickedDriver:Driver<Void> {
        return cancelButtonClicked.asDriverOnErrorJustComplete()
    }
    
    // search doctor
   
    private var reloadTableDriver:Driver<Void> {
        return reloadTable.asDriverOnErrorJustComplete()
    }
    private var selectDoctorDriver:Driver<DoctorContent> {
        return selectDoctor.asDriverOnErrorJustComplete()
    }
    private var appointmentModelDriver:Driver<AppointmentModel> {
        return appointmentModel.asDriverOnErrorJustComplete()
    }
    private var searchBarPlaceholderDriver:Driver<String> {
        return Localizable.localize(.doctorName).asDriverOnErrorJustComplete()
    }
    private var titleSelf:Driver<String> {
        return Localizable.localize(.doctors).asDriverOnErrorJustComplete()
    }
    private var searchTableDataDriver:Driver<[ParamDoctor]> {
        return dataSearchTable.map{$0.Doctor}.asDriverOnErrorJustComplete()
    }
    private var canselButtonTitle:Driver<String> {
        return Localizable.localize(.close).asDriverOnErrorJustComplete()
    }
    private var subdivisionIdDriver:Driver<String> {
        return subdivisionId.asDriverOnErrorJustComplete()
    }
}


struct FullItemsDataModel {
    let doctorId:String
    let doctorName:String
    let professions:String
    let windows:[WindowItem]
    
    
}
struct WindowItem {
    let fullTime:String
    let roomId:String
}
