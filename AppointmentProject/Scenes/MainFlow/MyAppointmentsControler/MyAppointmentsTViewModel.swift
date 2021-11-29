//
//  MyAppointmentsTViewModel.swift
//  AppointmentProject
//
//  Created by George on 31.07.2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import EventKit

enum MyAppointmentSectionType {
    case defaultSection(header:String,footer:String)
    var headerFooter:(header:String,footer:String) {
        switch self {
        case .defaultSection(let header, let footer):
            return (header,footer)
        }
    }
}
enum MyAppointmentItem {
    case myAppointmentModel(info:ModelAppointmentCell)
}

typealias MyAppointmentSection = SectionModel<MyAppointmentSectionType,MyAppointmentItem>

 extension MyAppointmentsTViewModel {
    
    private var myAppointmentsTitleDriver:Driver<String> {
        return Localizable.localize(.appointments).asDriverOnErrorJustComplete()
    }
    private var itemsDriver:Driver<[MyAppointmentSection]> {
        return items.asDriverOnErrorJustComplete()
    }
    private var presentMenuOnDriver:Driver<(CGRect,CGSize)> {
        return presentMenuOn.asDriverOnErrorJustComplete()
    }
    private var historyTitleDriver:Driver<String> {
        return Localizable.localize(.history).asDriverOnErrorJustComplete()
    }
    private var selectDocDriver:Driver<DoctorContent> {
        return selectDoctor.asDriverOnErrorJustComplete()
    }
    private var presentReloadIndicatorDriver:Driver<Void> {
        return presentReloadIndicator.asDriverOnErrorJustComplete()
    }
    private var dismissReloadIndicatorDriver:Driver<Void> {
        return dismissReloadIndicator.asDriverOnErrorJustComplete()
    }
    
}
final class MyAppointmentsTViewModel: ViewModelProtocol {
    private let indexSelectedCell = BehaviorSubject<IndexPath>(value: IndexPath())
    private let presentMenuOn = PublishSubject<(CGRect,CGSize)>()
    private let disposeBag = DisposeBag()
    private let items = BehaviorSubject<[MyAppointmentSection]>(value: [])
    private let goToDoctor = PublishSubject<Void>()
    private let cancelAppointment = PublishSubject<(centerId:String,appointmentId:String,inputData:InputCancelAppointmentModel)>()
    private let selectedGoToDocotor = PublishSubject<DoctorContent>()
    private let presentReloadIndicator = PublishSubject<Void>()
    private let dismissReloadIndicator = PublishSubject<Void>()
    private let selectDoctor = PublishSubject<DoctorContent>()
    private let sendPush = PublishSubject<NotificationPush>()
    func transform(_ input: Input) -> Output {
        input.refreshContent.subscribe(onNext:getTableData).disposed(by: disposeBag)
        menuPosition(input)
        actionsAppointments(input)
        
        return Output(myAppointmentsTitle: myAppointmentsTitleDriver, contentTable: itemsDriver, presentMenuOn: presentMenuOnDriver, historyTitle: historyTitleDriver, selectDoc: selectDocDriver,showReloadIndicator:presentReloadIndicatorDriver, hideReloadIndicator: dismissReloadIndicatorDriver)
    }
    
  
    private func getTableData() {
        if let appointments = MyAppointmentsModel.getData(for: .appointments) {
            Localizable.languageKey().subscribe(onNext: { [weak self] languageKey in
                guard let self = self else { return }
                
               let filterAppontments =  appointments.myAppoints.filter{$0.token == SingletonData.shared.token }
                
                var headers:[String] = []
                let contentTable = filterAppontments
                    .sorted { firstModel , secondModel in
                        
                        let firstDate  = firstModel.time.changeSymbol(",",on:" ").fullDateSpase() ?? Date()
                        let secondDate = secondModel.time.changeSymbol(",",on:" ").fullDateSpase() ?? Date()
                    
                    return firstDate < secondDate
                        
                        }
                    .map { content -> MyAppointmentSection in
                        let appointmentDataSTR = content.time.cutString(from: 0, to: 9)
                        
                        let headerMonth = appointmentDataSTR.dateSpase()?.monthAsString(languageKey) ?? ""
                           
                        let numberDay = appointmentDataSTR.dateSpase()?.getDateComponents(component: .day)  ?? 0
                        
                        let year = appointmentDataSTR.dateSpase()?.getDateComponents(component: .year) ?? 0
                           
                        var header = "\(numberDay) \(headerMonth) \(year)"
                        
                        if headers.contains(header) {
                                header = ""
                        }
                        
                        headers.append(header)
                        print(content.time.changeSymbol(",",on:" "))

                       let appointmentDate = (content.time.changeSymbol(",",on:" ") + ":00")
                            .fullDateSpase()!
                       let contentCell = ModelAppointmentCell(subdivision: content.subdivision, doctorName: content.name, doctorProfession: content.professions, appointmentID: content.appointmentId, centerId: content.centerId, docId: content.docId, isActive: appointmentDate > Date())
                       
                       let footer = content.time.cutString(from: 11, to: 15)
                       
                   return MyAppointmentSection(model: .defaultSection(header: header, footer:footer), items: [.myAppointmentModel(info: contentCell)])
                    }
                
                self.items.onNext(contentTable)
            }).disposed(by: disposeBag)

        } else {
            items.onNext([])

        }
       
    }
    private func actionsAppointments(_ input: Input) {
        input.selectAction.withLatestFrom(Observable.combineLatest(items, indexSelectedCell, input.selectAction)).subscribe(onNext: { [self] contentTable , index , action in

            let content = contentTable[index.section].items[index.row]
            switch content {
            case .myAppointmentModel(info: let itemData):
                let inputData = InputCancelAppointmentModel(Token: SingletonData.shared.token, CenterId: itemData.centerId, AppointmentId: itemData.appointmentID)
                switch action {
                case .delete: cancelAppointment.onNext((centerId: itemData.centerId, appointmentId: itemData.appointmentID,inputData:inputData))
                case .goToDoctor: goToDoctor.onNext(())
                }
            }
        }).disposed(by: disposeBag)
    }
    private func menuPosition(_ input: Input) {
        input.itemSelectedOn.subscribe(onNext: { position in
            self.indexSelectedCell.onNext(position.indexPath)
            let rect = CGRect(x: 50, y: position.topY - 50 , width: 0, height: 0)
            let size = CGSize(width: 300, height: 100)
            self.presentMenuOn.onNext((rect, size))
        }).disposed(by: disposeBag)
        
       
    }
    
