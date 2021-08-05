//
//  RefreshVC.swift
//  AppointmentProject
//
//  Created by George on 31.07.2021.
//

import UIKit

class ActivityVC: UIViewController {
    let activity = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Present")
        activity.center = view.center
        self.view.addSubview(activity)
        activity.startAnimating()
    }
    
}
