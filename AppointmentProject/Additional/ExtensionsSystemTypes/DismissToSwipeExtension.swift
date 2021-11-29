//
//  DismissToSwipeExtension.swift
//  AppointmentProject
//
//  Created by George on 09.10.2021.
//

import Foundation
import RxSwift
import RxCocoa

private let disposeBag = DisposeBag()


protocol SwipingViewControllerProtocol :UIGestureRecognizerDelegate {
    var viewController:UIViewController? { get set }
    var contentOffset: CGPoint? { get set }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

extension SwipingViewControllerProtocol  {
    func addSwipeGesture() {
        var viewTranslation = CGPoint(x: 0, y: 0)
        let swipeDismissGesture = UIPanGestureRecognizer()
        swipeDismissGesture.delegate = self
        swipeDismissGesture.cancelsTouchesInView = false
        
        swipeDismissGesture.rx.event.subscribe(onNext: { [weak self] gesture in
            guard let self = self else { return }
            self.handleDismiss(gesture,viewTranslation: &viewTranslation)
        }).disposed(by: disposeBag)
        viewController?.view.addGestureRecognizer(swipeDismissGesture)

    }
    
    private func handleDismiss(_ sender:UIPanGestureRecognizer,viewTranslation: inout CGPoint) {
        
        let viewTranslationCopy = viewTranslation
        guard let viewController = viewController else {
            return
        }
        if let contentOffset = self.contentOffset {
            
            if  contentOffset.y >= 1  || sender.translation(in: viewController.view).y < 0 {
                     return
                 }
        }
                
        switch sender.state {
            case .changed:
            viewTranslation = sender.translation(in: viewController.view)
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    viewController.navigationController!.view.transform = CGAffineTransform(translationX: 0, y: viewTranslationCopy.y)
                })
            case .ended:
                if viewTranslation.y < 300 {
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        viewController.navigationController!.view.transform = .identity
                    })
                } else {
                        viewController.dismiss(animated: true, completion: nil)
                }
            default:
                break
            }
    }
    
   

}
