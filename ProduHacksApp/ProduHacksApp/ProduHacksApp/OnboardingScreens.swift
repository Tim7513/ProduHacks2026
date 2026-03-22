import SwiftUI

// MARK: - Unified Login/Signup Screen

struct UserTypeSelectionScreen: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData

    @State private var username = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var name = ""
    @State private var showSignInRoleDialog = false
    @State private var isAuthenticating = false
    @State private var authErrorMessage: String?

    var body: some View {
        ZStack {
            Color.surfaceBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 16) {
                        BrandLogoView(size: 96)

                        Text("Welcome to LitLink")
                            .font(.jakartaDisplay(42, weight: .bold))
                            .foregroundColor(Color.onSurface)

                        Text(isSignUp ? "Create your household account" : "Sign in to continue")
                            .font(.lexendBody(18, weight: .regular))
                            .foregroundColor(Color.onSurfaceVariant)
                    }
                    .padding(.top, 60)

                    // Login/Signup Form
                    VStack(spacing: 20) {
                        if isSignUp {
                            // Name Field (only for signup)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.lexendBody(14, weight: .semibold))
                                    .foregroundColor(Color.onSurface)

                                TextField("Enter your name", text: $name)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.onSurfaceVariant.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }

                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.lexendBody(14, weight: .semibold))
                                .foregroundColor(Color.onSurface)

                            TextField("Choose a household username", text: $username)
                                .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.onSurfaceVariant.opacity(0.2), lineWidth: 1)
                                )
                        }

                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.lexendBody(14, weight: .semibold))
                                .foregroundColor(Color.onSurface)

                            SecureField(isSignUp ? "Create a password" : "Enter your password", text: $password)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.onSurfaceVariant.opacity(0.2), lineWidth: 1)
                                )
                        }

                        // Account Type Selector (only for signup)
                        if isSignUp {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("This device will be used as...")
                                    .font(.lexendBody(14, weight: .semibold))
                                    .foregroundColor(Color.onSurface)

                                HStack(spacing: 12) {
                                    // Parent Option
                                    Button(action: {
                                        appData.userType = .guardian
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: appData.userType == .guardian ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(appData.userType == .guardian ? Color.primary : Color.onSurfaceVariant)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Parent")
                                                    .font(.lexendBody(14, weight: .semibold))
                                                Text("Create the shared account")
                                                    .font(.lexendBody(11, weight: .regular))
                                            }
                                            Spacer()
                                        }
                                        .foregroundColor(Color.onSurface)
                                        .padding(16)
                                        .background(appData.userType == .guardian ? Color.primaryContainer.opacity(0.3) : Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(appData.userType == .guardian ? Color.primary : Color.onSurfaceVariant.opacity(0.2), lineWidth: appData.userType == .guardian ? 2 : 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    // Child Option
                                    Button(action: {
                                        appData.userType = .child
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: appData.userType == .child ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(appData.userType == .child ? Color.secondary : Color.onSurfaceVariant)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Child")
                                                    .font(.lexendBody(14, weight: .semibold))
                                                Text("Uses the parent's account")
                                                    .font(.lexendBody(11, weight: .regular))
                                            }
                                            Spacer()
                                        }
                                        .foregroundColor(Color.onSurface)
                                        .padding(16)
                                        .background(appData.userType == .child ? Color.secondaryContainer.opacity(0.3) : Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(appData.userType == .child ? Color.secondary : Color.onSurfaceVariant.opacity(0.2), lineWidth: appData.userType == .child ? 2 : 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        // Submit Button
                        Button(action: {
                            handleAuthentication()
                        }) {
                            Text(isAuthenticating ? "Please Wait..." : (isSignUp ? "Create Account" : "Sign In"))
                                .font(.lexendBody(18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.primary, Color.primaryContainer],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .disabled(isAuthenticating || (isSignUp ? (name.isEmpty || username.isEmpty || password.isEmpty) : (username.isEmpty || password.isEmpty)))
                        .opacity((isAuthenticating || (isSignUp ? (name.isEmpty || username.isEmpty || password.isEmpty) : (username.isEmpty || password.isEmpty))) ? 0.5 : 1.0)
                        .padding(.top, 8)

                        // Toggle Sign Up/Sign In
                        Button(action: {
                            withAnimation {
                                isSignUp.toggle()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                    .font(.lexendBody(14, weight: .regular))
                                    .foregroundColor(Color.onSurfaceVariant)
                                Text(isSignUp ? "Sign In" : "Sign Up")
                                    .font(.lexendBody(14, weight: .semibold))
                                    .foregroundColor(Color.primary)
                            }
                        }
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                }
            }
        }
        .confirmationDialog(
            "Continue as",
            isPresented: $showSignInRoleDialog,
            titleVisibility: .visible
        ) {
            Button("Guardian") {
                completeAuthentication(as: .guardian)
            }

            Button("Child") {
                completeAuthentication(as: .child)
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose which experience you want to open for this sign-in.")
        }
        .alert("Authentication Error", isPresented: Binding(
            get: { authErrorMessage != nil },
            set: { if !$0 { authErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authErrorMessage ?? "Unknown error")
        }
    }

    func handleAuthentication() {
        if isSignUp {
            completeAuthentication(as: appData.userType)
        } else {
            showSignInRoleDialog = true
        }
    }

    func completeAuthentication(as userType: UserType) {
        appData.userType = userType

        if isSignUp && userType == .child {
            authErrorMessage = "Children should sign in with the household account created by the parent."
            return
        }

        Task {
            await authenticateSharedAccount(as: userType)
        }
    }

    @MainActor
    private func authenticateSharedAccount(as userType: UserType) async {
        isAuthenticating = true
        defer { isAuthenticating = false }

        do {
            let mode: SupabaseAuthMode = isSignUp ? .signUp : .signIn
            let guardianId = try await SupabaseService.shared.authenticateGuardian(
                username: username,
                password: password,
                name: name,
                mode: mode
            )

            appData.currentGuardianId = guardianId
            appData.currentHouseholdUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            appData.isParentAuthenticated = true
            if isSignUp && !name.isEmpty {
                appData.parentName = name
            }

            try await SupabaseService.shared.bootstrapChildren(appData.children, guardianId: guardianId)
            let remoteChildren = try await SupabaseService.shared.fetchGuardianChildren(guardianId: guardianId)
            if !remoteChildren.isEmpty {
                appData.replaceChildren(with: remoteChildren)
            }

            if userType == .guardian {
                withAnimation {
                    currentScreen = .childSelection
                }
            } else {
                withAnimation {
                    currentScreen = .onboardingChildSetup
                }
            }
        } catch {
            authErrorMessage = error.localizedDescription
        }
    }
}

// MARK: - Guardian Setup Screen (Placeholder)

struct GuardianSetupScreen: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData
    @State private var guardianName = ""
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.surfaceBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        VStack(spacing: 12) {
                            Text("Create Guardian Account")
                                .font(.jakartaDisplay(32, weight: .bold))
                                .foregroundColor(Color.onSurface)

                            Text("Manage and monitor your children's reading")
                                .font(.lexendBody(16, weight: .regular))
                                .foregroundColor(Color.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)

                        VStack(spacing: 20) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Name")
                                    .font(.lexendBody(14, weight: .semibold))
                                    .foregroundColor(Color.onSurface)

                                TextField("Enter your name", text: $guardianName)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.onSurfaceVariant.opacity(0.2), lineWidth: 1)
                                    )
                            }

                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.lexendBody(14, weight: .semibold))
                                    .foregroundColor(Color.onSurface)

                                TextField("Choose a household username", text: $username)
                                    .autocapitalization(.none)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.onSurfaceVariant.opacity(0.2), lineWidth: 1)
                                    )
                            }

                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.lexendBody(14, weight: .semibold))
                                    .foregroundColor(Color.onSurface)

                                SecureField("Create a password", text: $password)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.onSurfaceVariant.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 32)

                        // Continue Button
                        Button(action: {
                            // Save guardian info to AppData
                            appData.parentName = guardianName
                            // Navigate to child selection
                            withAnimation {
                                currentScreen = .childSelection
                            }
                        }) {
                            Text("Continue")
                                .font(.lexendBody(18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.primary, Color.primaryContainer],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 32)
                        .disabled(guardianName.isEmpty || username.isEmpty || password.isEmpty)
                        .opacity((guardianName.isEmpty || username.isEmpty || password.isEmpty) ? 0.5 : 1.0)

                        Spacer()
                    }
                }
            }
            .navigationBarItems(leading: Button(action: {
                withAnimation {
                    currentScreen = .onboardingUserType
                }
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(Color.primary)
            })
        }
    }
}

