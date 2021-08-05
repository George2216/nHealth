//
//  CenterListModel.swift
//  AppointmentProject
//
//  Created by George on 17.07.2021.
//

import Foundation

struct CentersListModel: Codable  {
    let Center:[CenterListModel]
}

struct CenterListModel:Codable {
    let id:String
    let name:String
    let city:String
    let address:String
    let longitude:String
    let latitude:String
    let is_main:String
}

