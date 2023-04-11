//
//  CSV_Parser.swift
//  Budget
//
//  Created by Justin Reed on 14/02/2023.
//

import Foundation
import SwiftUI

enum StatementFileDataFormats {
    case format_1
}


struct CSVDataLocation {
    let accountNameLocation: Int
    let accountBalanceLocation: Int
    let availableBalanceLocation: Int
    let transactionDateLocation: Int
    let transactionTypeLocation: Int
    let transactionDescriptionLocation: Int
    let transactionPaidOutLocation: Int
    let transactionPaidInLocation: Int
    let transactionBalanceLocation: Int
    let noColumnsPerTransaction: Int
    let transactionsStartLocation: Int
}

struct CSVData {
    var accountName: String
    var accountBalance: Int
    var availableBalance: Int
    
    var transactions: [TransactionRecord]
    
}

struct TransactionRecord {
    let date: Date
    let transactionType: String
    let description: String
    let paidOut: Int
    let paidIn: Int
    let balance: Int
}

func loadCSV(knownCSVFiles: FetchedResults<File>, knownAccounts: FetchedResults<Account>){
    
    // Get CSV name & path
    let (csvName, csvPath) = letUserPickCSVFile()
    
    // If the user didn't select a file move on else step into this scope
    guard let csvName = csvName else { print("CSV file not added because: CSV name not set"); return }
    guard let csvPath = csvPath else { print("CSV file not added because: CSV path not set"); return }

    // Check if CSV File is already known to the app
    var csvFileAlreadyKnown: Bool = false
    for file in knownCSVFiles{
        if file.filePath == csvPath{
            csvFileAlreadyKnown = true
            break
        }
    }
    
    // If the file is known already do nothing, else step into this scope
    guard !csvFileAlreadyKnown else { print("CSV file already known"); return }

    
    // Extract information from the CSV
    let csvData:CSVData? = loadCSVFileContents(csvFileURL: csvPath)
    
    guard let csvData = csvData else {
        print("Error: could not load CSV data")
        return
    }
    
    
    var knownAccount: Account? = nil
    
    var accountInCSVAlreadyKnown: Bool = false
    for account in knownAccounts{
        if account.accountName == csvData.accountName{
            knownAccount = account
            accountInCSVAlreadyKnown = true
            break
        }
    }
    
    // #####################################
    // Create objects for persistant storage
    // #####################################
    
    // Create the csvFile object
    var csvFile = File(context: PersistenceController.shared.container.viewContext)
    csvFile.id = UUID()
    csvFile.fileName = csvName
    csvFile.filePath = csvPath
    
    var csvAccount: Account
    // Create the account object if needed
    if !accountInCSVAlreadyKnown {
        csvAccount = Account(context: PersistenceController.shared.container.viewContext)
        csvAccount.id = UUID()
        csvAccount.accountName = csvData.accountName
    }else{
        csvAccount = knownAccount!
    }
    
    // Create new transactions
    
    var newTransactions: [Transaction] = []
    for transaction in csvData.transactions{
        var t:Transaction = Transaction(context: PersistenceController.shared.container.viewContext)
        t.id = UUID()
        t.balance = Int64(transaction.balance)
        t.date = transaction.date
        t.dayTransactionNumber = 0
        t.paidIn = Int64(transaction.paidIn)
        t.paidOut = Int64(transaction.paidOut)
        t.transactionType = transaction.transactionType
        t.transactionDescription = transaction.description
        t.associatedAccount = csvAccount
        newTransactions.append(t)
    }

    csvAccount.appendTranactions(transactions: newTransactions)
    csvFile.appendTranactions(newTransactions: newTransactions)
    
    do {
        try PersistenceController.shared.container.viewContext.save()
    } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("loadDummyCSV:Unresolved error \(nsError), \(nsError.userInfo)")
    }
    
}

func letUserPickCSVFile() -> (String?, String?){
    // Create a dialog box
    let dialog = NSOpenPanel();

    dialog.title                   = "Choose a csv file to load";
    dialog.showsResizeIndicator    = true;
    dialog.showsHiddenFiles        = false;
    dialog.allowsMultipleSelection = false;
    dialog.canChooseDirectories = false;
    dialog.allowedFileTypes        = ["csv"]
    

    if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
        let result = dialog.url // Pathname of the file
        
        if (result != nil) {
            let path: String = result!.path
            let name: String = result!.pathComponents.last!
            
            
            return (name, path)
        }
        
    } else {
        // User clicked on "Cancel"
        return (nil, nil)
    }
    
    return (nil, nil)
}

