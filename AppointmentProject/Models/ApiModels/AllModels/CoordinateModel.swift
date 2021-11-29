//
//  CoordinateModel.swift
//  AppointmentProject
//
//  Created by George on 09.09.2021.
//

import Foundation
struct CoordinateModel {
    let latitude:String
    let longitude:String
    let title:String
    let subtitle:String
    
    init() {
        latitude = ""
        longitude = ""
        title = ""
        subtitle = ""
    }
    init(latitude:String,longitude:String,title:String,subtitle:String) {
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.subtitle = subtitle
    }
}
