//
//  SpecialtyListModel.swift
//  AppointmentProject
//
//  Created by George on 20.07.2021.
//

import Foundation

struct SpecialtyListModel:Codable {
    let Specialty:[Specialty]
}

struct Specialty:Codable, SpecialtyProtocol {
    var id: String
    var name: String
    
  
}

protocol SpecialtyProtocol {
    var id:String { get  set }
    var name:String { get  set}
}
