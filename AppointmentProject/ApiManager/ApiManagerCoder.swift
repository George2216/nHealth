//
//  ApiManagerCoder.swift
//  AppointmentProject
//
//  Created by George on 16.07.2021.
//

import Foundation
import XMLCoder
import RxSwift
import RxCocoa


class XMLMultiCoder<Output:Codable> {
    
    private func getUrlPath() -> String {
       
        return SingletonData.shared.defaultUrlPath
    }
    func parsData<Input:Codable>(input:Input?,metod:Metod ,phpFunc:PHPFunc, ecodeParam:EncodeParam) -> Observable<(Output?,String?)> {
        return Observable<(Output?,String?)>.create { [self] observable in

            let url = URL(string: "http://\(getUrlPath())/toothfairy/services/api/APIDocUA.php?func=\(phpFunc.rawValue)")!
            
            var request = URLRequest(url: url)

            do {
                let httpBody = try XMLEncoder().encode(input, withRootKey: ecodeParam.withRootKey, rootAttributes: ecodeParam.rootAttributes, header: ecodeParam.header)
                request.httpBody = httpBody
            } catch {
                observable.onNext((nil, nil))
                
            }
                request.httpMethod = metod.rawValue
                request.setValue("text/xml", forHTTPHeaderField: "Content-Type") // I guess this can be "text/xml"

                let task =  URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                if let output = try?  XMLDecoder().decode(Output.self, from: data ?? Data()) {
                    
                    observable.onNext((output,nil))
                } else if let string = try?  XMLDecoder().decode(String.self, from: data ?? Data()) {
                    observable.onNext((nil,string))
                } else {
                    observable.onNext((nil,nil))
                }
            }

           }
                task.resume()
            
            return Disposables.create {
                task.cancel()
                }
            }
        }
    }


enum Metod :String {
case POST
case GET
}

enum PHPFunc:String {
case DoctorList
case SlotsByDocDay
case CenterList
case SpecialtyList
case ServicesList
case Appointment
case CancelAppointment
}

struct EncodeParam {
    let withRootKey:String?
    let rootAttributes:[String : String]?
    let header:XMLHeader?
}

