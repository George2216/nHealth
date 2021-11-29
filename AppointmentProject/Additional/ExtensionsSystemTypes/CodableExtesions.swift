//
//  CodableExtesions.swift
//  AppointmentProject
//
//  Created by George on 30.10.2021.
//

import Foundation
extension Encodable {
    
    func saveSelfData(for key:UDKeys)  {
      do{
          let data = try PropertyListEncoder.init().encode(self)
          UserDefaults.standard.setValue(data, forKey: key.rawValue)
      } catch let error as NSError{
        print(error.localizedDescription)
      }
    }
}

extension Decodable {
   static func getData(for key:UDKeys) -> Self? {
        do{
            let data =  UserDefaults().data(forKey:key.rawValue)
            guard let binaryData = data else { return nil }

            let packet = try PropertyListDecoder.init().decode(Self.self, from: binaryData)
          return packet
        }catch let error as NSError {
          print(error.localizedDescription)
        }
        return nil
    }
}

extension Decodable {
    static var none:EmptyAnsver {
        return EmptyAnsver()
    }
}
