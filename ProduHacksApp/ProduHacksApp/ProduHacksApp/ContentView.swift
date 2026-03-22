import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("ProduHacks 2026")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("Welcome to the App!")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
