//
//  File+CoreDataProperties.swift
//  Budget
//
//  Created by Justin Reed on 13/02/2023.
//
//

import Foundation
import CoreData

@objc(File)
public class File: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<File> {
        return NSFetchRequest<File>(entityName: "File")
    }

    @NSManaged public var fileName: String
    @NSManaged public var filePath: String
    @NSManaged public var id: UUID

}
