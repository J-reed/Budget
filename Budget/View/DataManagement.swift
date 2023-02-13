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
                                
                            }
                            Button("Remove File from dataset"){
                                
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
                       
                    }
                    
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
