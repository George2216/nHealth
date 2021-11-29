//
//  ProfessionsCoordinator.swift
//  AppointmentProject
//
//  Created by George on 30.08.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
final class ProfessionsCoordinator:NSObject ,  Coordinator {
    private let disposeBag = DisposeBag()
    private var clinicId:String
    var childCoordinators: [Coordinator] = []
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    func start() {
        let professions = ProfessionTVC.instantiate()
        let navController = UINavigationController(rootViewController: professions)
        professionTVCEvents(professions)
        professions.clinicId.onNext(clinicId)
        navigationController.show(navController, sender: nil)
    }
    
   
    
     init(navigationController: UINavigationController,clinicId:String,finishDelegate:CoordinatorFinishDelegate) {
        self.navigationController = navigationController
        self.clinicId = clinicId
        self.finishDelegate = finishDelegate
    }
    
    private func professionTVCEvents(_ controller:ProfessionTVC){
        controller.nvContent.subscribe(onNext: {[weak self]event in
            guard let self = self else { return }
            switch event {
            case .dismissFinish:
                self.navigationController.dismiss(animated: true, completion: nil)
            case .finish:
                self.finish(controller)
            case .segmentControl(let titleView):
                controller.navigationItem.titleView = titleView
            case .rightButton(let rightButton ):
                controller.navigationItem.rightBarButtonItem = rightButton
            case .leftButton( let leftButton):
                controller.navigationItem.leftBarButtonItem = leftButton
            }
        }).disposed(by: disposeBag)
    }
    deinit {
        print("Professions deinit")
    }
}
