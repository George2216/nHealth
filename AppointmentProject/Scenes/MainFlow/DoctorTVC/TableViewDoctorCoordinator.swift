//
//  TableViewCoordinator.swift
//  AppointmentProject
//
//  Created by George on 30.08.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

struct DoctorContent {
    let id:String
    let name:String
    let professions:String
}

final class TableViewDoctorCoordinator:NSObject, Coordinator, CoordinatorFinishDelegate {
    
    private let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    var paramDoctor:DoctorContent
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    
    
    func start() {
        let tableDoctor = TableViewDoctor.instantiate()
        
        navigationController.pushViewController(tableDoctor, animated: true)
        tableDoctor.paramDoctor.onNext(self.paramDoctor)

        tableViewDoctorEvents(tableDoctor)

    }
    private func tableViewDoctorEvents(_ controller:TableViewDoctor) {
        controller.nvContent.subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .finish :
                self.finish(controller)
                
            case .tapBack:
                controller.navigationController?.popViewController(animated: true)
                
            case .backButton(let button):
                controller.navigationItem.leftBarButtonItem = button
                
            case .fullScreenPhoto:
                let pageVCCoordinator = PageDoctorCoordinator(navigationController: controller.navigationController!)
                pageVCCoordinator.finishDelegate = self
                pageVCCoordinator.start()
                self.childCoordinators.append(pageVCCoordinator)

            case .showMap(content: let content):
                let mapCoordinator = MapViewCoordinator(navigationController:  controller.navigationController!, contentMap: content)
                mapCoordinator.finishDelegate = self
                mapCoordinator.start()
                self.childCoordinators.append(mapCoordinator)
           
            case .showRefresh:
                let activityCoordinator = ActivityVCCoordinator(navigationController: self.navigationController, finishDelegate: self)
                activityCoordinator.start()
                self.childCoordinators.append(activityCoordinator)
            case .hideRefresh:
                self.navigationController.dismiss(animated: true, completion: nil)
            case .titleText(let title):
                controller.title = title
                self.navigationController.setNavigationBarHidden(false, animated: false)

            case .appointmentContent(let model):
                let appointmentCoordinator = AppointmentCoordinator(navigationController: self.navigationController, model: model, finishDelegate: self)
                    appointmentCoordinator.start()
                self.childCoordinators.append(appointmentCoordinator)
            }

        }).disposed(by: disposeBag)
        
    }
    
    
     init(navigationController: UINavigationController,paramDoctor:DoctorContent,finishDelegate:CoordinatorFinishDelegate) {
        self.navigationController = navigationController
        self.paramDoctor = paramDoctor
        self.finishDelegate = finishDelegate
    }
    deinit {
        print("Doctor deinit ")
    }
}