    private func subscribeOnShowDoctor() {
        goToDoctor.throttle(.seconds(1), scheduler: MainScheduler.instance).withLatestFrom(Observable.combineLatest(indexSelectedCell, items)).subscribe(onNext: {[weak self] index , contentTable in
            guard let self = self else { return }
            let content = contentTable[index.section].items[index.row]
            switch content {
            case .myAppointmentModel(info: let itemData):
                self.selectDoctor.onNext(DoctorContent(id: itemData.docId, name: itemData.doctorName, professions: itemData.doctorProfession))

            }
        }).disposed(by: disposeBag)
    
    }
    
    // delete appointment from server and memory
    private func cancelAppointmentAction() {
        
        cancelAppointment.withLatestFrom(Observable.combineLatest(cancelAppointment,Localizable.localize(.youCanceledOurAppointmentFor))).flatMapLatest { appointment , nfText   -> Observable<(String?,String)> in
            let apiManager = XMLMultiCoder<AppointmentOutput>()
            self.presentReloadIndicator.onNext(())
            
            let request = apiManager.parsData(input: appointment.inputData, metod: .POST, phpFunc: .CancelAppointment, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil))
            
            return request.map{($0.1,nfText)}
            
        }.subscribe(onNext: { (response , nfText) in
            
            if let appointments = MyAppointmentsModel.getData(for: .appointments), let response = response {
                
                
                let removeApointmData = appointments.myAppoints.filter{$0.appointmentId == response }[0]
                
                let newAppointments = appointments.myAppoints.filter{$0.appointmentId != response }
                
                // save new appontments list
                MyAppointmentsModel(myAppoints: newAppointments).saveSelfData(for: .appointments)
                
                // remove from calendar
                CalendarEventManager.event.removeEventFromCalendar(identifier: removeApointmData.calendarIdentifier)
                
                // send push notification
                if let nfSettings = NotificationSettingsModel.getData(for: .notificationSettings),  nfSettings.cancellation {
                    
                    let sound = nfSettings.sound ? "default" : ""

                    let body = removeApointmData.time.changeSymbol(",", on: ", ").changeSymbol("-", on: ".")
                    let title = nfText + " " + removeApointmData.name
                    
                    self.sendPush.onNext(NotificationPush(body: body, title: title, sound: sound))
                }
            } else {
                print("Error")
            }
            
        }).disposed(by: disposeBag)
        
        
    }

    private func sendPushNotification() {
        sendPush.subscribe(onNext: {[weak self] parametrs in
            guard let self = self else { return }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                
                guard let self = self else { return }
                
                    // refresh table
                    self.dismissReloadIndicator.onNext(())
                    self.getTableData()
                
                if let nfSettings = NotificationSettingsModel.getData(for: .notificationSettings),  nfSettings.cancellation {
                                        
                    let jsonManager =  JsonApiManager()
                    guard let token =  UserDefaults.standard.value(forKey: UDKeys.pushNotificationToken.rawValue) as? String  else { return  }
                    
                    let pushRequest = jsonManager.send(parametrs: .pushNotification, data: ModelPush(to: token, notification:parametrs)) as Observable<EmptyAnsver?>
                    
                        pushRequest.subscribe().disposed(by: self.disposeBag)
                    
                }
            }
        }).disposed(by: disposeBag)
    }
    
    init() {
        cancelAppointmentAction()
        sendPushNotification()
        subscribeOnShowDoctor()

    }
    struct Input {
        let refreshContent:Observable<Void>
        let itemSelectedOn:Observable<ModelCellPosition>
        let selectAction:Observable<SelectAction>
    }
    
    struct Output {
        let myAppointmentsTitle:Driver<String>
        let contentTable:Driver<[MyAppointmentSection]>
        let presentMenuOn:Driver<(CGRect,CGSize)>
        let historyTitle:Driver<String>
        let selectDoc:Driver<DoctorContent>
        let showReloadIndicator:Driver<Void>
        let hideReloadIndicator:Driver<Void>
    }
}

