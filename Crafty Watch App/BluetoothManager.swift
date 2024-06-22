import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject {
    static let shared = BluetoothManager()
    
    let DEVICES = [
          "CRAFTY": [
              "00000001-4c45-4b43-4942-265a524f5453",
              "00000002-4c45-4b43-4942-265a524f5453",
              "00000003-4c45-4b43-4942-265a524f5453"
          ]
      ]
    
    private var centralManager: CBCentralManager!
    @Published var peripheral: CBPeripheral?
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    @Published var battery: Int = 0
    @Published var remainingTime: Int = 0
    @Published var temperature: Double = 0
    
    @Published var targetTemperature: Double = 0 {
        didSet {
            // Add logic here to send the new temperature to the device
            changeTemperature(temperature: targetTemperature)
        }
    }
    
    private var batteryCharacteristic: CBCharacteristic?
    private var temperatureCharacteristic: CBCharacteristic?
    private var targetTemperatureCharacteristic: CBCharacteristic?
    private var remainingTimeCharacteristic: CBCharacteristic?
    

       
   enum ConnectionStatus {
       case disconnected
       case connecting
       case connected
       case invalidDevice
   }
   
   override init() {
       super.init()
       centralManager = CBCentralManager(delegate: self, queue: nil)
   }
   
   func startScanning() {
       if centralManager.state == .poweredOn {
           isScanning = true
           centralManager.scanForPeripherals(withServices: nil, options: nil)
       }
   }
   
   func stopScanning() {
       isScanning = false
       centralManager.stopScan()
   }
   
   func connect(to peripheral: CBPeripheral) {
       self.peripheral = peripheral
       connectionStatus = .connecting
       centralManager.connect(peripheral, options: nil)
   }
   
   func disconnect() {
       if let peripheral = peripheral {
           centralManager.cancelPeripheralConnection(peripheral)
       }
       connectionStatus = .disconnected
       isConnected = false
       self.peripheral = nil
   }
    
       
    func changeTemperature(temperature: Double) {
//        guard let characteristic = temperatureCharacteristic,
//              let peripheral = peripheral else { return }
//
//        let newTemp = Int(temperature * 10)
//
//        let data = Data([UInt8(newTemp & 0xFF), UInt8(newTemp >> 8)])
//        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        

        print("updating temperature to \(temperature)")
        playHaptic(.click)
    }
    
    private func convertBytes(_ data: Data) -> UInt16 {
        guard data.count >= 2 else { return 0 }
        return UInt16(data[0]) | (UInt16(data[1]) << 8)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let namePrefix = ["STORZ&BICKEL", "Storz&Bickel", "S&B"]
        if let name = peripheral.name,
           namePrefix.contains(where: name.hasPrefix) {
            if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
                discoveredPeripherals.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionStatus = .disconnected
        isConnected = false
        self.peripheral = nil
    }
}
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        let requiredServices = Set(DEVICES["CRAFTY"]!.map { CBUUID(string: $0) })
        let discoveredServices = Set(services.map { $0.uuid })
        
        if requiredServices.isSubset(of: discoveredServices) {
            connectionStatus = .connected
            isConnected = true
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        } else {
            connectionStatus = .invalidDevice
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        
        for characteristic in characteristics {
            switch characteristic.uuid.uuidString {
            case "00000041-4C45-4B43-4942-265A524F5453":
                batteryCharacteristic = characteristic
            case "00000011-4C45-4B43-4942-265A524F5453":
                temperatureCharacteristic = characteristic
            case "00000021-4C45-4B43-4942-265A524F5453":
                targetTemperatureCharacteristic = characteristic
            case "00000071-4C45-4B43-4942-265A524F5453":
                remainingTimeCharacteristic = characteristic
            default:
                break
            }
            
            peripheral.setNotifyValue(true, for: characteristic)
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value, !data.isEmpty else { return }
        
 
        print("Characteristic UUID: \(characteristic.uuid.uuidString)")
        print("Data size: \(data.count) bytes")
        print("Data content: \(data as NSData)")
     
        
        DispatchQueue.main.async {
            switch characteristic.uuid.uuidString {
            case "00000041-4C45-4B43-4942-265A524F5453": // Battery
                if data.count >= 1 {
                    self.battery = Int(data[0])
                }
            case "00000011-4C45-4B43-4942-265A524F5453": // Temperature
                if data.count >= 2 {
                    let value = self.convertBytes(data)
                    self.temperature = Double(value) / 10.0
                }
            case "00000021-4C45-4B43-4942-265A524F5453": // Target Temperature
                if data.count >= 2 {
                    let value = self.convertBytes(data)
                    self.targetTemperature = Double(value) / 10.0
                }
            case "00000071-4C45-4B43-4942-265A524F5453": // Remaining Time
                if data.count >= 2 {
                    let value = self.convertBytes(data)
                    self.remainingTime = Int(value)
                }
            default:
                print("Unhandled characteristic: \(characteristic.uuid.uuidString)")
                break
            }
        }
    
    }
    

}
