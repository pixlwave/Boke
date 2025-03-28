import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("Timer", systemImage: "timer") {
                TimerView()
            }
            
            Tab("MIDI Control", systemImage: "pianokeys") {
                MIDIView()
                    .environment(InputMapper.shared)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
