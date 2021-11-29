//
//  MapViewCoordinator.swift
//  AppointmentProject
//
//  Created by George on 09.09.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
final class MapViewCoordinator:NSObject ,  Coordinator {
    private let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
        var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    var contentMap:CoordinateModel
    
    func start() {
        let mapController = MapViewController.instantiate()
        mapController.coordinate.onNext(contentMap)
        mapControllerEvents(mapController)
        navigationController.show(mapController, sender: nil)
    }
    
   
     init(navigationController: UINavigationController,contentMap:CoordinateModel) {
        self.navigationController = navigationController
        self.contentMap = contentMap
    }
    private func mapControllerEvents(_ controller:MapViewController) {
        controller.nvContent.subscribe(onNext: {[weak self] events in
            guard let self = self else { return }
            switch events {
            case .finish:
                self.finish(controller)
            }
        }).disposed(by: disposeBag)
    }
    deinit {
        print("Map coordinator deinit")
    }
}
