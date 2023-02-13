//
//  ContentView.swift
//  Budget
//
//  Created by Justin Reed on 13/02/2023.
//

import SwiftUI

struct ContentView: View {
    
    var buttonsText = ["Data \nManagement", "Summary", "Data \nSource \nGroups", "Group \nSummary", "Saved Views"]
    
    var body: some View {
        DataManagement(windowWidth: getRect().width/1.75, windowHeight: getRect().height - 130, ButtonsText:buttonsText, currentTab: buttonsText[0])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
