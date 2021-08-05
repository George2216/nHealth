//
//  InitialTableViewModel.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import Foundation
import RxCocoa
import RxSwift

extension InitialTableViewModel {
    private var filterDataDriver:Driver<[ModelFilterCell]> {
        return filterCellData.asDriver(onErrorJustReturn: [])
    }
    private  var presentCalendarFilterDriver:Driver<Void> {
        return presentCalendarFilter.asDriver(onErrorJustReturn: ())
    }
    private  var presentClinicFilterDriver:Driver<Void> {
        return presentClinicFilter.asDriver(onErrorJustReturn: ())
    }
   
    
    private var doctorDataCellDriver:Driver<[DoctorModelCell]> {
        return doctorDataCell.asDriver(onErrorJustReturn: [])
    }
    private  var filterDoctorDataDriver:Driver<[ParamDoctor]> {
        return filterDoctorData.map{$0.Doctor}.asDriver(onErrorJustReturn: [])
    }
    private var textDidBeginEditingDriver:Driver<Void> {
        return textDidBeginEditing.asDriver(onErrorJustReturn: ())
    }
    private var textDidEndEditingDriver:Driver<Void> {
        return textDidEndEditing.asDriver(onErrorJustReturn: ())
    }
    private  var cancelButtonClickedDriver:Driver<Void> {
        return cancelButtonClicked.asDriver(onErrorJustReturn: ())
    }
    
    // search doctor
    private var doctorTableDataDriver:Driver<[ParamDoctor]> {
        return doctorTableData.map{$0.Doctor}.asDriver(onErrorJustReturn: [])
    }
    private var selectDoctorDriver:Driver<ParamDoctor> {
        return selectDoctor.asDriver(onErrorJustReturn: ParamDoctor(id: "", name: "", CenterId: "", SpecId: []))
    }
    
    private var reloadTableDriver:Driver<Void> {
        return reloadTable.asDriver(onErrorJustReturn: ())
    }
    private var appointmentModelDriver:Driver<AppointmentModel> {
        return appointmentModel.asDriver(onErrorJustReturn: AppointmentModel())
    }
    private var titleSelf:Driver<String> {
        return Localizable.localize(.doctors).asDriver(onErrorJustReturn: "")
    }
  
   
    private var searchTableDataDriver:Driver<[ParamDoctor]> {
        return dataSearchTable.map{$0.Doctor}.asDriver(onErrorJustReturn: [])
    }
    private var canselButtonTitle:Driver<String> {
        return Localizable.localize(.close).asDriver(onErrorJustReturn: "")
    }
}

