import SwiftUI

struct TimerView: View {
    @Bindable private var system = System.client
    
    var body: some View {
        Form {
            HStack(alignment: .firstTextBaseline) {
                Slider(value: $system.alertTime, in: (5 * 60)...(120 * 60), step: 5 * 60) { Text("Alert time:") }
                Text(system.alertTime.formatted ?? "")
                    .frame(width: 120, alignment: .leading)
            }
            HStack(alignment: .firstTextBaseline) {
                Slider(value: $system.resetTime, in: (1 * 60)...(20 * 60), step: 1 * 60) { Text("Screen reset time:") }
                Text(system.resetTime.formatted ?? "")
                    .frame(width: 120, alignment: .leading)
            }
            HStack {
                Picker(selection: $system.notificationFrequency, label: Text("Notification frequency:")) {
                    Text("1 minute").tag(1)
                    Text("5 minutes").tag(5)
                    Text("10 minutes").tag(10)
                }
                .pickerStyle(SegmentedPickerStyle())
                Spacer()
                    .frame(width: 125)
            }
            Toggle(isOn: $system.makesSound) {
                Text("Sounds")
            }
            
            Divider().padding(.vertical, 5)
            
            GroupBox {
                VStack(alignment: .leading) {
                    Text("Boot date: ") + Text(system.bootDate, format: .dateTime)
                    Text("Wake date: ") + Text(system.wakeDate, format: .dateTime)
                    Text("Unlock date: ") + Text(system.screenWakeDate, format: .dateTime)
                    Text("Time awake: \(system.startDate, style: .relative)")
                }
                .monospacedDigit()
            }
            .foregroundColor(.secondary)
        }
        .padding()
    }
}

// TODO: Implement this with a custom string interpolation.
private extension Text {
    init(_ date: Date?, format: Date.FormatStyle) {
        self = if let date {
            Text(date, format: format)
        } else {
            Text("Unknown")
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
