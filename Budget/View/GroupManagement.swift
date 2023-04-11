//
//  GroupManagement.swift
//  Budget
//
//  Created by Justin Reed on 11/04/2023.
//

import SwiftUI
import CoreData
import Charts

struct GroupManagement: View {
    
    
    // Get Data from DB
    @FetchRequest(entity: File.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \File.fileName, ascending: true)]) private var files: FetchedResults<File>
    @FetchRequest(entity: Account.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Account.accountName, ascending: true)]) private var accounts: FetchedResults<Account>
    
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: true)]) private var transactions: FetchedResults<Transaction>
    
    @FetchRequest(entity: Groups.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Groups.name, ascending: true)]) private var groups: FetchedResults<Groups>
    
    @Environment(\.managedObjectContext) var viewContext
    
    @Namespace var animation

    
    @State private var selectedGroups = Set<Groups.ID>()
    @State private var newGroupName = ""
    @State private var newGroupMemberName = ""
    
    @State private var selectedGroupMembers = Set<String>()
    
        
    
    
    var windowWidth: CGFloat { getRect().width / 1.75 }
    var windowHeight: CGFloat { getRect().height - 130 }
    
    
    var body: some View {
        
        var selectedGroup: Groups? = {
            for group in groups{
                if group.id == selectedGroups.first{
                    return group
                }
            }
            
            return nil
        }()
        
        HStack(spacing: 0){
            
            // Data Management View
            VStack(spacing: 20){
                Spacer()
                HStack(spacing: 20){
                    Spacer()
                    VStack(alignment: .center, spacing: 30){
                        Text("Data Management")
                            .font(.title2.bold())
                        
                        //Groups
                        
                        HStack(spacing: windowWidth/2){
                            HStack(spacing: windowWidth/10){
                                TextField("Enter a group name:", text: $newGroupName)
                                Button("Add New Group"){
                                    addGroup(groupName: newGroupName)
                                }
                            }
                            Button("Delete Groups"){
                                for group in groups{
                                    for groupID in selectedGroups{
                                        if group.id == groupID{
                                            PersistenceController.shared.container.viewContext.delete(group)
                                        }
                                    }
                                }
                                selectedGroups.removeAll()
                                
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
                        
                   
                        Text("Group Names:")
                        List(groups, selection: $selectedGroups){
                            Text($0.name ?? "Unknown Group")
                        }.frame(maxHeight: windowHeight/5)
                        
                        
                        //Group Members
                        
                        HStack(spacing: windowWidth/2){
                            HStack(spacing: windowWidth/10){
                                TextField("Enter a group member's Name:", text: $newGroupMemberName)
                                Button("Add New Group"){
                                    addGroupMember(group: selectedGroup,newGroupMemeberName: newGroupMemberName)
                                }
                            }
                            Button("Delete Group Member"){
                                deleteGroupMember(group: selectedGroup, selectedGroupMembers: selectedGroupMembers)
                            }
                        }
                        
                        let members = selectedGroup?.members ?? ["No members of selected group"]
                        
                        Text("Group Member Names:")
                        List(members, selection: $selectedGroupMembers){ member in
                            HStack(){
                                Text(member)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .background(getIsHighlighted(member: member,selectedGroupMembers: selectedGroupMembers))
                            .onTapGesture {
                                selectedGroupMembers.removeAll()
                                selectedGroupMembers.insert(member)
                            }
                        }.frame(maxHeight: windowHeight/5)

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


func addGroup(groupName: String){
    let newGroup = Groups(context: PersistenceController.shared.container.viewContext)
    newGroup.id = UUID()
    newGroup.name = groupName
    newGroup.members = ["TESCO STORES 2970 NRT BRADLEY S GB"]
    
    do {
        try PersistenceController.shared.container.viewContext.save()
    } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("loadDummyCSV:Unresolved error \(nsError), \(nsError.userInfo)")
    }
}

func addGroupMember(group: Groups?, newGroupMemeberName: String){
    
    guard let group = group else { print("No Group Selected"); return }
    group.members?.append(newGroupMemeberName)
}

func deleteGroupMember(group: Groups?,selectedGroupMembers: Set<String>){
    guard let group = group else { print("No Group Selected"); return }
    print(selectedGroupMembers.description)
}


func getIsHighlighted(member: String,selectedGroupMembers: Set<String>) -> Color {
    if selectedGroupMembers.contains(member){
        return Color.blue
    }
    else{
        return Color.white
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
