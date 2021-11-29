//
//  RxExtensions.swift
//  AppointmentProject
//
//  Created by George on 31.10.2021.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}

extension Reactive where Base: NotificationCenter {
    /**
    Transforms notifications posted to notification center to observable sequence of notifications.
    
    - parameter name: Optional name used to filter notifications.
    - parameter object: Optional object used to filter notifications.
    - returns: Observable sequence of posted notifications.
    */
    public func notification(_ name: Notification.Name?, object: AnyObject? = nil) -> Observable<Notification> {
        return Observable.create { [weak object] observer in
            let nsObserver = self.base.addObserver(forName: name, object: object, queue: nil) { notification in
                observer.on(.next(notification))
            }
            
            return Disposables.create {
                self.base.removeObserver(nsObserver)
            }
        }
    }
}
