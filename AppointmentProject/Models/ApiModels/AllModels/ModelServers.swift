//
//  ModelServers.swift
//  AppointmentProject
//
//  Created by George on 09.08.2021.
//

import Foundation
struct ModelServers: Codable {
    let arrayServers:[ModelServer]
    
}
struct ModelServer :Codable {
    var isSelected:Bool
    let contentText:String
}
