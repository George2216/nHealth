//
//  Coordinator.swift
//  AppointmentProject
//
//  Created by George on 27.08.2021.
//

import Foundation
import UIKit

protocol Coordinator : NSObject {
    var childCoordinators:[Coordinator] {get set}
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    
    var navigationController: UINavigationController {get set}
    
    func start()
}

protocol CoordinatorFinishDelegate:AnyObject {
    var childCoordinators:[Coordinator] {get set}
    func coordinatorDidFinish(childCoordinator: Coordinator)
    
}
extension CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator:Coordinator) {
        childCoordinators = childCoordinators.filter {$0 !== childCoordinator}
    }
}

extension Coordinator  {
    func finish(_ controller:UIViewController) {
        // do not delete coordinator when push occurs / finish event subscribe on  viewDidDisappear
        let nav = controller.navigationController
        let navigationUnwrap = (nav != nil) ? nav!.isMovingFromParent || nav!.isBeingDismissed : false

        if (controller.isMovingFromParent || controller.isBeingDismissed || controller.isMovingToParent) || navigationUnwrap  {
        childCoordinators.removeAll()
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)

        }
    }
    
}


