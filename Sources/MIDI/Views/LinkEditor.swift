import SwiftUI

struct LinkEditor: View {
    private static let elementCallURLString = "https://call.element.io/"
    static var defaultsKey = ""
    
    @AppStorage(Self.defaultsKey) private var link: URL?
    
    @State private var urlString = Self.elementCallURLString
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Enter URL")
                .font(.headline)
            TextField(Self.elementCallURLString, text: $urlString, onCommit: setURL)
                .frame(minWidth: 200)
        }
        .padding()
        .onAppear {
            urlString = link?.absoluteString ?? Self.elementCallURLString
        }
    }
    
    func setURL() {
        link = URL(string: urlString)
    }
}
