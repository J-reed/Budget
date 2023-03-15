//
//  AccountHolder+CoreDataClass.swift
//  Budget
//
//  Created by Justin Reed on 14/02/2023.
//
//

import Foundation
import CoreData

@objc(AccountHolder)
public class AccountHolder: NSManagedObject,Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountHolder> {
        return NSFetchRequest<AccountHolder>(entityName: "AccountHolder")
    }

    @NSManaged public var accountHolderName: String
    @NSManaged public var id: UUID
    @NSManaged public var transactions: Transaction

}
