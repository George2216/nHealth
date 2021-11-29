//
//  AboutUsCoordinator.swift
//  AppointmentProject
//
//  Created by George on 01.09.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class AboutUsCoordinator: NSObject , Coordinator {
    let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    func start() {
    let aboutUsVC = AboutUsVC()
        aboutUsEvents(aboutUsVC)
        let nav = UINavigationController(rootViewController: aboutUsVC)
        nav.modalPresentationStyle = .overFullScreen
//        aboutUsVC.addSwipeGesture()
        navigationController.present(nav, animated: true, completion: nil)
    }
    private func aboutUsEvents(_ controller:AboutUsVC) {
        controller.nvContent.subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .navItems(let barButtonItems):
                controller.navigationItem.rightBarButtonItems = barButtonItems
            case .finish:
                self.finish(controller)
            case .finishDismiss:
                self.navigationController.dismiss(animated: true, completion: nil)
            case .backButton(let backButton):
                controller.navigationItem.leftBarButtonItem = backButton
            }
        }).disposed(by: disposeBag)
    }
    
    
    
     init(navigationController: UINavigationController,finishDelegate:CoordinatorFinishDelegate?) {
        self.navigationController = navigationController
        self.finishDelegate = finishDelegate
    }
    deinit {
        print("About us deinit")
    }
}

