//
//  JsonApiManager.swift
//  AppointmentProject
//
//  Created by George on 11.11.2021.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import UIKit

// whith empty output
struct EmptyAnsver :Codable { }


private let firebaseToken = "key=AAAAH5rk2y4:APA91bEWeialpWDrzG0FIhT5iUGkU_LmkTtaH-lfwxYxqSsdTGLr5viLyfZ0gG0P8qBS6PDmjL_6HxIB4jsVoA_Mts1YLPF27d1UzbValFPNrulGBBUCdvE727f2XGYfb_PLwrg6vQEa"

class JsonApiManager {
    
    private var deviseToken:String {
        guard let token =  UserDefaults.standard.value(forKey: UDKeys.pushNotificationToken.rawValue) as? String  else { return " " }
        return token
    }
    
    
    func send<Input,Output:Codable>(parametrs:Request,data:Input?) -> Observable<Output?> where Input : Encodable    {
        
        return Observable<Output?>.create { observer in
            var request = parametrs.request
            if let postData:Data = try? JSONEncoder().encode(data) , !(data is EmptyAnsver) {
            request.httpBody = postData
            }
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    do {
                    let model = try JSONDecoder().decode(Output.self, from: data ?? Data())
                    observer.onNext(model)
                        
                } catch {
                    observer.onNext(nil)
                }
                    observer.onCompleted()
            }
        }
                task.resume()
                return Disposables.create {
                    task.cancel()
                }
        }
    }
        
    
    
    
    
    enum Request {
        case pushNotification
        case stosks
        var request:URLRequest {
            switch self {
                
            case .pushNotification:
                let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.allHTTPHeaderFields = ["Content-Type":"application/json","Authorization":firebaseToken]
                return request
                
            case .stosks:
                let url = URL(string: "https://api.preprod.ehealth.vikisoft.kiev.ua/v1/promotion")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = ["Content-Type":"application/json","Authorization":"Bearer c2778f3064753ea70de870a53795f5c9","API-key":"uXhEczJ56adsfh3Ri9SUkc4en","box-token":"rerqwrqwerqwerqewrqwer"]
                return request            }
            
        }
    }
    
    
}


struct DiscountModel:Codable {
    let data:[DiscountItemModel]
}
struct DiscountItemModel:Codable {
    let id:Int
    let name:String
    let slogan:String
    let description:String
    let price:Int
    let status:String
}
