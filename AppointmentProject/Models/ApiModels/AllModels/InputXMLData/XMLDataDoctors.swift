//
//  XMLDataDoctors.swift
//  AppointmentProject
//
//  Created by George on 17.07.2021.
//

import Foundation

// Inputs xml
struct InputModelDoctors:Codable {
    let Token :String
    let CenterId:String
}


struct InputModelSlots: Codable { 
    let Token :String
    let CenterId:String
    let Date:String
    let DoctorId:String
    let Duration:String

}

struct InputModelCentersList :Codable{
    let Token :String
}

struct InputServicesList :Codable{
    let Token :String
    let CenterId:String
}

// appointment models
struct InputAppointmentModel :Codable{
    let Token :String
    let CenterId:String
    let Data:InputAppointmentModelContent
}

struct InputAppointmentModelContent :Codable {
    let DoctorId:String
    let RoomId:String
    let FullName:String
    let StartTime:String
    let Phone:String
    let Duration:String
}

struct InputCancelAppointmentModel:Codable {
    let Token :String
    let CenterId:String
    let AppointmentId:String
}
