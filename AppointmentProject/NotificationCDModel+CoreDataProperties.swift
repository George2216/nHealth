//
//  NotificationCDModel+CoreDataProperties.swift
//  
//
//  Created by George on 21.10.2021.
//
//

import Foundation
import CoreData


extension NotificationCDModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationCDModel> {
        return NSFetchRequest<NotificationCDModel>(entityName: "NotificationCDModel")
    }

    @NSManaged public var isUsed: Bool
    @NSManaged public var textKey: String?
    @NSManaged public var vibration: NotificationCDSettings?
    @NSManaged public var sound: NotificationCDSettings?
    @NSManaged public var cancellation: NotificationCDSettings?
    @NSManaged public var receive: NotificationCDSettings?
    @NSManaged public var completion: NotificationCDSettings?

}
