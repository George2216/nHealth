//
//  ClinicCoordinator.swift
//  AppointmentProject
//
//  Created by George on 07.10.2021.
//

import Foundation
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class ClinicCoordinator : NSObject , Coordinator , CoordinatorFinishDelegate {
    
    private let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    var cityIndex:Int
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    func start() {
        let clinicTVC = ClinicTVC.instantiate()
        navigationController.navigationBar.prefersLargeTitles = true
        clinicTVC.title = "Обрати клініку"
        clinicTVCEvents(clinicTVC)
        clinicTVC.cityIndex.onNext(cityIndex)
        navigationController.pushViewController(clinicTVC, animated: true)
    }
    
    private func clinicTVCEvents(_ controller:ClinicTVC) {
        controller.nvEvents.subscribe(onNext: {[weak self] event in
            guard let self = self else { return }
            switch event {
            case .finish:
                self.finish(controller)
            case .searchController(let searchController):
                controller.navigationItem.searchController = searchController
            case .title(let title):
                controller.title =  title
            case .showActivityIndicatior:
                let refreshCoordinator = ActivityVCCoordinator(navigationController: self.navigationController,finishDelegate: self)
                refreshCoordinator.start()
                self.childCoordinators.append(refreshCoordinator)
            case .hideActivityIndicatior:
                self.navigationController.dismiss(animated: true, completion: nil)

            case .goToMainFlow:
            NotificationCenter.default.post(name: .goToFlow(flow: .mainFlow), object: nil)
                
            case .connectionError(let message):
                controller.presentAlertWithTitle(title: message, message: "", options: "×", style: .destructive) { action in }

            }
        }).disposed(by: disposeBag)
    }
    
    
     init(navigationController: UINavigationController, cityIndex:Int) {
         self.navigationController = navigationController
        self.cityIndex = cityIndex
    }
    deinit {
        print(" finish clinic coordinator")
    }
    
}

