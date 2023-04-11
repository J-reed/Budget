//
//  Groups+CoreDataClass.swift
//  Budget
//
//  Created by Justin Reed on 11/04/2023.
//
//

import Foundation
import CoreData

@objc(Groups)
public class Groups: NSManagedObject,Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Groups> {
        return NSFetchRequest<Groups>(entityName: "Groups")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var members: [String]?
}
