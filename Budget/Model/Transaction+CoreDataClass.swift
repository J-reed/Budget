//
//  Transaction+CoreDataClass.swift
//  Budget
//
//  Created by Justin Reed on 14/02/2023.
//
//

import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject,Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var balance: Int64
    @NSManaged public var date: Date
    @NSManaged public var dayTransactionNumber: Int16
    @NSManaged public var id: UUID
    @NSManaged public var paidIn: Int64
    @NSManaged public var paidOut: Int64
    @NSManaged public var transactionDescription: String
    @NSManaged public var transactionType: String
    @NSManaged public var fromFile: File
    @NSManaged public var transactionAccountHolder: AccountHolder
    @NSManaged public var associatedAccount: Account
    

}
