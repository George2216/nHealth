//
//  SlotsByDocDayModel.swift
//  AppointmentProject
//
//  Created by George on 18.07.2021.
//

import Foundation

struct SlotsByDocDayModel: Codable {
    
    let Windows:[WindowsModel]
}

struct WindowsModel: Codable {
    let name:String
    let DoctorName:String
    let DoctorId:String
    let Date:String
    let Window:[WindowModel]
}

struct WindowModel :Codable{
    let Start:String
    let End:String
    let RoomId:String
}
