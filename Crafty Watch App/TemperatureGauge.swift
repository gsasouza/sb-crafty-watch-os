import SwiftUI

struct TemperatureGradient: View {
    @Binding var temperature: Double
    @Binding var targetTemperature: Double
    @Binding var isHeating: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: CGFloat(temperature / 210))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                colorForTemperature(temperature: 0, isHeating:  isHeating),
                                colorForTemperature(temperature: temperature, isHeating:  isHeating),
                                colorForTemperature(temperature: min(temperature + 0, 210), isHeating:  isHeating)
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(Int(temperature))°C")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(colorForTemperature(temperature: temperature, isHeating: isHeating))
                    Text("\(Int(targetTemperature))°C")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
        }
    }
    
    func colorForTemperature(temperature: Double, isHeating: Bool) -> Color {
        if (!isHeating) {
            return .gray
        }
        switch temperature {
        case 0..<160:
            return .yellow
        case 180...200:
            return .orange
        case 200...210:
            return .red
        default:
            return .gray
        }
    }
}
