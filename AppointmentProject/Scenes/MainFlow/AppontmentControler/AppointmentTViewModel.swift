//
//  AppointmentTViewModel.swift
//  AppointmentProject
//
//  Created by George on 29.07.2021.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources


enum AppointmentSectionType {
    case doctorSection(header:String?,footer:String?)
    case stacticContentSection(header:String?,footer:String?)
    case dynamicContentSection(header:String?,footer:String?)
    case saveSection(header:String?,footer:String?)
    
    var doctorSection:(header:String?,footer:String?) {
        switch self {
        case .doctorSection(let header, let footer):
            return (header,footer)
        case .stacticContentSection(header: let header, footer: let footer) :
            return (header,footer)
        case .dynamicContentSection(header: let header, footer: let footer) :
            return (header,footer)
        case .saveSection(header: let header, footer: let footer) :
            return (header,footer)
        }
    }
}

enum AppointmentItem {
case doctorItem(title:String,subtitle:String)
case staticItem(imageName:String,text:String)
case patientDataItem(imageName:String,placeholder:String)
case saveItem(title:String)
}
typealias AppointmentSection = SectionModel<AppointmentSectionType,AppointmentItem>

final class AppointmentTViewModel: ViewModelProtocol {
    private let items = BehaviorSubject<[AppointmentSection]>(value: [])
    private let disposeBag = DisposeBag()
    private let appontmentData = BehaviorSubject<AppointmentModel>(value: AppointmentModel())
    private let errorMessageText = Localizable.localize(.invalidNamePhone)
    private let doctorName = PublishSubject<String>()
    private let startTime = PublishSubject<String>()
    private let date = PublishSubject<String>()
    private let subdivisionContent = PublishSubject<String>()
    private let alertErrorMessage = PublishSubject<String>()
    private let locationData = PublishSubject<CoordinateModel>()
    private let patientFullName = BehaviorSubject<String>(value:"")
    private let patientPhoneNumber = BehaviorSubject<String>(value:"")
    private let appointmentPatient = PublishSubject<Void>()
    private let startAppointment = PublishSubject<Void>()
    private let finishAppointment = PublishSubject<Void>()
    
    func transform(_ input: Input) -> Output {
        input.appointmentModel.subscribe(appontmentData).disposed(by: disposeBag)
        selectCell(input)
        createTableData(input)
        subscribeOnTextFieldData(input)
        
        return Output(   locationData: locationDataDriver, startAppointment: startAppointmentDriver, finishAppointment: finishAppointmentDriver, alertErrorMessage: alertErrorMessageDriver, dismiss: input.tapCancel.asDriver(onErrorJustReturn: ()), singUpTitle: singUpTitle,  items: itemsDriver)
    }
    
