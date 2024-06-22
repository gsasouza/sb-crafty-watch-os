//
//  MainView.swift
//  Crafty Watch App
//
//  Created by Gabriel Souza on 22/06/24.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var bluetoothManager = BluetoothManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ConnectedView(bluetoothManager: bluetoothManager)
                .tag(0)
            
            DisconnectView(bluetoothManager: bluetoothManager)
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .edgesIgnoringSafeArea(.all)
    }
}

// Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
