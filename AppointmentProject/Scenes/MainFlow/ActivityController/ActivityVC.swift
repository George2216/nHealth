//
//  RefreshVC.swift
//  AppointmentProject
//
//  Created by George on 31.07.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class ActivityVC: UIViewController {
    internal let nvContent = PublishSubject<Event>()
    private let activity = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.center = view.center
        self.view.addSubview(activity)
        activity.startAnimating()
    }

    override func viewDidDisappear(_ animated: Bool) {
       super.viewDidDisappear(animated)
        nvContent.onNext(.finish)
    }
   
}

extension ActivityVC {
    enum Event {
        case finish
    }
}

