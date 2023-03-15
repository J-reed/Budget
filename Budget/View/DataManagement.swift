//
//  Home.swift
//  Budget
//
//  Created by Justin Reed on 13/02/2023.
//



import SwiftUI
import CoreData
import Charts

struct DataManagement: View {
    
    
    // Get Data from DB
    @FetchRequest(entity: File.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \File.fileName, ascending: true)]) private var files: FetchedResults<File>
    @FetchRequest(entity: Account.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Account.accountName, ascending: true)]) private var accounts: FetchedResults<Account>
    
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: true)]) private var transactions: FetchedResults<Transaction>
    
    @Environment(\.managedObjectContext) var viewContext
    
    @Namespace var animation

    var windowWidth: CGFloat { getRect().width / 1.75 }
    var windowHeight: CGFloat { getRect().height - 130 }
    
    
    var body: some View {
        
        
        
        HStack(spacing: 0){
            
            // Data Management View
            VStack(spacing: 20){
                Spacer()
                HStack(spacing: 20){
                    Spacer()
                    VStack(alignment: .center, spacing: 30){
                        Text("Data Management")
                            .font(.title2.bold())
                        HStack(spacing: windowWidth/3){
                            Button("Import New data to dataset"){
                                loadCSV(knownCSVFiles: files, knownAccounts:accounts)
                            }
                            Button("Delete All Stored Data"){
                                for file in files{
                                    PersistenceController.shared.container.viewContext.delete(file)
                                }
                                
                                for account in accounts{
                                    PersistenceController.shared.container.viewContext.delete(account)
                                }
                                
                                for transaction in transactions{
                                    PersistenceController.shared.container.viewContext.delete(transaction)
                                }
                                
                                do {
                                    try PersistenceController.shared.container.viewContext.save()
                                } catch {
                                    // Replace this implementation with code to handle the error appropriately.
                                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                    let nsError = error as NSError
                                    fatalError("loadDummyCSV:Unresolved error \(nsError), \(nsError.userInfo)")
                                }
                            }
                        }.frame(maxWidth: .infinity)
                        Table(files){
                            TableColumn("File Name",value: \.fileName)
                            TableColumn("File Path",value: \.filePath)
                        }.frame(maxHeight: windowHeight/5)
                        HStack(alignment: .center,spacing: 10){
                            
                            ForEach(accounts, id:
                                        \.self){
                                account in
                                Toggle(account.accountName, isOn: .constant(true))
                                    .toggleStyle(.checkbox)
                                
                            }
                            
                            
                            
                        }.frame(maxWidth: .infinity, alignment: .center)
                        
                        
                        Chart() {
                            
                            ForEach(accounts){ account in
                                
                                ForEach(account.transactions){ transaction in
                                    PointMark(
                                        x: .value("Date", transaction.date),
                                        y: .value("Balance", transaction.balance/100)
                                    )
                                    
                                }.foregroundStyle(getRandomColour())
                            }
                        }.frame(maxHeight: 200)
                        Spacer()
                        Button("Print info to console"){
                            for account in accounts{
                                for transaction in account.transactions{
                                    print("\(transaction.date)")
                                }
                            }
                        }
                        
                        Spacer()
                        Spacer()
                       
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }.frame(alignment: .center)
            
        }
        //Max Frame
        .background(Color("BG").ignoresSafeArea())
    }
    
        
}

struct DataManagement_Previews: PreviewProvider {
    static var previews: some View {
        DataManagement()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


//Extending view to get Screen Frame
extension View{
    func getRect()->CGRect{
        return NSScreen.main!.visibleFrame
    }
}

func getRandomColour() -> Color{
    return Color.init(
        red: .random(in: 0...1),
        green: .random(in: 0...1),
        blue: .random(in: 0...1))
}
