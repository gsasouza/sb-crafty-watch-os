//
//  DisconnectView.swift
//  Crafty Watch App
//
//  Created by Gabriel Souza on 22/06/24.
//

import Foundation
import SwiftUI

struct DisconnectView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Connected Device")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Temperature: \(Int(bluetoothManager.temperature))°C")
                Text("Battery: \(bluetoothManager.battery)%")
                Text("Time Remaining: \(bluetoothManager.remainingTime)s")
            }
            .font(.system(size: 14))
            
            Spacer()
            
            Button(action: {
                bluetoothManager.disconnect()
                dismiss()
            }) {
                Text("Disconnect")
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
   
}

// Preview
struct DisconnectView_Previews: PreviewProvider {
    static var previews: some View {
        DisconnectView(bluetoothManager: BluetoothManager.shared)
    }
}
