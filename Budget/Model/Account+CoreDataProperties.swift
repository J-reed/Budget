//
//  Account+CoreDataProperties.swift
//  Budget
//
//  Created by Justin Reed on 13/02/2023.
//
//

import Foundation
import CoreData

@objc(Account)
public class Account: NSManagedObject, Identifiable{

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var accountName: String
    @NSManaged public var id: UUID
    
}


