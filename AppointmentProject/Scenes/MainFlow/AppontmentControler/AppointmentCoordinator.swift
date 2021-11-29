//
//  AppointmentCoordinator.swift
//  AppointmentProject
//
//  Created by George on 29.08.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class AppointmentCoordinator:NSObject, Coordinator, CoordinatorFinishDelegate {
    
    
   
    private let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var model:AppointmentModel
    
    func start() {
        let appointmentTVC = AppointmentTVC.instantiate()
        let nav = UINavigationController(rootViewController: appointmentTVC)
        appointmentTVCEvents(appointmentTVC)
        nav.modalPresentationStyle = .overFullScreen
        appointmentTVC.appointmentModel.onNext(model)
        navigationController.present(nav, animated: true) {[weak self] in
            guard let self = self else { return }
            appointmentTVC.appointmentModel.onNext(self.model)
        }

    }
    
    private func appointmentTVCEvents(_ controller:AppointmentTVC) {
        controller.nvContent.subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .finish:
                self.finish(controller)
                
            case .goBack:
                self.navigationController.dismiss(animated: true, completion: nil)
                
            case .showActivityInicator:
                let refreshCoordinator = ActivityVCCoordinator(navigationController: controller.navigationController!, finishDelegate: self)
                refreshCoordinator.start()
                self.childCoordinators.append(refreshCoordinator)
                
            case .showMap(content: let location):
                let mapCoordinator = MapViewCoordinator(navigationController: controller.navigationController!, contentMap: location)
                mapCoordinator.finishDelegate = self
                mapCoordinator.start()
                self.childCoordinators.append(mapCoordinator)
                
            case .backButton(let button):
                controller.navigationItem.rightBarButtonItem = button
                
            case .title(let title):
                controller.title = title
                
            case .showErrorMessage(title: let title):
                controller.presentAlertWithTitle(title: title, message: "", options: "×", style: .destructive) { action in }
                
            case .goToInitialVC:
                controller.performSegue(withIdentifier: "unwindToInitialFromAppointment", sender: self)

            }
        }).disposed(by: disposeBag)
    }
   
    
     init(navigationController: UINavigationController,model:AppointmentModel,finishDelegate:CoordinatorFinishDelegate?) {
        self.navigationController = navigationController
        self.model = model
        self.finishDelegate = finishDelegate

    }
    deinit {
        print("Deinit appointment")
    }
}
