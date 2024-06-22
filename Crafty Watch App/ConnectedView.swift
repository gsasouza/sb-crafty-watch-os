import SwiftUI

struct ConnectedView: View {
    @ObservedObject var bluetoothManager = BluetoothManager.shared
    @State private var crownState = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                // Temperature Display
                TemperatureGradient(temperature: $bluetoothManager.temperature, targetTemperature: $bluetoothManager.targetTemperature)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .focusable()
                    .digitalCrownRotation(
                        detent: Binding(
                            get: { self.crownState },
                            set: { newValue in
                                self.crownState = newValue
                                let newTemp = self.bluetoothManager.targetTemperature + newValue
                                self.bluetoothManager.targetTemperature = max(40, min(210, newTemp))
                                self.crownState = 0 // Reset crown value after applying
                            }
                        ),
                        from: -30,
                        through: 30,
                        by: 0.1,
                        sensitivity: .medium,
                        isContinuous: false,
                        isHapticFeedbackEnabled: true
                    )
                // Remaining Time and Battery
                HStack {
                    HStack {
                        Image(systemName: "timer")
                        Text("\(bluetoothManager.remainingTime)s")
                    }
                    .font(.system(size: 16))
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "battery.75")
                        Text("\(bluetoothManager.battery)%")
                    }
                    .font(.system(size: 16))
                }
                .foregroundColor(.gray)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
    }
}
