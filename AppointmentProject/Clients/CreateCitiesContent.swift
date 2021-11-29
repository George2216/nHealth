//
//  CreateCitiesContent.swift
//  AppointmentProject
//
//  Created by George on 09.10.2021.
//

import Foundation

protocol CityProtocol {
    var nameKey:LocalizeString { get }
    var clinics:[ClinicProtocol] { get set }
}

protocol ClinicProtocol {
    var name:String { get }
    var urlString:String { get }
    var token:String { get }
}



struct Cities {
    static let shared = Cities()
    private(set) var cities:[CityProtocol] = []
   
    private func createCity(_ city:City) -> CityProtocol {
        switch city {
        case .Poltava:
            return Poltava()
        case .Kyiv:
            return Kyiv()
        case .Kharkiv:
            return Kharkiv()
        case .Odessa:
            return Odessa()
        }
    }
    init() {
        cities.append(createCity(.Poltava))
        cities.append(createCity(.Kyiv))
        cities.append(createCity(.Kharkiv))
        cities.append(createCity(.Odessa))
    }
    
    private enum City {
    case Poltava
    case Kyiv
    case Kharkiv
    case Odessa
    }
}
