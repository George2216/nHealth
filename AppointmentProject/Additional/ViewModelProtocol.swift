//
//  ViewModelProtocol.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import Foundation

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    func transform(_ input:Input) -> Output
}

protocol InvilideImlProtocol {
    var stringOutput:String { get set }
}
