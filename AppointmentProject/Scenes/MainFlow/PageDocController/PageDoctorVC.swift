//
//  PageDoctorVC.swift
//  AppointmentProject
//
//  Created by George on 25.08.2021.
//

import UIKit
import RxSwift
import RxCocoa



class PageDoctorVC: UIPageViewController {
    private let disposeBag = DisposeBag()
    private let imagesIds = BehaviorRelay<[String]>(value: ["Без названия (2)","im2","im3","im4"])
    private let viewModel = PageDoctorViewModel()
    private let displayedVCIndex = BehaviorRelay<Int>(value: 0)
    private let tapViewAction = PublishSubject<Void>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        let optionsDict = [UIPageViewController.OptionsKey.interPageSpacing: 40]
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: optionsDict)
        self.view.backgroundColor = .black
        let output = viewModel.transform(PageDoctorViewModel.Input(tapViewAction: tapViewAction))
        delegate = self
        dataSource = self
        firsPageVC()
        createTapView()
        showAndHideNavBar(output)

    }
    private func createTapView() {
        self.view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tap)
        
        tap.rx.event.subscribe(onNext:{ _ in
            self.tapViewAction.onNext(())
        }).disposed(by: disposeBag)
}
   
    
    private func firsPageVC() {
        let rootVC = ImageController.instantiate()
        rootVC.imageId.accept(imagesIds.value[0])
        setViewControllers([rootVC], direction: .forward, animated: true, completion: nil)
    }
    
    private func showAndHideNavBar(_ output: PageDoctorViewModel.Output) {
        output.isShowBarFlag.drive(onNext: { flag in
            self.navigationController?.setNavigationBarHidden(flag, animated: true)
        }).disposed(by: disposeBag)

    }

    required init?(coder: NSCoder) {
        fatalError("")
    }
}


extension PageDoctorVC : UIPageViewControllerDelegate , UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
       let vc =  viewController as! ImageController
        if let index = imagesIds.value.firstIndex(of: vc.imageId.value)  {
            if index > 0 {
                let next = ImageController.instantiate()
                next.imageId.accept(imagesIds.value[index - 1])
          return next
            } else {
            return nil
            }
        } else {
            return nil
    }
}
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let vc =  viewController as! ImageController
         if let index = imagesIds.value.firstIndex(of: vc.imageId.value)  {
            if imagesIds.value.count - 1 > index {
                 let next = ImageController.instantiate()
                 next.imageId.accept(imagesIds.value[index + 1])
           return next
             } else {
             return nil
             }
         } else {
             return nil
     }
    }
    
    func presentationCount(for: UIPageViewController) -> Int {
        
        return 3
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 2
    }
    
   
}

