//
//  NotificationCDSettings+CoreDataProperties.swift
//  
//
//  Created by George on 21.10.2021.
//
//

import Foundation
import CoreData


extension NotificationCDSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationCDSettings> {
        return NSFetchRequest<NotificationCDSettings>(entityName: "NotificationCDSettings")
    }

    @NSManaged public var receive: NotificationCDModel?
    @NSManaged public var sound: NotificationCDModel?
    @NSManaged public var vibration: NotificationCDModel?
    @NSManaged public var completion: NotificationCDModel?
    @NSManaged public var cancellation: NotificationCDModel?

}
