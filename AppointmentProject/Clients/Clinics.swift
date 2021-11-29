//
//  Clinics.swift
//  AppointmentProject
//
//  Created by George on 09.10.2021.
//

import Foundation

struct Optimal: ClinicProtocol {
    var name: String = "Optimal"
    var urlString: String = "82.117.240.50/toothfairyhost/optimal"
    var token: String = "EEF4B03D-C023"
}

struct MedBeauty: ClinicProtocol {
    var name: String = "MedBeauty"
    var urlString: String = "82.117.240.50:9008/client/poltava_medbeauty"
    var token: String = "A36B6C70-FDC1"
}

struct Vivendi: ClinicProtocol {
    var name: String = "Vivendi"
    var urlString: String = "82.117.240.50/toothfairyhost/kiev_vivendi"
    var token: String = "059ECB6C-49D0"
}

struct Orlenok:ClinicProtocol {
    var name: String = "Orlenok"
    var urlString: String = "82.117.240.50/toothfairyhost/kiev_orlenok"
    var token: String = "0C6A863E-663C"
}

struct Ideal:ClinicProtocol {
    var name: String = "Идеал"
    var urlString: String = "159.224.182.50:81"
    var token: String = "8E56528E-A7DA"
}

struct Elitmed:ClinicProtocol {
    var name: String = "Elitmed+"
    var urlString: String = "93.78.207.140:81"
    var token: String = "FB4E9E6A-C972"
}

struct DentalCenter:ClinicProtocol {
    var name: String = "Dental center \n(Odesa's first private)"
    var urlString: String = "185.168.131.153/odessa_first"
    var token: String = "2A974C89-230D"
}



