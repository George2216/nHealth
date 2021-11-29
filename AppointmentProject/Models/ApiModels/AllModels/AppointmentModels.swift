//
//  AppointmentModels.swift
//  AppointmentProject
//
//  Created by George on 29.07.2021.
//

import Foundation

struct AppointmentModel {
    let doctor:AppointmentDoctor
    let appointmentLockation:AppointmentCenter
    let appointmentTime:AppointmentTime
    init() {
        self.doctor = AppointmentDoctor(id: "", name: "", professions: "")
        self.appointmentLockation = AppointmentCenter(id: "", latitude: "", longitude: "", name: "", city: "", adress: "")
        self.appointmentTime = AppointmentTime(time: "", roomId: "")

    }
    
    init(doctor:AppointmentDoctor,appointmentLockation:AppointmentCenter,appointmentTime:AppointmentTime) {
        self.doctor = doctor
        self.appointmentLockation = appointmentLockation
        self.appointmentTime = appointmentTime

    }
    
}

struct AppointmentDoctor {
    let id:String
    let name:String
    let professions:String
}

struct AppointmentCenter {
    let id:String
    let latitude:String
    let longitude:String
    let name:String
    let city:String
    let adress:String
}

struct AppointmentTime {
    let time:String
    let roomId:String
}
