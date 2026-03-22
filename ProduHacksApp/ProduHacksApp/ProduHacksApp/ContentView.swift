import SwiftUI

struct ContentView: View {
    @StateObject private var appData = AppData()
    @State private var currentScreen: AppScreen = .onboardingUserType

    var body: some View {
        ZStack {
            switch currentScreen {
            case .onboardingUserType:
                UserTypeSelectionScreen(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)

            case .onboardingGuardianSetup:
                GuardianSetupScreen(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)

            case .onboardingChildSetup:
                ChildSetupScreen(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)

            case .childSelection:
                ChildSelectionScreen(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)

            case .lock:
                LockScreen(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)

            case .reading:
                ReadingScreen(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)

            case .quiz:
                QuizScreen(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)

            case .summary:
                SummaryScreen(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)

            case .parentDashboard:
                ParentDashboard(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)

            case .parentSettings:
                ParentSettingsScreen(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)

            case .bookLibrary:
                BookLibraryScreen(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)

            case .appLockSettings:
                AppLockSettingsScreen(currentScreen: $currentScreen)
                    .environmentObject(appData)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentScreen)
    }
}

#Preview {
    ContentView()
}
