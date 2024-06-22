import SwiftUI

struct ConnectedView: View {
    @ObservedObject var bluetoothManager = BluetoothManager.shared
    @FocusState private var isFocused: Bool
    @State private var crownAccumulator: Double = 0
    @Environment(\.dismiss) private var dismiss
    
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                                             
                VStack(spacing: 10) {
                    // Temperature Display
                    TemperatureGradient(temperature: $bluetoothManager.temperature, targetTemperature: $bluetoothManager.targetTemperature, isHeating: $bluetoothManager.isHeating)
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                        .focusable()
                        .digitalCrownRotation(
                            $crownAccumulator,
                            from: -50,
                            through: 50,
                            by: 0.1,
                            sensitivity: .medium,
                            isContinuous: false,
                            isHapticFeedbackEnabled: true
                        )
                        .focused($isFocused)
                        .onChange(of: crownAccumulator) { oldValue, newValue in
                            if isFocused {
                                let newTemp = bluetoothManager.targetTemperature + newValue
                                bluetoothManager.targetTemperature = max(160, min(210, newTemp))
                                crownAccumulator = 0
                            }
                        }
                    // Remaining Time and Battery
            
                    HStack {
                        HStack {
                            Image(systemName: "timer")
                            Text("\(bluetoothManager.isConnected ? bluetoothManager.remainingTime :  bluetoothManager.autoOffTime)s")
                        }
                        .font(.system(size: 16))
                        
                        Spacer()
                        
                        HStack {
                            Text("\(bluetoothManager.battery)%")
                            Image(systemName: batteryIcon(battery: bluetoothManager.battery))
                        }
                        .font(.system(size: 16))
                    }
                    .foregroundColor(.gray)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                
            }
            
        }.background(Color.black.edgesIgnoringSafeArea(.all))
        
    }
    
    func batteryIcon(battery: Int) -> String{
       
        switch battery {
        case 0..<10:
            return "battery.0"
        case 10...25:
            return "battery.10"
        case 25...50:
            return "battery.25"
        case 50...75:
            return "battery.50"
        case 75...95:
            return "battery.75"
        default:
            return "battery.100"
        }
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
    }
}
