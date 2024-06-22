//
//  ContentView.swift
//  Crafty Watch App
//
//  Created by Gabriel Souza on 22/06/24.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @ObservedObject var bluetoothManager = BluetoothManager.shared
    
    var body: some View {
        switch bluetoothManager.connectionStatus {
        case .disconnected:
            DeviceListView(bluetoothManager: bluetoothManager)
        case .connecting:
            ProgressView("Connecting...")
        case .connected:
            MainView()
        case .invalidDevice:
            Text("Invalid device. Please select a compatible device.")
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        bluetoothManager.disconnect()
                    }
                }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        List {
            Text("Firmware Version: 1.0") // Replace with actual firmware version if available
            Toggle("Notifications", isOn: .constant(true)) // Replace with actual state
        }
    }
}
