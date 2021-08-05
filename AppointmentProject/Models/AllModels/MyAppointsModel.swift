//
//  MyAppointsModel.swift
//  AppointmentProject
//
//  Created by George on 02.08.2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


struct MyAppointmentsModel:Codable {
    var myAppoints:[MyAppointmentModel]
}

struct MyAppointmentModel: Codable {
    let name:String
    let subdivision:String
    let professions:String
    let appointmentId:String
    let time:String
    let centerId:String
    let docId:String
}

struct ModelAppointmentCell:ModelCell {
    let subdivision:String
    let doctorName:String
    let doctorProfession:String
    let appointmentID:String
    let centerId:String
    let docId:String

}

struct ModelCellPosition {
    let topY:CGFloat
    let indexPath:IndexPath
}

enum SelectAction {
    case delete
    case goToDoctor
}
