//
//  MenuEventTableCoordinator.swift
//  AppointmentProject
//
//  Created by George on 30.10.2021.
//


import Foundation
import UIKit
import RxSwift
import RxCocoa

typealias MenuPresentationControllerProtocol =  UIPopoverPresentationControllerDelegate & UITableViewController & SelectMenuCell

final class MenuEventTableCoordinator : NSObject , Coordinator {
    
    private let disposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    
    private var presentationController: MenuPresentationControllerProtocol
    private var position: CGRect
    private var size: CGSize
    
    
    func start() {
        let menu =  MenuEventsTableV.instantiate()
        menu.modalPresentationStyle = .popover
        menu.selectedDelegate = presentationController
        menu.preferredContentSize = size
        menuEvents(controller: menu)
        let popoverVC =  menu.popoverPresentationController
        popoverVC?.delegate = presentationController
        popoverVC?.sourceView = presentationController.tableView
        popoverVC?.sourceRect = position
        
        navigationController.present(menu, animated: true, completion: nil)

    }
    
    private func menuEvents(controller:MenuEventsTableV) {
        controller.navEvents.subscribe(onNext: {[weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .finish:
                self.finish(controller)
            case .selectItem(let action):
                
                self.navigationController.dismiss(animated: true, completion: nil)
                controller.selectedDelegate?.selectAction(action: action)
            }
        }).disposed(by: disposeBag)
    }
    
    init(navigationController: UINavigationController,finishDelegate:CoordinatorFinishDelegate,presentationController:MenuPresentationControllerProtocol,position:CGRect,size:CGSize) {
        
        self.finishDelegate = finishDelegate
        self.navigationController = navigationController
        self.presentationController = presentationController
        self.position = position
        self.size = size
    }
    
    deinit {
        print("Menu coordinator deinited")
    }
}
