//
//  LanguageCoordinator.swift
//  AppointmentProject
//
//  Created by George on 01.09.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class LanguageCoordinator: NSObject , Coordinator {
    let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    func start() {
        let languageTVC = LanguageTVC(style: .insetGrouped)
    eventsLanguageTVC(languageTVC)
    navigationController.pushViewController(languageTVC, animated: true)
    }
    
    func eventsLanguageTVC(_ controller:LanguageTVC) {
        controller.nvContent.subscribe(onNext: {[weak self] event in
            guard let self = self else { return }
            switch event {
            case .finish :
                self.finish(controller)
            }
        }).disposed(by: disposeBag)
    }
    
   
    init(navigationController: UINavigationController,finishDelegate:CoordinatorFinishDelegate?) {
        self.navigationController = navigationController
        self.finishDelegate = finishDelegate
    }
    deinit {
        print("Language deinit")
    }
}
