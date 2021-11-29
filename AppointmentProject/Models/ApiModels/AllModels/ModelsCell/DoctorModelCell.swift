//
//  DoctorModelCell.swift
//  AppointmentProject
//
//  Created by George on 16.07.2021.
//

import Foundation
struct DoctorModelCell : Hashable {
    let docId:String
    let name:String
    let profession:String
    var arrayCollection:[TimeSlotModel]
}

struct TimeSlotModel:Hashable {
    let time:String
}
