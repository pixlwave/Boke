import SwiftUI

struct PreferencesView: View {
    static func makeHostedView() -> NSHostingView<PreferencesView> { NSHostingView(rootView: PreferencesView()) }
    
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView().tabItem { Text("Timer") }.tag(1)
        }
        .padding(.all)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
