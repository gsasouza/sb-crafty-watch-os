import SwiftUI

struct DeviceListView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bluetoothManager.discoveredDevices) { device in
                    DeviceRowView(device: device, bluetoothManager: bluetoothManager)
                }
            }
            .navigationTitle("Devices")
            .refreshable {
                bluetoothManager.startScanning()
            }
            .overlay(Group {
                if bluetoothManager.discoveredDevices.isEmpty {
                    VStack {
                        ProgressView()
                        Text("Scanning for devices...")
                            .foregroundColor(.secondary)
                    }
                }
            })
        }
    }
}

struct DeviceRowView: View {
    let device: DiscoveredDevice
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        HStack {
           
            
            VStack(alignment: .trailing) {
                
                
                Button(action: {
                    bluetoothManager.connect(to: device.peripheral)
                }) {
                    VStack(alignment: .leading) {
                        Text(device.name)
                    }
                    
                    Spacer()
                    
                    Text(device.rssi.description + " dBm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                }
            }
        }
        .padding(.vertical, 8)
    }
}
