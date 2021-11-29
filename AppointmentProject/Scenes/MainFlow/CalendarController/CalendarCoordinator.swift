//
//  CalendarCoordinator.swift
//  AppointmentProject
//
//  Created by George on 30.08.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
final class CalendarCoordinator:NSObject ,  Coordinator {
   
    
    private let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    var finishDelegate: CoordinatorFinishDelegate?
    var delegate:CalendarDateProtocol?
    var navigationController: UINavigationController
    
    func start() {
        let calendarController = CalendarController.instantiate()
        calendarController.delegate = delegate
        calendarControllerEvents(calendarController)
        navigationController.present(calendarController, animated: true, completion: nil)
    }
   
    private func calendarControllerEvents(_ controller:CalendarController) {
        controller.nvContent.subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .finish:
                self.finish(controller)
            case .dismissFinish:
                self.navigationController.dismiss(animated: true, completion: nil)
            }
        }).disposed(by: disposeBag)
    }
    
    init(navigationController: UINavigationController,delegate:CalendarDateProtocol?,finishDelegate:CoordinatorFinishDelegate) {
        self.navigationController = navigationController
        self.delegate = delegate
        self.finishDelegate = finishDelegate
    }
    
    deinit {
        print("Deinit calendar")
    }
}
