import SwiftUI

struct PreferencesView: View {
    static func makeHostedView() -> NSHostingView<PreferencesView> { NSHostingView(rootView: PreferencesView()) }
    
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView().tabItem { Text("Timer") }.tag(1)
            NetworkView().tabItem { Text("Network") }.tag(2)
        }
        .padding(.all)
    }
}

struct TimerView: View {
    @ObservedObject var system = System.client
    
    var body: some View {
        Form {
            HStack {
                Slider(value: $system.alertTime, in: (5 * 60)...(120 * 60)) { Text("Alert time:") }
                Text(system.alertTime.formatted ?? "")
                    .frame(width: 120, alignment: .leading)
            }
            HStack {
                Slider(value: $system.resetTime, in: (1 * 60)...(20 * 60)) { Text("Screen reset time:") }
                Text(system.resetTime.formatted ?? "")
                    .frame(width: 120, alignment: .leading)
            }
            Picker(selection: $system.notificationFrequency, label: Text("Notification frequency:")) {
                Text("1 minute").tag(1)
                Text("5 minutes").tag(5)
                Text("10 minutes").tag(10)
            }
            .pickerStyle(SegmentedPickerStyle())
            Toggle(isOn: $system.makesSound) {
                Text("Sounds")
            }
            
            Divider().padding(.vertical, 5)
            
            VStack(alignment: .leading) {
                Text("Boot date: \(system.bootDate?.description ?? "nil")")
                Text("Wake date: \(system.wakeDate?.description ?? "nil")")
                Text("Unlock date: \(system.screenWakeDate?.description ?? "nil")")
                Text("Time awake: \(system.timeAwake().formatted ?? "Error")")
            }
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

struct NetworkView: View {
    @ObservedObject var network = Network.client
    
    @State private var selectedSSID = Set<String>()
    @State private var isPresentingSheet = false
    
    var body: some View {
        HStack {
            List(network.ssids, id: \.self, selection: $selectedSSID) { ssid in
                Text(ssid)
            }
            .padding(.all)
            VStack {
                Button("Add Network") {
                    isPresentingSheet.toggle()
                }
                Button("Remove Network") {
                    network.ssids.removeAll(where: { $0 == selectedSSID.first })
                }
            }
        }
        .padding(.all)
        .sheet(isPresented: $isPresentingSheet) {
            AddNetworkSheet(isPresented: $isPresentingSheet)
        }
    }
}

struct AddNetworkSheet: View {
    @Binding var isPresented: Bool
    @State private var networkName = ""
    var body: some View {
        VStack(alignment: .leading) {
            Text("Network Name")
                .font(.system(size: 13, weight: .bold))
                .padding(.bottom, 8)
            Text("Please enter the name for the new network")
            TextField("", text: $networkName)
            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented.toggle()
                }
                Button("Ok") {
                    Network.client.ssids.append(networkName)
                    isPresented.toggle()
                }.disabled(networkName.isEmpty || Network.client.ssids.contains(networkName))
            }
         }
        .padding()
    }
}

struct PreferencesView_Previews: PreviewProvider {
    @State static var isPresented: Bool = true
    static var previews: some View {
        Group {
            PreferencesView()
            AddNetworkSheet(isPresented: $isPresented)
                .frame(width: 300)
        }
    }
}
