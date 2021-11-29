//
//  CityCoordinator.swift
//  AppointmentProject
//
//  Created by George on 07.10.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class CityCoordinator: NSObject , Coordinator , CoordinatorFinishDelegate  {
    
   

    private let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    
    func start() {
        let cityTVC = CityTVC.instantiate()
        cityTVCEvents(cityTVC)
        navigationController.navigationBar.prefersLargeTitles = true

        navigationController.pushViewController(cityTVC, animated: true)

    }
    
    private func cityTVCEvents(_ controller:CityTVC) {
        controller.nvEvents.subscribe(onNext: {[weak self]event in
            guard let self = self else { return }
            switch event {
            case .showClinics(let index) :
                let clinicCoordinator = ClinicCoordinator(navigationController: self.navigationController, cityIndex: index)
                clinicCoordinator.finishDelegate = self
                clinicCoordinator.start()
                self.childCoordinators.append(clinicCoordinator)
            case .title(let title):
                controller.title = title
            case .searchController(let searchController):
                controller.navigationItem.searchController = searchController
            case .finish:
                self.finish(controller)
            }
        }).disposed(by: disposeBag)
    }
     init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    deinit {
        print("Finish city coordinator")
    }
   
}
