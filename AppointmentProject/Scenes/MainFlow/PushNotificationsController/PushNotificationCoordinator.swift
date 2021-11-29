//
//  PushNotificationCoordinator.swift
//  AppointmentProject
//
//  Created by George on 19.10.2021.
//
import Foundation
import UIKit
import RxSwift
import RxCocoa

final class PushNotificationCoordinator : NSObject , Coordinator {
    private let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    func start() {
        let pushNotificationTVC = PushNotificationTVC(style: .insetGrouped)
        pushNotificationTVEvents(pushNotificationTVC)
        navigationController.pushViewController(pushNotificationTVC, animated: true)
    }
    
    private func pushNotificationTVEvents(_ controller:PushNotificationTVC) {
        controller.nvContent.subscribe(onNext: {[weak self] event in
            guard let self = self else { return }
            switch event {
            case .isLargeTitle(let isLarge):
                self.navigationController.navigationBar.prefersLargeTitles = isLarge

            case .finish:
                self.finish(controller)
            }
            
        }).disposed(by: disposeBag)
    }
    
    init(navigationController: UINavigationController, finishDelegate:CoordinatorFinishDelegate) {
        self.navigationController = navigationController
        self.finishDelegate = finishDelegate
    }
    
    deinit {
        print("Finish notification coordinator")
    }
}

