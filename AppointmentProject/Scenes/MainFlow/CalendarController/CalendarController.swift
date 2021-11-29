//
//  CalendarController.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import UIKit
import RxCocoa
import RxSwift
final class CalendarController: UIViewController , Storyboarded {
    internal let nvContent = PublishSubject<Event>()
    private let disposeBag = DisposeBag()
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    var delegate:CalendarDateProtocol?
    private let viewModel = CalendarControllerViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        let output = viewModel.transform(CalendarControllerViewModel.Input())
        calendarLocalize(output)
        buttonsLocalizable(output)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        nvContent.onNext(.finish)
    }
    private func calendarLocalize(_ output:CalendarControllerViewModel.Output) {
        datePicker.minimumDate = Date()

        output.calengarLocale.drive(onNext:{ identifier in
            self.datePicker.locale = Locale(identifier: identifier)
        }).disposed(by: disposeBag)
    }
    
    private func buttonsLocalizable(_ output:CalendarControllerViewModel.Output) {
        output.cancelButtonLocalizable.drive(cancelButton.rx.title()).disposed(by: disposeBag)
        output.saveButtonLocalizable.drive(saveButton.rx.title()).disposed(by: disposeBag)
    }
    @IBAction func saveAction(_ sender: Any) {
        delegate?.selectDate(datePicker.date)
        nvContent.onNext(.dismissFinish)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        nvContent.onNext(.dismissFinish)
    }
}
extension CalendarController {
    enum Event {
        case finish
        case dismissFinish
    }
}
