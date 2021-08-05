//
//  Extensions.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import Foundation

extension String {
    
    func cutString(from:Int,to:Int) -> String {
        var finishString = ""
        for (index , value) in self.enumerated() {
            if index >= from && index <= to {
                finishString.append(value)
            }
        }
       return finishString
    }
}

 // encode struct to data and data to struct
func getDataFromPacket<EncodeType:Codable>(packet: EncodeType) -> Data? {
  do{
    let data = try PropertyListEncoder.init().encode(packet)
    return data
  }catch let error as NSError{
    print(error.localizedDescription)
  }
    return nil
}

func getPacketFromData<EncodeType:Codable>(data: Data) -> EncodeType? {
    do{
      let packet = try PropertyListDecoder.init().decode(EncodeType.self, from: data)
      return packet
    }catch let error as NSError {
      print(error.localizedDescription)
    }
    return nil
}

extension Date {
    
    func stringDF() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"
        df.locale = Locale.init(identifier: "ru_RU")
        return df.string(from: self)
    }
        
    func stringDateSpase() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale.init(identifier: "ru_RU")
        return df.string(from: self)
    }
    
    func stringDate(by:String) -> String {
        let df = DateFormatter()
        df.dateFormat = by
        df.locale = Locale.init(identifier: "ru_RU")
        return df.string(from: self)
    }
    
}
extension String {
    func dateSpace() -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        df.locale = Locale.init(identifier: "ru_RU")
        
        return df.date(from: self)
    }
}
