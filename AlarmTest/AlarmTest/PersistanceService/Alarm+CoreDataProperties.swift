//
//  Alarm+CoreDataProperties.swift
//  AlarmTest
//
//  Created by Rdm on 21/05/2022.
//
//

import Foundation
import CoreData


extension Alarm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Alarm> {
        return NSFetchRequest<Alarm>(entityName: "Alarm")
    }

    @NSManaged public var awakeTime: Date
    @NSManaged public var id: String
    @NSManaged public var isActive: Bool
    @NSManaged public var labelText: String
    @NSManaged public var repetition: String
    
    public static func alarmRepetitionStringToArray(repetitionString: String) -> [String] {
        let repetitionDaysArray: [String] = repetitionString.components(separatedBy: "/")
        return repetitionDaysArray
    }
    
}

extension Alarm : Identifiable {

}
