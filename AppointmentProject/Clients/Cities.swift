//
//  Cities.swift
//  AppointmentProject
//
//  Created by George on 09.10.2021.
//

import Foundation


struct Poltava:CityProtocol  {
    var nameKey: LocalizeString = .poltava
    var clinics:[ClinicProtocol] = []
    init() {
        clinics.append(addClinic(.Optimal))
        clinics.append(addClinic(.MedBeauty))
        clinics.append(addClinic(.Elitmed))
        clinics.append(addClinic(.Ideal))

    }
    
    private func addClinic(_ clinic:PoltavaClinics) -> ClinicProtocol {
        switch clinic {
        case .Optimal:
            return Optimal()
        case .MedBeauty:
            return MedBeauty()
        case .Elitmed:
            return Elitmed()
        case .Ideal:
            return Ideal()
        }
    }
    
    private enum PoltavaClinics {
    case Optimal
    case MedBeauty
    case Ideal
    case Elitmed
    }
}

struct Kyiv:CityProtocol  {
    
    var nameKey:LocalizeString = .kyiv
    var clinics:[ClinicProtocol] = []
    
    init() {
        clinics.append(addClinic(.Vivendi))

    }
    
    private func addClinic(_ clinic:KyivClinics) -> ClinicProtocol {
        switch clinic {
        case .Vivendi:
            return Vivendi()
        }
    }
    
    private enum KyivClinics {
    case Vivendi
    }
}

struct Kharkiv:CityProtocol {
    var nameKey:LocalizeString = .kharkiv
    var clinics: [ClinicProtocol] = []
    init() {
        clinics.append(addClinic(.Orlenok))

    }
    private func addClinic(_ clinic: KharkivClinics) -> ClinicProtocol {
        switch clinic {
        case .Orlenok:
            return Orlenok()
       
        }
    }
    
    private enum KharkivClinics {
    case Orlenok
    }
}

struct Odessa:CityProtocol {
    var nameKey:LocalizeString = .odessa
    var clinics: [ClinicProtocol] = []
    init() {
        clinics.append(addClinic(.dentalCenter))
    }
    private func addClinic(_ clinic: OdessaClinics) -> ClinicProtocol {
        switch clinic {
        case .dentalCenter:
            return DentalCenter()
       
        }
    }
    private enum OdessaClinics {
        case dentalCenter
    }
}

struct Zaporizhzhia:CityProtocol {
    var nameKey: LocalizeString = .zaporizhzhia
    var clinics: [ClinicProtocol] = []
    
    init() {
        clinics.append(addClinic(.ZSMU))
    }
    
    private func addClinic(_ clinic: ZaporizhzhiaClinics) -> ClinicProtocol {
        switch clinic {
        case .ZSMU:
            return ZSMU()
       
        }
    }
    private enum ZaporizhzhiaClinics {
        case ZSMU
    }
    
}
