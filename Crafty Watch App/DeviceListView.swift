import SwiftUI

struct DeviceListView: View {
    @ObservedObject var bluetoothManager = BluetoothManager.shared
    
    var body: some View {
        List {
            if bluetoothManager.isScanning {
                HStack {
                    ProgressView()
                    Text("Scanning...")
                }
            }
            
            ForEach(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                Button(action: {
                    bluetoothManager.connect(to: peripheral)
                }) {
                    Text(peripheral.name ?? "Unknown Device")
                }
            }
        }
        .navigationTitle("Devices")
        .onAppear {
            bluetoothManager.startScanning()
        }
        .onDisappear {
            bluetoothManager.stopScanning()
        }
    }
}
