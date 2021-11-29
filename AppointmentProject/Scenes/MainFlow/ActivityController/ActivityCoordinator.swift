//
//  ActivityCoordinator.swift
//  AppointmentProject
//
//  Created by George on 31.08.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class ActivityVCCoordinator: NSObject , Coordinator {
    private let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    func start() {
        let activityVC = ActivityVC()
        activityVC.modalPresentationStyle = .overFullScreen
        activityVCEvents(activityVC)
        navigationController.present(activityVC, animated: true, completion: nil)
    }
    private func activityVCEvents(_ controller:ActivityVC) {
        controller.nvContent.subscribe(onNext: {[weak self]event in
            guard let self = self else { return }
            switch event {
            case .finish:
                self.finish(controller)
            }
        }).disposed(by: disposeBag)
    }
    
    
        init(navigationController: UINavigationController,finishDelegate:CoordinatorFinishDelegate?) {
            self.navigationController = navigationController
            self.finishDelegate = finishDelegate
    }
    
    deinit {
        print("deinit refresh")
    }
}
