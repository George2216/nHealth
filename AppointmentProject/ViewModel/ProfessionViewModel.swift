//
//  ProfessionViewModel.swift
//  AppointmentProject
//
//  Created by George on 16.07.2021.
//

import Foundation
import RxCocoa
import RxSwift

extension ProfessionViewModel {
    private var specialtiesDriver:Driver<[SpecialitysUI]> {
        return  professions.asDriver(onErrorJustReturn: [])
    }
    private var cellIsEnubleDriver:Driver<Bool> {
        return  cellIsEnuble.asDriver(onErrorJustReturn: false)
    }
    private var saveDataDriver: Driver<(clinicId:String,professions:[String])> {
        return saveData.asDriver(onErrorJustReturn: (clinicId: String(), professions: []))
    }
    
}

class ProfessionViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private var professions = BehaviorSubject<[SpecialitysUI]>(value: [])
    private let cellIsEnuble = PublishSubject<Bool>()
    private let idSubdivision = BehaviorSubject<String>(value: String())
    private let saveData = PublishSubject<(clinicId:String,professions:[String])>()
    
    func transform(_ input: Input) -> Output {
        getProfession(input)
        subscribeOnSegment(input)
        createSelectCellSpecialty(input)
        saveAction(input)
        saveIdClinic(input)
        
        return Output(specialties: specialtiesDriver, cellIsEnuble: cellIsEnubleDriver, saveData: saveDataDriver)
    }
    private func saveIdClinic(_ input:Input) {
        input.idClinic.bind(to: idSubdivision).disposed(by: disposeBag)
    }
    
    private func saveAction(_ input:Input) {
        input.tapSave.withLatestFrom(Observable.combineLatest(professions, idSubdivision)).subscribe(onNext:{ arrayProd , clinicId in
            print("Tap")
            
            self.saveData.onNext((clinicId: clinicId, professions: arrayProd.filter{$0.isSelected}.map{$0.id}))
        }).disposed(by: disposeBag)
        
    }
    private func getProfession(_ input:Input) {
        input.idClinic.subscribe(onNext: { [self] id in
            let apiManager = XMLMultiCoder<SpecialtyListModel>()
            apiManager.parsData(input: InputModelDoctors(Token: "EEF4B03D-C023", CenterId: id), metod: .POST, phpFunc: .SpecialtyList, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil)).asObservable().subscribe(onNext: { model , _  in
            
                let specialityUI =  model?.Specialty.map({ data  in
                return SpecialitysUI(id: data.id, name: data.name, isSelected: true, alpha: 0.7)
                })
                professions.onNext(specialityUI ?? [])
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    private func subscribeOnSegment(_ input:Input) {
        input.segmentIndex.withLatestFrom(Observable.combineLatest( input.segmentIndex, professions)).subscribe(onNext: { [self] segmentIndex , profesionArray in
            
            let boolFlag = segmentIndex == 1
            let newArray = profesionArray.map{ specialitysUI -> SpecialitysUI in
                var newSpecialitysUI = specialitysUI
                newSpecialitysUI.isSelected = !boolFlag
                newSpecialitysUI.alpha = (boolFlag ? 1 : 0.7)
                return newSpecialitysUI
            }
            cellIsEnuble.onNext(boolFlag)
            professions.onNext(newArray)
            
            }).disposed(by: disposeBag)
        input.segmentIndex.subscribe(onNext:{ [self] index in
            switch index {
            case 0:
                cellIsEnuble.onNext(false)
            case 1:
                cellIsEnuble.onNext(true)
            default:
                break
            }
        }).disposed(by: disposeBag)
        
    }
    private func createSelectCellSpecialty(_ input:Input){
        input.selectCellIndex.withLatestFrom(Observable.combineLatest( input.selectCellIndex, professions)).subscribe(onNext: {index, arrayProfessionsUI in
            var newArray = arrayProfessionsUI
            newArray[index].isSelected =  !newArray[index].isSelected
            self.professions.onNext(newArray)
        }).disposed(by: disposeBag)
    }
    
    struct SpecialitysUI:SpecialtyProtocol {
        var id: String
        var name: String
        var isSelected:Bool
        var alpha:CGFloat
    }
    
    struct Input {
        let idClinic:Observable<String>
        let segmentIndex:Observable<Int>
        let selectCellIndex:Observable<Int>
        let tapSave:Observable<Void>
    }
    struct Output {
        let specialties:Driver<[SpecialitysUI]>
        let cellIsEnuble:Driver<Bool>
        let saveData:Driver<(clinicId:String,professions:[String])>
    }
}

