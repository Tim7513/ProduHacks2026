import SwiftUI

struct LockScreen: View {
    private enum ParentAccessAction {
        case silentReading
        case appLockSettings
    }

    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData
    @State private var showParentOverrideSheet = false
    @State private var parentPassword = ""
    @State private var isVerifyingOverride = false
    @State private var overrideErrorMessage: String?
    @State private var pendingParentAction: ParentAccessAction = .silentReading

    private var readingMinutes: Int {
        max(1, appData.readingRequirementMinutes)
    }

    var body: some View {
        ZStack {
            // Background
            Color.surfaceBackground
                .ignoresSafeArea()

            // Decorative pattern (optional)
            GeometryReader { geometry in
                ForEach(0..<5, id: \.self) { i in
                    Rectangle()
                        .fill(Color.gray.opacity(0.05))
                        .frame(width: 100, height: 100)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .rotationEffect(.degrees(Double.random(in: -10...10)))
                }
            }

            VStack(spacing: 40) {
                Spacer()

                // Hero Section
                VStack(spacing: 24) {
                    // Mascot Image
                    BrandLogoView(size: 140, cornerRadius: 30)
                        .asymmetricTiltLeft()
                        .shadow(color: Color.primary.opacity(0.3), radius: 20, x: 0, y: 10)

                    VStack(spacing: 12) {
                        Text("Time for your \(readingMinutes)-minute reading adventure!")
                            .font(.jakartaDisplay(32, weight: .bold))
                            .foregroundColor(Color.onSurface)
                            .multilineTextAlignment(.center)

                        Text("The world of stories is waiting. Other apps are taking a nap while we explore!")
                            .font(.lexendBody(16, weight: .regular))
                            .foregroundColor(Color.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                VStack(spacing: 14) {
                    Text("Pick a genre for today's reading")
                        .font(.lexendBody(16, weight: .semibold))
                        .foregroundColor(Color.onSurface)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(appData.availableGenres, id: \.self) { genre in
                                Button(action: {
                                    appData.selectedGenre = genre
                                }) {
                                    Text(genre)
                                        .font(.lexendBody(14, weight: .semibold))
                                        .foregroundColor(appData.selectedGenre == genre ? .white : Color.onSurface)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            appData.selectedGenre == genre
                                            ? LinearGradient(
                                                colors: [Color.primary, Color.primaryContainer],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            : LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .cornerRadius(18)
                                        .popUpShadow()
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal, 24)

                // Call to Action
                CustomButton(
                    title: "Start Reading",
                    icon: "book.fill",
                    variant: .primary
                ) {
                    appData.hasAchieved80Percent = false
                    appData.isSilentReadingModeEnabled = false
                    appData.currentReadingPassage = nil
                    QuizService.shared.currentQuiz = nil
                    withAnimation {
                        currentScreen = .reading
                    }
                }
                .padding(.horizontal, 40)

                Button(action: {
                    pendingParentAction = .silentReading
                    showParentOverrideSheet = true
                }) {
                    Text("Parent Override: Silent Reading")
                        .font(.lexendBody(15, weight: .semibold))
                        .foregroundColor(Color.primary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color.primaryContainer.opacity(0.25))
                        .cornerRadius(14)
                }

                Button(action: {
                    pendingParentAction = .appLockSettings
                    showParentOverrideSheet = true
                }) {
                    Text("Parent Access: App Lock Settings")
                        .font(.lexendBody(15, weight: .semibold))
                        .foregroundColor(Color.secondary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color.secondaryContainer.opacity(0.22))
                        .cornerRadius(14)
                }

                Spacer()

                // Status Badge
                HStack(spacing: 8) {
                    PulsingDots()
                    Text("Focused Mode Active")
                        .font(.lexendBody(14, weight: .medium))
                        .foregroundColor(Color.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.secondaryContainer.opacity(0.3))
                .cornerRadius(24)
                .popUpShadow()
                .padding(.bottom, 40)
            }
            .padding()

            // Top Bar with Parental Lock Badge and Sign Out
            VStack {
                HStack {
                    // Sign Out Button (top-left)
                    Button(action: {
                        // Reset selected child
                        appData.selectedChildId = nil
                        withAnimation {
                            currentScreen = .onboardingUserType
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 14))
                            Text("Sign Out")
                                .font(.lexendBody(12, weight: .semibold))
                        }
                        .foregroundColor(Color.onSurfaceVariant)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .glassPanel()
                        .cornerRadius(20)
                    }

                    Spacer()

                    // Parental Lock Badge
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 16))
                        Text("Parental Lock On")
                            .font(.lexendBody(12, weight: .medium))
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.primary)
                    }
                    .foregroundColor(Color.onSurface)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .glassPanel()
                    .cornerRadius(24)
                }
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showParentOverrideSheet) {
            parentOverrideSheet
        }
        .alert("Override Error", isPresented: Binding(
            get: { overrideErrorMessage != nil },
            set: { if !$0 { overrideErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(overrideErrorMessage ?? "Unknown error")
        }
    }

    private var parentOverrideSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(parentAccessDescription)
                    .font(.lexendBody(16, weight: .regular))
                    .foregroundColor(Color.onSurfaceVariant)

                SecureField("Household password", text: $parentPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.onSurfaceVariant.opacity(0.2), lineWidth: 1)
                    )

                Button(action: {
                    Task {
                        await performParentAccessAction()
                    }
                }) {
                    Text(isVerifyingOverride ? "Verifying..." : parentAccessButtonTitle)
                        .font(.lexendBody(17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.primary)
                        .cornerRadius(14)
                }
                .disabled(parentPassword.isEmpty || isVerifyingOverride)
                .opacity((parentPassword.isEmpty || isVerifyingOverride) ? 0.5 : 1.0)

                Spacer()
            }
            .padding(24)
            .background(Color.surfaceBackground.ignoresSafeArea())
            .navigationTitle(parentAccessTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        parentPassword = ""
                        showParentOverrideSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    @MainActor
    private func performParentAccessAction() async {
        guard let username = appData.currentHouseholdUsername else {
            overrideErrorMessage = "Household account information is missing. Please sign in again."
            return
        }

        isVerifyingOverride = true
        defer { isVerifyingOverride = false }

        do {
            let isValid = try await SupabaseService.shared.verifyHouseholdPassword(
                username: username,
                password: parentPassword
            )

            guard isValid else {
                overrideErrorMessage = "Incorrect household password."
                return
            }

            switch pendingParentAction {
            case .silentReading:
                appData.hasAchieved80Percent = false
                appData.isSilentReadingModeEnabled = true
                appData.currentReadingPassage = nil
                QuizService.shared.currentQuiz = nil
                parentPassword = ""
                showParentOverrideSheet = false
                withAnimation {
                    currentScreen = .reading
                }

            case .appLockSettings:
                parentPassword = ""
                showParentOverrideSheet = false
                withAnimation {
                    currentScreen = .appLockSettings
                }
            }
        } catch {
            overrideErrorMessage = error.localizedDescription
        }
    }

    private var parentAccessTitle: String {
        switch pendingParentAction {
        case .silentReading:
            return "Parent Override"
        case .appLockSettings:
            return "App Lock Settings"
        }
    }

    private var parentAccessDescription: String {
        switch pendingParentAction {
        case .silentReading:
            return "Enter the household password to let your child read silently without microphone checks for this session."
        case .appLockSettings:
            return "Enter the household password to open app lock settings on this child device."
        }
    }

    private var parentAccessButtonTitle: String {
        switch pendingParentAction {
        case .silentReading:
            return "Enable Silent Reading"
        case .appLockSettings:
            return "Open App Lock Settings"
        }
    }
}

enum AppScreen {
    case onboardingUserType
    case onboardingGuardianSetup
    case onboardingChildSetup
    case childSelection
    case lock
    case reading
    case quiz
    case summary
    case parentDashboard
    case parentSettings
    case bookLibrary
    case appLockSettings
}