class InitialTableViewModel:ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private let reloadTable = PublishSubject<Void>()
    
        // search table data
    private let dataSearchTable = BehaviorSubject<DoctorsModel>(value: DoctorsModel(Doctor: []))
    // main cells data
    private let filterDoctorData = BehaviorSubject<DoctorsModel>(value: DoctorsModel(Doctor: []))
    // static doctor data
    private let doctorTableData = BehaviorSubject<DoctorsModel>(value: DoctorsModel(Doctor: []))
    
    private let selectDate = BehaviorSubject<Date>(value: Date())
    private let filterCellData = BehaviorSubject<[ModelFilterCell]>(value: [])
    
    private let doctorDataCell = BehaviorRelay<[DoctorModelCell]>(value: [])
    private let slotsData = BehaviorRelay<[[String]]>(value: [])
    private let presentCalendarFilter = PublishSubject<Void>()
    private let presentClinicFilter = PublishSubject<Void>()
    private let textDidBeginEditing = PublishSubject<Void>()
    private let textDidEndEditing = PublishSubject<Void>()
    private let cancelButtonClicked = PublishSubject<Void>()
    private let selectDoctor = PublishSubject<ParamDoctor>()
    private let allSlotsDataOnDay = BehaviorSubject<SlotsByDocDayModel>(value: SlotsByDocDayModel(Windows: []))
    private let appointmentModel = PublishSubject<AppointmentModel>()
    
    func transform(_ input: Input) -> Output {
        createFilterData(input)
        touchFilterCells(input)
        subscribeOnSearchVoids(input)
        selectDocAction(input)
        subscribeOnRefresh(input)
        filterTable(input)
        getAppointmentData(input)
        refreshTableView(input)
        filterSearchTable(input)
        
        return Output(cellData: filterDataDriver, presentCalendar: presentCalendarFilterDriver, presentClinic: presentClinicFilterDriver, doctorData: doctorDataCellDriver,textDidBeginEditing:textDidBeginEditingDriver,textDidEndEditing:textDidEndEditingDriver, cancelButtonClicked: cancelButtonClickedDriver, doctorTableData: doctorTableDataDriver, reloadTable: reloadTableDriver, selectDoctor: selectDoctorDriver, appointmentModel: appointmentModelDriver, searchBarPlaseholder: getSearchBarPlaseholder(), titleSelf: titleSelf, searchTableData: searchTableDataDriver, canselButtonTitle: canselButtonTitle)
    }
    private func filterSearchTable(_ input:Input) {
        input.searchBarText.withLatestFrom(Observable.combineLatest(input.searchBarText, doctorTableData)).subscribe(onNext: {[self] searchText , searchContent in
            
            guard !searchText.isEmpty else {
                self.dataSearchTable.onNext(searchContent)
                return
            }
            
           let newContent =  searchContent.Doctor.filter {  doctor in
                return doctor.name.localizedLowercase.contains(searchText.localizedLowercase)
            }
            self.dataSearchTable.onNext(DoctorsModel(Doctor: newContent))
            
        }).disposed(by: disposeBag)
    }
    private func getSearchBarPlaseholder() -> Driver<String>{
        return Localizable.localize(.doctorName).asDriver(onErrorJustReturn: "")
    }
    private func subscribeOnRefresh(_ input:Input) {
        input.refreshControl.subscribe(reloadTable).disposed(by: disposeBag)
    }
    private func touchFilterCells(_ input:Input) {
        input.indexSelectFilterCell.withLatestFrom(Observable.combineLatest(input.indexSelectFilterCell, doctorTableData)).subscribe(onNext: {[self] row , docData in
            switch row {
            case 0 : presentCalendarFilter.onNext(())
            case 1 : presentClinicFilter.onNext(())
            case 2 : filterDoctorData.onNext(docData)
            default:break
            }
        }).disposed(by: disposeBag)
    }
    
    private func createFilterData(_ input:Input) {
        getSelfTableData()
        
        Observable.combineLatest(Localizable.localize(.clear), Localizable.localize(.filters),selectDate)
            .flatMapLatest({ clear , filters , date -> Observable<[ModelFilterCell]> in
                return  Observable<[ModelFilterCell]>.just([ModelFilterCell(text: date.stringDF(), systemImageName: "calendar"),ModelFilterCell(text: filters, systemImageName: "slider.horizontal.3"),ModelFilterCell(text: clear, systemImageName: "xmark")])
        }).subscribe(filterCellData).disposed(by: disposeBag)
            
        
        input.selectDate.withLatestFrom(Observable.combineLatest(input.selectDate, filterCellData)).subscribe(onNext: { date , dataFilter in
            var dataFilterLoc = dataFilter
            dataFilterLoc[0].text = date.stringDF()
            self.filterCellData.onNext(dataFilter)
        }).disposed(by: disposeBag)
        
        
       
        input.selectDate.subscribe(onNext: { [self]
            date in
            selectDate.onNext(date)
        }).disposed(by: disposeBag)
    }
    
    private func getSelfTableData() {
        
        let getDoctorsManager = XMLMultiCoder<DoctorsModel>()
        let value = InputModelDoctors(Token: "EEF4B03D-C023", CenterId: "1")
            getDoctorsManager.parsData(input: value, metod: .POST, phpFunc: .DoctorList, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil)).asObservable()
                .subscribe(onNext: { [self] doctors , _  in
                filterDoctorData.onNext(doctors ?? DoctorsModel(Doctor: []))
                doctorTableData.onNext(doctors ?? DoctorsModel(Doctor: []))
                dataSearchTable.onNext(doctors ?? DoctorsModel(Doctor: []))
            }).disposed(by: disposeBag)
    }
    
    private func createTableData() {
        let apiManager = XMLMultiCoder<SlotsByDocDayModel>()
        Observable.combineLatest(selectDate, filterDoctorData)
            .subscribe(onNext:{ [self] date , doctorData in
        
            let doctors = doctorData.Doctor
            let dateSTR = date.stringDateSpase()
            var doctorsCellData:[DoctorModelCell] = []
            var allWindows = [WindowsModel]()
            for (index , value) in doctors.enumerated() {
                
                let apiInput = InputModelSlots(Token: "EEF4B03D-C023", CenterId: value.CenterId, Date: dateSTR, DoctorId: value.id, Duration: "30")
               apiManager.parsData(input: apiInput, metod: .POST, phpFunc: .SlotsByDocDay, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil))
                .concatMap({ [self] model , _  -> Observable<()> in

                    var arraySlots:[String] = []
                    let specString = doctors[index].SpecId.map{$0.name}.joined(separator: ", ")
                    
                    guard model?.Windows.count != 0  else { return Observable<()>.just(())}
                    let window = model!.Windows[0].Window
                    for slot in window {
                        
                        arraySlots.append(slot.Start.cutString(from: 11, to: 15))
                    }
                allWindows.append(model!.Windows[0])

                guard let subdivision:CentersListModel = SingletonData.shared.getCentersListData() else {
                        return Observable<()>.just(())
                    }
                    
                    
                    var nameCenter = ""
                    subdivision.Center.forEach { model in
                        if model.id == doctors[index].CenterId {
                            nameCenter = model.name
                        }
                    }
                

                    let doctorCellData = DoctorModelCell(docId: doctors[index].id, name: doctors[index].name, subdivision: nameCenter, profession: specString, arrayCollection: arraySlots)
                    
                    
                doctorsCellData.append(doctorCellData)
                    
                    print(doctorsCellData)
                    print(doctorData.Doctor[index])
                    
                self.doctorDataCell.accept(doctorsCellData)
              
                    
                DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
                    self.reloadTable.onNext(())
                        }
                
                allSlotsDataOnDay.onNext(SlotsByDocDayModel(Windows: allWindows))

                    return Observable<()>.just(())
                    
                }).subscribe().disposed(by: disposeBag)
                

                

        }
            
    }).disposed(by: disposeBag)
}
    private func getCenterList() {
        let apiManager = XMLMultiCoder<CentersListModel>()
        let inputData = InputModelCentersList(Token: "EEF4B03D-C023")
        guard UserDefaults.standard.value(forKey: UDKeys.Subdivisions.rawValue) == nil else {
            return
        }
        
        apiManager.parsData(input: inputData, metod: .POST, phpFunc: .CenterList, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil)).asObservable().subscribe(onNext: { centerList , _ in
            
            // save on data format
            guard  let centerList = centerList else { return }
            guard let centersDataFormat =  getDataFromPacket(packet: centerList) else { return }
            
            UserDefaults.standard.setValue(centersDataFormat, forKey: UDKeys.Subdivisions.rawValue)
            
        }).disposed(by: disposeBag)
    }
    
    private func subscribeOnSearchVoids(_ input:Input) {
        input.textDidEndEditing.bind(to: textDidEndEditing).disposed(by: disposeBag)
        input.textDidBeginEditing.bind(to: textDidBeginEditing).disposed(by: disposeBag)
        input.cancelButtonClicked.bind(to: cancelButtonClicked).disposed(by: disposeBag)
    }
    
    private func getStartDataFilterData(_ input:Input) -> [ModelFilterCell] {
        var modelArray:[ModelFilterCell] = []
        Observable.combineLatest(Localizable.localize(.clear), Localizable.localize(.filters),selectDate).subscribe(onNext: {
            clear , filters , date in
        modelArray = [ModelFilterCell(text: date.stringDF(), systemImageName: "calendar"),ModelFilterCell(text: filters, systemImageName: "slider.horizontal.3"),ModelFilterCell(text: clear, systemImageName: "xmark")]
            
        }).disposed(by: disposeBag)
        
        return modelArray
    }
    
    private func selectDocAction(_ input:Input) {
        input.selectDoctorId.withLatestFrom(Observable.combineLatest(filterDoctorData, input.selectDoctorId)).subscribe(onNext: { [self] doctors , id in
          
            for doctor in doctors.Doctor {
                if doctor.id == id {
                    selectDoctor.onNext(doctor)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func filterTable(_ input:Input) {
        input.filterData.withLatestFrom(Observable.combineLatest(input.filterData, doctorTableData)).subscribe(onNext: { [self]filteData , contentTable in
            
            if filteData.professions.count == 0 {
                doctorDataCell.accept([])
            }
           
            
            let newTable = contentTable.Doctor.filter { doc in
                if doc.CenterId == filteData.clinicId {
                    let boolArray = doc.SpecId.map {filteData.professions.contains($0.value)}
                    if boolArray.contains(where: {$0 == true}) {
                        return true

                    } else {
                        doctorDataCell.accept([])
                        return false
                        }
                    }
                return false
            }
            if newTable.count == 0 {
                doctorDataCell.accept([])
            }
            
            
            let newFilterDocData:DoctorsModel = DoctorsModel(Doctor: newTable)
        
            filterDoctorData.onNext(newFilterDocData)
            
        }).disposed(by: disposeBag)
    }
    
    private func getAppointmentData(_ input:Input) {
        input.selectTimeSlot.withLatestFrom(Observable.combineLatest(input.selectTimeSlot, filterDoctorData,allSlotsDataOnDay)).subscribe(onNext:{ [self] indices , docData  , windowsData  in

            // doctors don't always go in order
            let docId = indices.docId
            
            var doctor = ParamDoctor(id: "", name: "", CenterId: "", SpecId: [])
            
            if let index =  docData.Doctor.map({$0.id}).firstIndex(of: docId) {
                doctor = docData.Doctor[index]
            }
        
            var window:WindowsModel? = nil
            var centerContent:AppointmentCenter? = nil
            
            windowsData.Windows.forEach { model  in
                if  model.DoctorId == doctor.id {
                    window = model
                    return
                }
            }
            
            if let subdivisionsData = UserDefaults().data(forKey: UDKeys.Subdivisions.rawValue) {
                guard let subdivision:CentersListModel = getPacketFromData(data: subdivisionsData) else {
                    return
                }
                subdivision.Center.forEach { center in
                    if center.id == doctor.CenterId {
                        centerContent = AppointmentCenter(id: center.id , latitude: center.latitude, longitude: center.longitude, name: center.name, city: center.city, adress: center.address)
                        return
                    }
                }
            }
            let professions = doctor.SpecId.map{$0.name}.joined(separator: ", ")
            
            let docModel = AppointmentDoctor(id: doctor.id, name: doctor.name, professions: professions)
            let centerModel = centerContent!
            
            let appointmentTime = AppointmentTime(time: window?.Window[indices.indexSlot].Start ?? "", roomId: window?.Window[indices.indexSlot].RoomId ?? "" )
            let appointmentContent = AppointmentModel(doctor: docModel, appointmentLockation: centerModel, appointmentTime: appointmentTime)
            appointmentModel.onNext(appointmentContent)
            
        }).disposed(by: disposeBag)
    }
    
    private func refreshTableView(_ input:Input) {
        input.refreshTableView.subscribe(onNext:{ [self] _ in
            do {
                let date = try? selectDate.value()
                selectDate.onNext(date ?? Date())
            }
        }).disposed(by: disposeBag)
      
    }
    
    init() {
        getCenterList()
        createTableData()
    }
    
    struct Input {
        let indexSelectFilterCell:Observable<Int>
        let selectDate:Observable<Date>
        let textDidBeginEditing:Observable<Void>
        let textDidEndEditing:Observable<Void>
        let cancelButtonClicked:Observable<Void>
        let selectDoctorId:Observable<String>
        let refreshControl:Observable<Void>
        let filterData:Observable<(clinicId:String,professions:[String])>
        let selectTimeSlot:Observable<(docId:String,indexSlot:Int)>
        let refreshTableView:Observable<Void>
        let searchBarText:Observable<String>
    }
    
    struct Output {
        let cellData:Driver<[ModelFilterCell]>
        let presentCalendar:Driver<Void>
        let presentClinic:Driver<Void>
        let doctorData:Driver<[DoctorModelCell]>
        let textDidBeginEditing:Driver<Void>
        let textDidEndEditing:Driver<Void>
        let cancelButtonClicked:Driver<Void>
        let doctorTableData:Driver<[ParamDoctor]>
        let reloadTable:Driver<Void>
        let selectDoctor:Driver<ParamDoctor>
        let appointmentModel:Driver<AppointmentModel>
        let searchBarPlaseholder:Driver<String>
        let titleSelf:Driver<String>
        let searchTableData:Driver<[ParamDoctor]>
        let canselButtonTitle:Driver<String>
    }
    
}


