//
//  InitialTableVCDelegates.swift
//  AppointmentProject
//
//  Created by George on 06.11.2021.
//

import Foundation
import UIKit
protocol CalendarDateProtocol: AnyObject {
    func selectDate(_ date:Date)
}

protocol SearchTableSelectedDelegate: AnyObject {
    func selectDoctor(for index:Int)
}