    private func createTableData(_ input:Input) {
        let localizableText = Observable.combineLatest(
            Localizable.localize(.doctor),
            Localizable.localize(.fullName),
            Localizable.localize(.save))
        
        input.appointmentModel.withLatestFrom(Observable.combineLatest(input.appointmentModel,localizableText)).subscribe(onNext: { appointmentData , localizableData in
            let dateString = appointmentData.appointmentTime.time.cutString(to: "T")?.changeSymbol("-", on: ".") ?? ""
            let timeString = appointmentData.appointmentTime.time.cutString(from:"T").cutString(from: 0, to: 4)
            let locationTitle = appointmentData.appointmentLockation.city + " " + appointmentData.appointmentLockation.adress + " " + appointmentData.appointmentLockation.name
            let fullNamePlaceholder = localizableData.1
            let phonePlaceholder = "+38"

            let doctorHeaderSection = AppointmentSection(model: .doctorSection(header: nil, footer: nil), items: [.doctorItem(title: localizableData.0, subtitle: appointmentData.doctor.name)])
            
            let staticSection = AppointmentSection(model: .stacticContentSection(header: nil, footer: nil), items: [.staticItem(imageName: "calendar.circle.fill", text: dateString) ,
                 .staticItem(imageName: "timer", text: timeString),
                 .staticItem(imageName: "mappin.and.ellipse", text: locationTitle)])
            
            let patientDataSection = AppointmentSection(model: .dynamicContentSection(header: nil, footer: nil), items: [.patientDataItem(imageName: "person.fill", placeholder: fullNamePlaceholder),
                 .patientDataItem(imageName: "phone.circle.fill", placeholder: phonePlaceholder)])
            
            let saveSection = AppointmentSection(model: .saveSection(header: nil, footer: nil), items: [.saveItem(title: localizableData.2)])
            
            self.items.onNext([doctorHeaderSection,staticSection,patientDataSection,saveSection])
            
        }).disposed(by: disposeBag)
    }
    private func subscribeOnTextFieldData(_ input:Input) {
        input.textFieldsData.subscribe(onNext: {[weak self] (text , indexPath ) in
            guard let self = self else { return }
            switch indexPath.row {
            case 0 :
                self.patientFullName.onNext(text)
            case 1 :
                self.patientPhoneNumber.onNext(text)
            default :
                break
            }
        }).disposed(by: disposeBag)
    }
   
   
    private func selectCell(_ input:Input) {
        input.selectCell.withLatestFrom(Observable.combineLatest(appontmentData, input.selectCell,patientFullName,patientPhoneNumber,errorMessageText)).subscribe(onNext: {[self]  model , indexPath , patientName , patientPhone , messageText in
            print(patientName.isEmpty , patientPhone.isEmpty)
                switch indexPath {
                case IndexPath(row: 2, section: 1):
                    self.locationData.onNext(CoordinateModel(latitude: model.appointmentLockation.latitude, longitude: model.appointmentLockation.longitude, title: model.appointmentLockation.name, subtitle: model.appointmentLockation.adress))
                    
                case IndexPath(row: 0, section: 3) where patientName.isEmpty || patientPhone.isEmpty || !patientPhone.isValid(regex: .phone):
                    self.alertErrorMessage.onNext(messageText)
                case IndexPath(row: 0, section: 3) :
                    self.appointmentPatient.onNext(())
                default:break
                }
        }).disposed(by: disposeBag)
    }
    
