//
//  SlotsByDocDay.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import Foundation
struct SlotsByDocDayModell:Codable {
   var name = ""
   var doctorName = ""
   var doctorId = ""
   var date = ""
   var window:[Window] = []
}

struct Window:Codable {
  var start = ""
  var end = ""
  var roomId = ""
}
