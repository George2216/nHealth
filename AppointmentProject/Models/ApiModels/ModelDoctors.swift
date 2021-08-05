//
//  ModelDoctors.swift
//  AppointmentProject
//
//  Created by George on 17.07.2021.
//

import Foundation
import XMLCoder

struct DoctorsModel:Codable {
    let Doctor:[ParamDoctor]
}

struct ParamDoctor: Codable {
    let id:String
    let name:String
    let CenterId:String
    let SpecId:[SpecData]
}

struct SpecData: Codable , DynamicNodeDecoding {
    let name:String
    let value:String
    
    enum CodingKeys :String, CodingKey{
        case name
        case value = ""
    }
    
    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        
        switch key {
        case CodingKeys.value:

            return .element
        case CodingKeys.name:
            return .attribute
        default:
            return .elementOrAttribute
        }
    }
    
}

