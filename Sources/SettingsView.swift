import SwiftUI

struct SettingsView: View {
    enum Tab { case timer, midi }
    
    var body: some View {
        TabView {
            TimerView()
                .tabItem { Label("Timer", systemImage: "timer") }
                .tag(Tab.timer)
            MIDIView()
                .environment(InputMapper.shared)
                .tabItem { Label("MIDI Control", systemImage: "pianokeys") }
                .tag(Tab.midi)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
