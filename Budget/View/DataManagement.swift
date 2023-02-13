//
//  Home.swift
//  Budget
//
//  Created by Justin Reed on 13/02/2023.
//

import SwiftUI

struct Home: View {
    
    @State var windowWidth: CGFloat
    @State var windowHeight: CGFloat
    @State var ButtonsText: [String]
    @State var currentTab: String


    
    @Namespace var animation
    
    
    var tabWindowProportion = 0.11
    var selectedTabCapsuleWidth = 2.0
    var tabItemDistributionFactor = 10.0
    var capsuleHeightMultipler = 2.0
    
    struct File: Identifiable {
        let filePath: String
        let fileName: String
        let id = UUID()
    }
    
    struct Account: Identifiable, Hashable{
        let accountName: String
        let id = UUID()
    }
    
    
    var body: some View {
        
        
        HStack(spacing: 0){
            // Side bar menu
            VStack(spacing: 20){
                // Menu Buttons
                ForEach(ButtonsText,id: \.self){tabName in
                    
                    MenuButton(menuItem: tabName)
                }
                
            }
            .padding(.top, 60)
            .frame(width: windowWidth * tabWindowProportion)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(
                //Corner Radius only on right side
                ZStack{
                    Color.white
                        .padding(.trailing,30)
                    
                    Color.white
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.04), radius: 5, x:5, y:0)
                }
                .ignoresSafeArea()
            )
            
            
            // Data Management View
            VStack(spacing: 20){
                Spacer()
                HStack(spacing: 20){
                    Spacer()
                    VStack(alignment: .center, spacing: 30){
                        Text("Data Management")
                            .font(.title2.bold())
                        HStack(spacing: windowWidth*(1-tabWindowProportion)/3){
                            Button("Import New data to dataset"){
                                
                            }
                            Button("Remove File from dataset"){
                                
                            }
                        }.frame(maxWidth: .infinity)
                        Table(getFiles()){
                            TableColumn("File Name",value: \.fileName)
                            TableColumn("File Path",value: \.filePath)
                        }.frame(maxHeight: windowHeight/5)
                        HStack(alignment: .center,spacing: 10){
                            
                            ForEach(getAccounts(), id:
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
        .frame(width: windowWidth, height: windowHeight, alignment: .leading)
        .background(Color("BG").ignoresSafeArea())
        
        //Apply button style to whole view
        .buttonStyle(BorderlessButtonStyle())
    }
    
    @ViewBuilder
    func MenuButton(menuItem: String) -> some View{
        
        Text(menuItem)
            .multilineTextAlignment(.center)
            .aspectRatio(contentMode: .fit)
            .foregroundColor(currentTab == menuItem ? .black : .gray)
            .frame(width: windowWidth * tabWindowProportion, height: windowHeight/tabItemDistributionFactor)
            .background(Color.white)
            .overlay(
            
                HStack{
                    if currentTab == menuItem{
                        Capsule()
                            .fill(Color.black)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                            .frame(width: selectedTabCapsuleWidth, height:windowHeight/tabItemDistributionFactor)
                            .offset(x: 2)
                    }
                },
                alignment: .trailing
                
                
            )
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()){
                    currentTab = menuItem
                }
            }
        
    }
  
    // Returns the list of files
    func getFiles() -> [File] {
        let files = [
            File(filePath: "p1", fileName: "TestFile1"),
            File(filePath: "p2", fileName: "TestFile2"),
            File(filePath: "p3", fileName: "TestFile3")
        ]
        
        return files
    }
    
    func getAccounts() -> [Account] {
        let accounts = [
            Account(accountName: "A1"),
            Account(accountName: "A2"),
            Account(accountName: "A3")
        ]
        
        return accounts
    }
        
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//Extending view to get Screen Frame
extension View{
    func getRect()->CGRect{
        return NSScreen.main!.visibleFrame
    }
}