func loadCSVFileContents(csvFileURL: String) -> CSVData?{
    var csvContent = try? String(contentsOf: URL(filePath: csvFileURL))
    
    //If it fails to read the file try reading it as an ASCII encoded file
    if csvContent == nil {
        csvContent = try? String(contentsOf: URL(filePath: csvFileURL), encoding: String.Encoding(rawValue: NSASCIIStringEncoding))
    }
    
    guard var csvContent = csvContent else {
        print("Couldn't load file. Please check the file encoding is either UTF8 or ASCII")
        return nil
    }
    
    // Clean the csv
    csvContent.replace("\",\"", with: "<|>")
    csvContent.replace("\r\n", with: "<|>")
    csvContent.replace("\"", with: "")
    
    
    let (keyDataLocations, currencyCharacter, formatName): (CSVDataLocation, String, String) = getCSVFormat()
    csvContent.replace(currencyCharacter, with: "")
    
    let csvContentList: [String] = csvContent.components(separatedBy: "<|>")
    
    let accountName: String = csvContentList[keyDataLocations.accountNameLocation]
    
    var accountBalanceStr: String = csvContentList[keyDataLocations.accountBalanceLocation]
    accountBalanceStr.replace(".", with: "")
    let accountBalance: Int? = Int(accountBalanceStr)
    
    var availableBalanceStr: String = csvContentList[keyDataLocations.availableBalanceLocation]
    availableBalanceStr.replace(".", with: "")
    let availableBalance: Int? = Int(availableBalanceStr)
    
    
    guard let accountBalance = accountBalance else {
        print("Couldn't convert account balance to int: Was reading location \(keyDataLocations.accountBalanceLocation) as specified by format \(formatName) as holding the value  \"\(csvContentList[keyDataLocations.accountBalanceLocation])\"")
        return nil
    }
    
    guard let availableBalance = availableBalance else {
        print("Couldn't convert available balance to int: Was reading location \(keyDataLocations.availableBalanceLocation) as specified by format \(formatName) as holding the value \"\(csvContentList[keyDataLocations.availableBalanceLocation])\"")
        return nil
    }
    
    
    let noItemsMinusHeader = csvContentList.count - keyDataLocations.transactionsStartLocation
    
    let totalNoTransactions:Int = noItemsMinusHeader.isMultiple(of: keyDataLocations.noColumnsPerTransaction)
        ? noItemsMinusHeader / keyDataLocations.noColumnsPerTransaction
        : (noItemsMinusHeader / keyDataLocations.noColumnsPerTransaction) + 1
    
    
    
    var transactions: [TransactionRecord] = []
    for currentTransactionNumber in 1..<totalNoTransactions {
        
        let currentOffset: Int = keyDataLocations.noColumnsPerTransaction*currentTransactionNumber
        
        let transactionDate:Date = Utils.dateFormatter.date(from: csvContentList[keyDataLocations.transactionDateLocation + currentOffset]) ?? Date()
        
        var paidOutStr: String = csvContentList[keyDataLocations.transactionPaidOutLocation + currentOffset]
        paidOutStr.replace(".", with: "")
        let paidOut: Int? = paidOutStr.isEmpty ? 0 : Int(paidOutStr)
        
        guard let paidOut = paidOut else {
            print("Couldn't convert paidOut to int: Was reading location \(keyDataLocations.transactionPaidOutLocation+currentOffset) as specified by format \(formatName) as holding the value \"\(csvContentList[keyDataLocations.transactionPaidOutLocation+currentOffset])\"")
            return nil
        }
        
        
        var paidInStr: String = csvContentList[keyDataLocations.transactionPaidInLocation + currentOffset]
        paidInStr.replace(".", with: "")
        
        let paidIn: Int? = paidInStr.isEmpty ? 0 : Int(paidInStr)
        
        guard let paidIn = paidIn else {
            print("Couldn't convert paidIn to int: Was reading location \(keyDataLocations.transactionPaidInLocation + currentOffset) as specified by format \(formatName) as holding the value \"\(csvContentList[keyDataLocations.transactionPaidInLocation + currentOffset])\"")
            return nil
        }
        
        var balanceStr: String = csvContentList[keyDataLocations.transactionBalanceLocation + currentOffset]
        balanceStr.replace(".", with: "")
        let balance: Int? = Int(balanceStr)
    
        guard let balance = balance else {
            print("Couldn't convert balance to int: Was reading location \(keyDataLocations.transactionBalanceLocation+currentOffset) as specified by format \(formatName) as holding the value \"\(csvContentList[keyDataLocations.transactionBalanceLocation+currentOffset])\"")
            return nil
        }
        
        
        let currentTransaction = TransactionRecord(
            date: transactionDate,
            transactionType: csvContentList[keyDataLocations.transactionTypeLocation + currentOffset],
            description: csvContentList[keyDataLocations.transactionDescriptionLocation + currentOffset],
            paidOut: paidOut,
            paidIn: paidIn,
            balance: balance
        )
        
        transactions.append(currentTransaction)
    }
    
    return CSVData(accountName: accountName, accountBalance: accountBalance, availableBalance: availableBalance, transactions: transactions)
    
 
}

func getCSVFormat(format: StatementFileDataFormats = .format_1) -> (CSVDataLocation, currencyCharacter: String, formatName: String) {
    
    switch format{
        case .format_1:
            return (CSVDataLocation(
                accountNameLocation: 1,
                accountBalanceLocation:3,
                availableBalanceLocation:5,
                transactionDateLocation:7,
                transactionTypeLocation: 8,
                transactionDescriptionLocation: 9,
                transactionPaidOutLocation: 10,
                transactionPaidInLocation: 11,
                transactionBalanceLocation: 12,
                noColumnsPerTransaction: 6,
                transactionsStartLocation: 13
            ), "£", "format_1")
    }
}

enum Utils {
    
    public static var  dateFormatter: DateFormatter = {
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        df.timeZone = .gmt
        return df
    }()
    
}
