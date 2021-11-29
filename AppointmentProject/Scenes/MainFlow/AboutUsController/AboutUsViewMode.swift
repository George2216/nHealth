//
//  AboutUsViewMode.swift
//  AppointmentProject
//
//  Created by George on 07.08.2021.
//

import Foundation
import RxSwift
import RxCocoa
extension AboutUsViewModel {
    private var  dismissSelfDriver:Driver<Void> {
        return dismissSelf.asDriverOnErrorJustComplete()
    }
    private var backButtonTitle:Driver<String> {
        return Localizable.localize(.close).asDriverOnErrorJustComplete()
    }
    private var goBackIsEnubleDriver:Driver<Bool> {
        return goBackIsEnuble.asDriverOnErrorJustComplete()
    }
    private var goForwargIsEnubleDriver:Driver<Bool> {
        return goForwargIsEnuble.asDriverOnErrorJustComplete()
    }
    private var goBackDriver:Driver<Void> {
        return goBack.asDriverOnErrorJustComplete()
    }
    private var goForwardDriver:Driver<Void> {
        return goForward.asDriverOnErrorJustComplete()
    }
    private var refreshDriver:Driver<Void> {
        return refresh.asDriverOnErrorJustComplete()
    }
    
    private var webViewRequestDriver:Driver<URLRequest> {
        return webViewRequest.asDriver(onErrorJustReturn: URLRequest(url: URL(string: "https://www.google.com/")!))
    }
    private var scrolablePointDriver:Driver<CGPoint> {
        return scrolablePoint.asDriverOnErrorJustComplete()
    }
}

final class AboutUsViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()

    private let dismissSelf = PublishSubject<Void>()
    
    private let goBackIsEnuble = BehaviorSubject<Bool>(value: false)
    private let goForwargIsEnuble = BehaviorSubject<Bool>(value: false)
    private let goBack = PublishSubject<Void>()
    private let goForward = PublishSubject<Void>()
    private let refresh = PublishSubject<Void>()
    private let webViewRequest = BehaviorSubject<URLRequest>(value: URLRequest(url:URL(string:  SingletonData.shared.webViewPath)!))
    private let scrolablePoint = PublishSubject<CGPoint>()
    func transform(_ input: Input) -> Output {
        input.tapClose.subscribe(dismissSelf).disposed(by: disposeBag)
        input.isCanGoBack.subscribe(goBackIsEnuble).disposed(by: disposeBag)
        input.isCanGoForward.subscribe(goForwargIsEnuble).disposed(by: disposeBag)
        input.tapBack.subscribe(goBack).disposed(by: disposeBag)
        input.tapFroward.subscribe(goForward).disposed(by: disposeBag)
        input.tapRefresh.subscribe(refresh).disposed(by: disposeBag)
        input.webViewOffset.subscribe(scrolablePoint).disposed(by: disposeBag)
        
        return  Output(dismissSelf: dismissSelfDriver, backButtonTitle: backButtonTitle, goBackIsEnuble: goBackIsEnubleDriver,goForwargIsEnuble:goForwargIsEnubleDriver,goBack:goBackDriver,goForward:goForwardDriver, refresh: refreshDriver, webViewRequest: webViewRequestDriver, scrolablePoint: scrolablePointDriver)
    }
    

    
    struct Input {
        let tapClose:Observable<Void>
        let tapFroward:Observable<Void>
        let tapBack:Observable<Void>
        let tapRefresh:Observable<Void>
        let isCanGoBack:Observable<Bool>
        let isCanGoForward:Observable<Bool>
        let webViewOffset:Observable<CGPoint>
    }
    struct Output {
        let dismissSelf:Driver<Void>
        let backButtonTitle:Driver<String>
        let goBackIsEnuble:Driver<Bool>
        let goForwargIsEnuble:Driver<Bool>
        let goBack:Driver<Void>
        let goForward:Driver<Void>
        let refresh:Driver<Void>
        let webViewRequest:Driver<URLRequest>
        let scrolablePoint:Driver<CGPoint>

    }
    
}
