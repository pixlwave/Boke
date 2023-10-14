import SwiftUI

struct TimerView: View {
    @ObservedObject private var system = System.client
    
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
                    Text("Boot date: \(system.bootDate?.description ?? "nil")")
                    Text("Wake date: \(system.wakeDate?.description ?? "nil")")
                    Text("Unlock date: \(system.screenWakeDate?.description ?? "nil")")
                    Text("Time awake: \(system.timeAwake().formatted ?? "Error")")
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}