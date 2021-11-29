//
//  AboutUsVC.swift
//  AppointmentProject
//
//  Created by George on 07.08.2021.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
final class AboutUsVC: UIViewController, WKNavigationDelegate , SwipingViewControllerProtocol{
   
    var viewController: UIViewController?
    var contentOffset: CGPoint?
    
    internal let nvContent = PublishSubject<Event>()

    private var webView:WKWebView!
    private let disposeBag = DisposeBag()
    private let viewModel = AboutUsViewModel()
    private let tapClose = PublishSubject<Void>()
    
    // webview actions
    private let tapFroward = PublishSubject<Void>()
    private let tapBack = PublishSubject<Void>()
    private let tapRefresh = PublishSubject<Void>()
    private let isCanGoBack = BehaviorSubject<Bool>(value: false)
    private let isCanGoForward = BehaviorSubject<Bool>(value: false)
    private lazy var webViewOffset:Observable<CGPoint> = {
        return webView.scrollView.rx.contentOffset.asObservable()
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        didFinishLoadWebView()
        
        let output = viewModel.transform(AboutUsViewModel.Input(tapClose: tapClose,tapFroward:tapFroward,tapBack:tapBack,tapRefresh:tapRefresh,isCanGoBack:isCanGoBack,isCanGoForward:isCanGoForward, webViewOffset: webViewOffset))
        navigationSetting(output)
        createWebView(output)
        validOffset(output)
        output.dismissSelf.drive(onNext: dismissSelf).disposed(by: disposeBag)
        output.goBack.drive(onNext:goBack).disposed(by: disposeBag)
        output.goForward.drive(onNext:goForvard).disposed(by: disposeBag)
        output.refresh.drive(onNext:refreshWebView).disposed(by: disposeBag)
        tapBackButton()

    }
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        viewController = self
        self.contentOffset = webView.scrollView.contentOffset
        self.addSwipeGesture()
    }
   
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        nvContent.onNext(.finish)
    }
    private func navigationSetting(_ output:AboutUsViewModel.Output) {
        output.backButtonTitle.drive(onNext:{ backButtonTitle in
            let backButton = UIBarButtonItem(title: backButtonTitle, style: .done, target: nil, action: nil)
            self.nvContent.onNext(.backButton(backButton))
        }).disposed(by: disposeBag)
                
        // WebView buttons
        let forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: nil, action: nil)
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: nil, action: nil)
        let refreshButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: nil, action: nil)
        
        // isEnubled
        output.goForwargIsEnuble.drive(forwardButton.rx.isEnabled).disposed(by: disposeBag)
        output.goBackIsEnuble.drive(backButton.rx.isEnabled).disposed(by: disposeBag)
        
        // subscribe on actions
        forwardButton.rx.tap.subscribe(tapFroward).disposed(by: disposeBag)
        backButton.rx.tap.subscribe(tapBack).disposed(by: disposeBag)
        refreshButton.rx.tap.subscribe(tapRefresh).disposed(by: disposeBag)
        
        nvContent.onNext(.navItems([forwardButton,backButton,refreshButton]))
    }
    
    private func goForvard() {
        webView.goForward()
    }
    private func goBack() {
        webView.goBack()
    }
    private func refreshWebView() {
        webView.reload()
    }
    private func tapBackButton() {
        navigationItem.leftBarButtonItem?.rx.tap.subscribe(tapClose).disposed(by: disposeBag)
    }
    private func dismissSelf() {
        nvContent.onNext(.finishDismiss)
    }
    
    private func validOffset(_ output:AboutUsViewModel.Output) {
        output.scrolablePoint.drive(onNext: {[weak self] point in
            guard let self = self else { return }
            self.contentOffset = point
        }).disposed(by: disposeBag)
    }
    
    private func createWebView(_ output:AboutUsViewModel.Output) {
        output.webViewRequest.drive(onNext:{ [self] request in
            webView.load(request)
            webView.allowsBackForwardNavigationGestures = true
        }).disposed(by: disposeBag)
    }
    private func didFinishLoadWebView() {
        webView.rx.didFinishLoad.subscribe(onNext: {[self] _ in
            isCanGoForward.onNext(webView.canGoForward)
            isCanGoBack.onNext(webView.canGoBack)
        }).disposed(by: disposeBag)
    }
    
    
    
}
// events
extension AboutUsVC {
    enum Event {
        case backButton(_ button:UIBarButtonItem)
        case navItems(_ items:[UIBarButtonItem])
        case finish
        case finishDismiss
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
