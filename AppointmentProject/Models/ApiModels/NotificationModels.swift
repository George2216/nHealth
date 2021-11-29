//
//  NotificationModels.swift
//  AppointmentProject
//
//  Created by George on 22.10.2021.
//

import Foundation
struct NotificationSettingsModel:Codable {
    var sound: Bool
    var completion: Bool
    var cancellation: Bool
}
struct ChangeSwitchCaseModel {
    let indexPath:IndexPath
    let isOn:Bool
}
