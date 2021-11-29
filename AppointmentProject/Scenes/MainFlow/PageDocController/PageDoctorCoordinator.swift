//
//  PageDoctorCoordinator.swift
//  AppointmentProject
//
//  Created by George on 06.09.2021.
//

import Foundation
import UIKit
class PageDoctorCoordinator:NSObject , Coordinator {
    var childCoordinators: [Coordinator]  = []
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
   internal func start() {
        let pageVC  = PageDoctorVC()
        pageVC.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(pageVC, animated: false)
    }
    
     init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("Page deinit")
    }
}
