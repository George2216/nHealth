//
//  ViewControllerCoordinator.swift
//  AppointmentProject
//
//  Created by George on 27.08.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay
protocol CoordinatorTabBarProtocol: Coordinator {
    var tabBarController: TabBarController {get set}

}

final class TabBarCoordinator: NSObject , CoordinatorTabBarProtocol, CoordinatorFinishDelegate {
    private let tabBarImages = ["doc.text.below.ecg.fill.rtl","archivebox.fill","tag","gear"]
    
    
    
    
    private let disposeBag = DisposeBag()
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []

    var navigationController: UINavigationController
    var tabBarController: TabBarController
    
    func start() {
        let pages: [TabBarPage] = [.initial, .history, .discount, .settings]
            .sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
        prepareTabBarController(withTabControllers: getTabBarControllers(pages))
       
    }

    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        for (index , imageName) in tabBarImages.enumerated() {
          let height = tabBarController.tabBar.frame.height / 2 - 10
            tabControllers[index].tabBarItem.image = UIImage(systemName: imageName)?.withBaselineOffset(fromBottom: height)
        }
       
        
//        /// Set delegate for UITabBarController
        tabBarController.delegate = self
        /// Assign page's controllers
        tabBarController.setViewControllers(tabControllers, animated: true)
        /// Styling
        tabBarController.tabBar.barTintColor = .white
        /// In this step, we attach tabBarController to navigation controller associated with this coordanator
        navigationController.viewControllers = [tabBarController]
        
    }
    
    func getTabBarControllers(_ pages: [TabBarPage]) -> [UIViewController] {
        let initial = InitialTableVC.instantiate()
        let history = MyAppointmentsTVC.instantiate()
        let discount = DiscountTableVC(style: .insetGrouped)
        let settings = SettingsTableVC.instantiate()
       
        initialVCEvents(initial)
        myAppointmentsEvents(history)
        discountVCEvents(discount)
        settingsVSEvents(settings)
        
        let initialNav = UINavigationController(rootViewController: initial)
        let historyNav = UINavigationController(rootViewController: history)
        let stockNav = UINavigationController(rootViewController: discount)
        let settinsNav = UINavigationController(rootViewController: settings)

        var arrayControllers:[UIViewController] = []
        
        pages.forEach { page in
            switch page {
            case .initial:
                arrayControllers.append(initialNav)
            case .history:
                arrayControllers.append(historyNav)
            case .discount:
                arrayControllers.append(stockNav)
            case .settings:
                arrayControllers.append(settinsNav)
            }
        }
        
        return arrayControllers
    }
     init(navigationController:UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
        tabBarController = .init()
    }
   
}

extension TabBarCoordinator: UITabBarControllerDelegate {
    func  tabBarController ( _  tabBarController :  UITabBarController ,  shouldSelect  viewController :  UIViewController )  ->  Bool  {
        return  true
    }
    
   
}

enum TabBarPage {
    case initial
    case history
    case discount
    case settings
    
    func pageOrderNumber() -> Int {
        switch self {
        case .initial:
            return 0
        case .history:
            return 1
        case .discount:
            return 2
        case .settings:
            return 3
        }
    }
    
}


// events
extension TabBarCoordinator {
    
    private func myAppointmentsEvents(_ controller:MyAppointmentsTVC) {
        controller.nvContent.subscribe(onNext: {[weak self]
            event in
            guard let self = self else { return }

            switch event {
            case .title(let title):
                controller.navigationItem.title = title
            case .showIndicator:
                let refreshCoordinator = ActivityVCCoordinator(navigationController: self.navigationController,finishDelegate: self)
                refreshCoordinator.start()
                self.childCoordinators.append(refreshCoordinator)
            case .showMenu(let position, size: let size):
                let menuCoordinator = MenuEventTableCoordinator(navigationController: self.navigationController,finishDelegate: self,presentationController:controller,position: position,size: size)
                menuCoordinator.start()
                self.childCoordinators.append(menuCoordinator)
                
            case .hideReloadIndicator:
                self.navigationController.dismiss(animated: true, completion: nil)
                
            case .tapDoctor(let parametrsDoctor):
                
                let tableDoctorCoordinator = TableViewDoctorCoordinator(navigationController:  controller.navigationController!, paramDoctor: parametrsDoctor, finishDelegate: self)
                tableDoctorCoordinator.start()
                self.childCoordinators.append(tableDoctorCoordinator)
            }
            
            self.tabBarController.navigationController?.navigationBar.prefersLargeTitles = false
        }).disposed(by: disposeBag)
    }
    
    private func initialVCEvents(_ controller:InitialTableVC) {
        controller.nvContent.subscribe(onNext:  { [weak self] event in
            guard let self = self else { return }

            switch event {
            case .dismissKeyboard:
                self.navigationController.view.endEditing(true)
                
            case .navBarView(let titleView) :
                controller.navigationItem.titleView = titleView
                
            case .appointmentContent(let model):
                let appointmentCoordinator = AppointmentCoordinator(navigationController: self.navigationController, model: model, finishDelegate: self)
                    appointmentCoordinator.start()
                self.childCoordinators.append(appointmentCoordinator)
                
            case .tapDoctor(let parametrsDoctor):
                let tableDoctorCoordinator = TableViewDoctorCoordinator(navigationController:  controller.navigationController!, paramDoctor: parametrsDoctor,finishDelegate: self)
                tableDoctorCoordinator.start()
                self.childCoordinators.append(tableDoctorCoordinator)
                
            case .tapProfessions(let clinicId):
                
                let professionCoordinator =   ProfessionsCoordinator(navigationController: self.navigationController, clinicId: clinicId, finishDelegate: self)
                professionCoordinator.start()
                self.childCoordinators.append(professionCoordinator)

            case .tapCalendar:
                let calendarCoordinator = CalendarCoordinator(navigationController: self.navigationController, delegate: controller, finishDelegate: self)
                calendarCoordinator.start()
                self.childCoordinators.append(calendarCoordinator)

            }
            
            self.tabBarController.navigationController?.navigationBar.prefersLargeTitles = false
        }).disposed(by: disposeBag)
        
    }
    private func discountVCEvents(_ controller:DiscountTableVC) {
        controller.nvContent.subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .title(let text):
                controller.navigationItem.title = text
            }
        }).disposed(by: disposeBag)
    }
    
    private func settingsVSEvents(_ controller:SettingsTableVC) {
        controller.nvContent.subscribe(onNext: { [weak self] event in
            guard let self = self else { return }

            switch event {
            case .title(let title):
                controller.navigationItem.title = title
                
            case .tapLanguage:
                let languageCoordinator = LanguageCoordinator(navigationController: controller.navigationController!,finishDelegate: self)
                languageCoordinator.start()
                self.childCoordinators.append(languageCoordinator)

            case .tapServer:
                let cityCoordinator = CityCoordinator(navigationController: controller.navigationController!)
                cityCoordinator.finishDelegate = self
                cityCoordinator.start()
                self.childCoordinators.append(cityCoordinator)
                
            case .tapAboutUs:
                let aboutUsCoordinator = AboutUsCoordinator(navigationController: controller.navigationController!,finishDelegate: self)
                aboutUsCoordinator.start()
                self.childCoordinators.append(aboutUsCoordinator)

            case .prefersLargeTitles(let prefersLargeTitles):
                controller.navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
                
            case .tapPushNotification:
                let pushNotification = PushNotificationCoordinator(navigationController: controller.navigationController!,finishDelegate: self)
                pushNotification.start()
                self.childCoordinators.append(pushNotification)
                
            }
            
        }).disposed(by: disposeBag)
    }
    
}
