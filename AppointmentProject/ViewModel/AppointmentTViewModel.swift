//
//  AppointmentTViewModel.swift
//  AppointmentProject
//
//  Created by George on 29.07.2021.
//

import Foundation
import RxCocoa
import RxSwift

extension AppointmentTViewModel {
    private var doctorNameDriver:Driver<String> {
        return doctorName.asDriver(onErrorJustReturn: "")
    }
    private var startTimeDriver:Driver<String> {
        return startTime.asDriver(onErrorJustReturn: "")
    }
    private var dateDriver:Driver<String> {
        return date.asDriver(onErrorJustReturn: "")
    }
    private var subdivisionContentDriver:Driver<String> {
        return subdivisionContent.asDriver(onErrorJustReturn: "")
    }
    private var singUpTitle:Driver<String> {
        return Localizable.localize(.signUp).asDriver(onErrorJustReturn: "")
    }
    private var locationDataDriver:Driver<(latitude:String,longitude:String,title:String,subtitle:String)> {
        return locationData.asDriver(onErrorJustReturn: (latitude: String(), longitude: String(), title: String(), subtitle: String()))
    }
    private var startAppointmentDriver:Driver<Void> {
        return startAppointment.asDriver(onErrorJustReturn: ())
    }
    private var finishAppointmentDriver:Driver<Void> {
        return finishAppointment.asDriver(onErrorJustReturn: ())
    }
    private var alertErrorMessageDriver:Driver<String> {
        return alertErrorMessage.asDriver(onErrorJustReturn: "")
    }
    private var doctorTitleText:Driver<String> {
        return Localizable.localize(.doctor).asDriver(onErrorJustReturn: "")
    }
    
    private var fullNameText:Driver<String> {
        return Localizable.localize(.fullName).asDriver(onErrorJustReturn: "")
    }
    private var saveTitle:Driver<String> {
        return Localizable.localize(.save).asDriver(onErrorJustReturn: "")
    }
 }
class AppointmentTViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private let appontmentData = BehaviorSubject<AppointmentModel>(value: AppointmentModel())
    private let errorMessageText = Localizable.localize(.invalidNamePhone)
    private let doctorName = PublishSubject<String>()
    private let startTime = PublishSubject<String>()
    private let date = PublishSubject<String>()
    private let subdivisionContent = PublishSubject<String>()
    private let alertErrorMessage = PublishSubject<String>()
    private let locationData = PublishSubject<(latitude:String,longitude:String,title:String,subtitle:String)>()
    private let patientFullName = BehaviorSubject<String>(value:"")
    private let patientPhoneNumber = BehaviorSubject<String>(value:"")
    private let appointmentPatient = PublishSubject<Void>()
    private let startAppointment = PublishSubject<Void>()
    private let finishAppointment = PublishSubject<Void>()
    
    func transform(_ input: Input) -> Output {
        input.appointmentModel.subscribe(appontmentData).disposed(by: disposeBag)
        selectCell(input)
        bindingPatientData(input)
        
        return Output(doctorName: doctorNameDriver, startTime: startTimeDriver, date: dateDriver, subdivisionContent: subdivisionContentDriver, locationData: locationDataDriver, startAppointment: startAppointmentDriver, finishAppointment: finishAppointmentDriver, alertErrorMessage: alertErrorMessageDriver, dismiss: input.tapCancel.asDriver(onErrorJustReturn: ()), singUpTitle: singUpTitle, doctorTitleText: doctorTitleText, fullNameText: fullNameText, saveTitle: saveTitle)
    }
    
    // saving patient data in property
    private func bindingPatientData(_ input:Input) {
        input.patientFullName.subscribe(patientFullName).disposed(by: disposeBag)
        input.patientPhoneNumber.subscribe(patientPhoneNumber).disposed(by: disposeBag)
    }
    
    private func selectCell(_ input:Input) {
        input.selectCell.withLatestFrom(Observable.combineLatest(appontmentData, input.selectCell,patientFullName,patientPhoneNumber,errorMessageText)).subscribe(onNext: {[self]  model , indexPath , patientName , patientPhone , messageText in
            print(patientName.isEmpty , patientPhone.isEmpty)
                switch indexPath {
                case IndexPath(row: 2, section: 1):
                    self.locationData.onNext((latitude: model.appointmentLockation.latitude, longitude: model.appointmentLockation.longitude, title: model.appointmentLockation.name, subtitle: model.appointmentLockation.adress))
                case IndexPath(row: 0, section: 3):
                    if patientName.isEmpty || patientPhone.isEmpty {
                        alertErrorMessage.onNext(messageText)
                    } else {
                      self.appointmentPatient.onNext(())
                    }
                default:break
                }
        }).disposed(by: disposeBag)
    }
    
    private func appointmentRequestFunc() {

        appointmentPatient.withLatestFrom(Observable.combineLatest(patientFullName, patientPhoneNumber, appontmentData))
            .flatMapLatest({patientName , patientPhone , docData -> Observable<(AppointmentOutput?,String?,AppointmentModel)> in
                
            self.startAppointment.onNext(())
            let apiManager = XMLMultiCoder<AppointmentOutput>()
            let inputRequestData = InputAppointmentModel(Token: "EEF4B03D-C023", CenterId: docData.appointmentLockation.id, Data: InputAppointmentModelContent(DoctorId: docData.doctor.id, RoomId: docData.appointmentTime.roomId, FullName: patientName, StartTime: docData.appointmentTime.time, Phone: patientPhone, Duration: "30"))
            
            let request = apiManager.parsData(input: inputRequestData, metod: .POST, phpFunc: .Appointment, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil))
                
                
               
                let output = request.flatMapLatest { model -> Observable<(AppointmentOutput?, String?, AppointmentModel)> in
                    print(model)
                    
                    return Observable<(AppointmentOutput?, String? , AppointmentModel)>.just((nil ,model.1, docData))
                }
                
                return output
                
        }).subscribe(onNext:{ [self] _ , index , docData  in
                
                // save appointments
                if let index = index {
                   let time =  docData.appointmentTime.time.cutString(from: 11, to: 15)
                    let date =   docData.appointmentTime.time.cutString(from: 0, to: 9)
                        
                    
                    let myAppointment =  MyAppointmentModel(name: docData.doctor.name, subdivision: docData.appointmentLockation.name, professions:                 docData.doctor.professions, appointmentId: index, time: date + " " + time, centerId: docData.appointmentLockation.id, docId: docData.doctor.id)
                    
                    if let appointmentsData = UserDefaults.standard.data(forKey: UDKeys.appointments.rawValue) {
                        
                        guard let appoinmnebts:MyAppointmentsModel = getPacketFromData(data: appointmentsData) else {
                            return
                        }
                        var appointmentContent = appoinmnebts
                        appointmentContent.myAppoints.append(myAppointment)
                        guard let appoinmnebtsNewData = getDataFromPacket(packet: appointmentContent) else {
                            return
                        }
                        UserDefaults.standard.setValue(appoinmnebtsNewData, forKey: UDKeys.appointments.rawValue)
                    } else {
                        let appointmentContent = MyAppointmentsModel(myAppoints: [myAppointment])

                        guard let appoinmnebtsNewData = getDataFromPacket(packet: appointmentContent) else {
                            return
                        }
                        UserDefaults.standard.setValue(appoinmnebtsNewData, forKey: UDKeys.appointments.rawValue)
                    }
                }
                self.finishAppointment.onNext(())
            
            
        }).disposed(by: disposeBag)
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
    }
    struct Output {
        let doctorName:Driver<String>
        let startTime:Driver<String>
        let date:Driver<String>
        let subdivisionContent:Driver<String>
        let locationData:Driver<(latitude:String,longitude:String,title:String,subtitle:String)>
        let startAppointment:Driver<Void>
        let finishAppointment:Driver<Void>
        let alertErrorMessage:Driver<String>
        let dismiss:Driver<Void>
        let singUpTitle:Driver<String>
        let doctorTitleText:Driver<String>
        let fullNameText:Driver<String>
        let saveTitle:Driver<String>
    }
    init() {
        getAppoitmentContent()
        appointmentRequestFunc()
    }
    
}