// MARK: - Child Login Screen (Select which child you are)

struct ChildSetupScreen: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData

    var body: some View {
        ZStack {
            Color.surfaceBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color.secondary)

                        Text("Welcome, Reader!")
                            .font(.jakartaDisplay(36, weight: .bold))
                            .foregroundColor(Color.onSurface)

                        Text("Which child profile is linked to this device?")
                            .font(.lexendBody(18, weight: .regular))
                            .foregroundColor(Color.onSurfaceVariant)
                    }
                    .padding(.top, 60)

                    // Children Grid
                    if appData.children.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "person.crop.circle.badge.questionmark")
                                .font(.system(size: 60))
                                .foregroundColor(Color.onSurfaceVariant)

                            Text("No Children Accounts")
                                .font(.jakartaDisplay(24, weight: .bold))
                                .foregroundColor(Color.onSurface)

                            Text("Please ask your parent to create a child account first")
                                .font(.lexendBody(14, weight: .regular))
                                .foregroundColor(Color.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 20) {
                            ForEach(appData.children) { child in
                                ChildLoginCard(child: child) {
                                    Task {
                                        await selectChild(child)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer()

                    // Back Button
                    Button(action: {
                        withAnimation {
                            currentScreen = .onboardingUserType
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back to User Type")
                        }
                        .font(.lexendBody(14, weight: .semibold))
                        .foregroundColor(Color.secondary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(Color.white)
                        .cornerRadius(12)
                        .popUpShadow()
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }

    @MainActor
    private func selectChild(_ child: ChildProfile) async {
        appData.selectedChildId = child.id
        appData.childName = child.name

        if let remoteSettings = try? await SupabaseService.shared.fetchRemoteSettings(for: child.id) {
            appData.applyRemoteSettings(remoteSettings, to: child.id)
        }

        withAnimation {
            currentScreen = .lock
        }
    }
}

// MARK: - Child Login Card

struct ChildLoginCard: View {
    let child: ChildProfile
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Avatar with initial
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.secondary, Color.secondaryContainer],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(child.name.prefix(1))
                            .font(.jakartaDisplay(48, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color.secondary.opacity(0.3), radius: 10, x: 0, y: 5)

                VStack(spacing: 4) {
                    Text(child.name)
                        .font(.jakartaDisplay(22, weight: .bold))
                        .foregroundColor(Color.onSurface)

                    Text("Level \(child.readingLevel)")
                        .font(.lexendBody(12, weight: .medium))
                        .foregroundColor(Color.onSurfaceVariant)
                }

                // Quick Stats Badge
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color.tertiary)
                    Text("\(child.stats.streakDays) day streak")
                        .font(.lexendBody(11, weight: .semibold))
                        .foregroundColor(Color.onSurfaceVariant)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.tertiaryContainer.opacity(0.3))
                .cornerRadius(12)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(24)
            .popUpShadow()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
