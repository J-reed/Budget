//
//  BudgetApp.swift
//  Budget
//
//  Created by Justin Reed on 13/02/2023.
//

import SwiftUI

@main
struct BudgetApp: App {
    
    @State private var selectedIndex: Int? = 0
    
    let persistenceController: PersistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView(){
                
                List{
                    Spacer()
                    NavigationLink("Data Management", tag: 0, selection: $selectedIndex){
                        DataManagement()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    }
                    NavigationLink("Summary", tag: 1, selection: $selectedIndex){
                        Text("Summary")
                    }
                    NavigationLink("Data Source Groups", tag: 2, selection: $selectedIndex){
                        Text("Data Source Groups")
                    }
                    NavigationLink("Group Summary", tag: 3, selection: $selectedIndex){
                        Text("Group Summary")
                    }
                    NavigationLink("Saved Views", tag: 4, selection: $selectedIndex){
                        Text("Saved Views")
                    }
                }.ignoresSafeArea()
            }
            
            
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