    private func appointmentRequestFunc() {

        appointmentPatient.withLatestFrom(Observable.combineLatest(patientFullName, patientPhoneNumber, appontmentData,Localizable.localize(.youSignedUpFor)))
            .flatMapLatest({patientName , patientPhone , docData , youSignedUpFor -> Observable<(AppointmentOutput?,String?,AppointmentModel,String)> in
            let phone = patientPhone.removeFirst(.ten)
            self.startAppointment.onNext(())
            let apiManager = XMLMultiCoder<AppointmentOutput>()
                
            let inputRequestData = InputAppointmentModel(Token: SingletonData.shared.token, CenterId: docData.appointmentLockation.id, Data: InputAppointmentModelContent(DoctorId: docData.doctor.id, RoomId: docData.appointmentTime.roomId, FullName: patientName, StartTime: docData.appointmentTime.time, Phone: phone, Duration: "30"))

                let request = apiManager.parsData(input: inputRequestData, metod: .POST, phpFunc: .Appointment, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil))
                
                let output = request.flatMapLatest { model -> Observable<(AppointmentOutput?, String?, AppointmentModel,String)> in
                    
                    return Observable<(AppointmentOutput?, String? , AppointmentModel,String)>.just((nil ,model.1, docData,youSignedUpFor))
                }
                
                return output
                
        }).subscribe(onNext:{ [self] _ , index , docData , youSignedUpFor in
                
                // save appointments
                if let index = index {
                    let timeStr =  docData.appointmentTime.time.cutString(from: 11, to: 15)
                    let dateStr =   docData.appointmentTime.time.cutString(from: 0, to: 9)
                    
                    let title = youSignedUpFor + " " + docData.doctor.name
                    let body = dateStr.changeSymbol("-", on: ".") + " " + timeStr
                    let fullData = docData.appointmentTime.time.changeSymbol("T", on: " ").fullDateSpase()
                   
                    CalendarEventManager.event.addEventToCalendar(title: title, description: body, date: fullData!) {[weak self]  identifier in
                        
                        guard let self = self else { return }
                    
                    let myAppointment =  MyAppointmentModel(name: docData.doctor.name, subdivision: docData.appointmentLockation.name, professions:                 docData.doctor.professions, appointmentId: index, time: dateStr + "," + timeStr, centerId: docData.appointmentLockation.id, docId: docData.doctor.id, token: SingletonData.shared.token, calendarIdentifier: identifier)
                    
                    if let appointments = MyAppointmentsModel.getData(for: .appointments) {
                      
                        var appointmentContent = appointments
                        appointmentContent.myAppoints.append(myAppointment)
                        appointmentContent.saveSelfData(for: .appointments)

                    } else {
                        
                        let appointmentContent = MyAppointmentsModel(myAppoints: [myAppointment])
                        appointmentContent.saveSelfData(for: .appointments)
                    }
                        
                    if let nfSettings = NotificationSettingsModel.getData(for: .notificationSettings),  nfSettings.completion {
                        
                        let sound = nfSettings.sound ? "default" : ""
                        
                        let jsonManager =  JsonApiManager()
                        guard let token =  UserDefaults.standard.value(forKey: UDKeys.pushNotificationToken.rawValue) as? String  else { return  }
                        
                        let pushRequest = jsonManager.send(parametrs: .pushNotification, data: ModelPush(to: token, notification: NotificationPush(body: body , title:title , sound: sound))) as Observable<EmptyAnsver?>
                        
                            pushRequest.subscribe().disposed(by: self.disposeBag)
                    }
                
                self.finishAppointment.onNext(())
                self.sendReloadNotification()

                }}
        }).disposed(by: disposeBag)
    }
    
    private func sendReloadNotification() {
        NotificationCenter.default.post(name: .reloadInitialVCData, object: nil)

    }
    
    
    private func getAppoitmentContent() {
        appontmentData.subscribe(onNext: {[self] data in
            doctorName.onNext(data.doctor.name)
            startTime.onNext(data.appointmentTime.time.cutString(from: 11, to: 15))
            date.onNext(data.appointmentTime.time.cutString(from: 0, to: 9))
            subdivisionContent.onNext(data.appointmentLockation.city + " " + data.appointmentLockation.adress + " " + data.appointmentLockation.name)
            
        }).disposed(by: disposeBag)
        
    }
   
    struct Input {
        let appointmentModel:Observable<AppointmentModel>
        let selectCell:Observable<IndexPath>
        let patientFullName:Observable<String>
        let patientPhoneNumber:Observable<String>
        let tapCancel:Observable<Void>
        let textFieldsData:Observable<(String,IndexPath)>

    }
    struct Output {
       
        let locationData:Driver<CoordinateModel>
        let startAppointment:Driver<Void>
        let finishAppointment:Driver<Void>
        let alertErrorMessage:Driver<String>
        let dismiss:Driver<Void>
        let singUpTitle:Driver<String>
       
        let items:Driver<[AppointmentSection]>
    }
    init() {
        getAppoitmentContent()
        appointmentRequestFunc()
    }
    
}

extension AppointmentTViewModel {
    private var itemsDriver:Driver<[AppointmentSection]> {
        items.asDriverOnErrorJustComplete()
    }
   
    private var singUpTitle:Driver<String> {
        return Localizable.localize(.signUp).asDriverOnErrorJustComplete()
    }
    private var locationDataDriver:Driver<CoordinateModel> {
        return locationData.asDriverOnErrorJustComplete()
    }
    private var startAppointmentDriver:Driver<Void> {
        return startAppointment.asDriverOnErrorJustComplete()
        
    }
    private var finishAppointmentDriver:Driver<Void> {
        return finishAppointment.asDriverOnErrorJustComplete()
    }
    private var alertErrorMessageDriver:Driver<String> {
        return alertErrorMessage.asDriverOnErrorJustComplete()
    }
   
  
 }
