import SwiftUI
import FamilyControls

// Data model for app configuration
struct AppLockConfig: Identifiable {
    let id = UUID()
    var appName: String
    var icon: String
    var isLocked: Bool
}

struct AppLockSettingsScreen: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData
    @StateObject private var screenTimeManager = ScreenTimeManager.shared

    @State private var dailyScreenTimeLimitMinutes: Int = 120
    @State private var readingRequirementMinutes: Int = 1
    @State private var unlockDurationMinutes: Int = 60
    @State private var enableSchoolHoursLock: Bool = true
    @State private var schoolStartHour: Int = 8
    @State private var schoolEndHour: Int = 15
    @State private var enableBedtimeLock: Bool = true
    @State private var bedtimeHour: Int = 21
    @State private var wakeupHour: Int = 7
    @State private var showAppPicker = false
    @State private var saveErrorMessage: String?

    var lockedAppsCount: Int {
        screenTimeManager.selectedAppsToBlock.applicationTokens.count
    }

    var hasSelectedRestrictions: Bool {
        !screenTimeManager.selectedAppsToBlock.applicationTokens.isEmpty
        || !screenTimeManager.selectedAppsToBlock.categoryTokens.isEmpty
        || !screenTimeManager.selectedAppsToBlock.webDomainTokens.isEmpty
    }

    var body: some View {
        ZStack {
            Color.surfaceBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color.secondary)

                        Text("App Lock & Screen Time")
                            .font(.jakartaDisplay(28, weight: .bold))
                            .foregroundColor(Color.onSurface)

                        Text("Manage \(appData.childName)'s device usage")
                            .font(.lexendBody(16, weight: .regular))
                            .foregroundColor(Color.onSurfaceVariant)
                    }
                    .padding(.top, 20)

                    HStack(spacing: 12) {
                        QuickStatCard(
                            icon: "lock.fill",
                            value: "\(lockedAppsCount)",
                            label: "Apps Locked",
                            color: Color.secondary
                        )

                        QuickStatCard(
                            icon: "clock.fill",
                            value: "\(dailyScreenTimeLimitMinutes / 60)h",
                            label: "Daily Limit",
                            color: Color.tertiary
                        )

                        QuickStatCard(
                            icon: "book.fill",
                            value: "\(readingRequirementMinutes)m",
                            label: "To Unlock",
                            color: Color.primary
                        )
                    }
                    .padding(.horizontal, 32)

                    LockSettingCard(
                        icon: "hourglass",
                        title: "Daily Screen Time Limit",
                        color: Color.tertiary
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Maximum Time Per Day")
                                    .font(.lexendBody(14, weight: .semibold))
                                    .foregroundColor(Color.onSurface)
                                Spacer()
                                Text("\(dailyScreenTimeLimitMinutes) min")
                                    .font(.jakartaDisplay(16, weight: .bold))
                                    .foregroundColor(Color.tertiary)
                            }

                            Slider(value: Binding(
                                get: { Double(dailyScreenTimeLimitMinutes) },
                                set: { dailyScreenTimeLimitMinutes = Int($0) }
                            ), in: 30...300, step: 15)
                            .tint(Color.tertiary)
                        }
                    }

                    LockSettingCard(
                        icon: "book.circle.fill",
                        title: "Reading Requirement to Unlock",
                        color: Color.primary
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Minutes of Reading Required")
                                    .font(.lexendBody(14, weight: .semibold))
                                    .foregroundColor(Color.onSurface)
                                Spacer()
                                Text("\(readingRequirementMinutes) min")
                                    .font(.jakartaDisplay(16, weight: .bold))
                                    .foregroundColor(Color.primary)
                            }

                            Slider(value: Binding(
                                get: { Double(readingRequirementMinutes) },
                                set: { readingRequirementMinutes = Int($0) }
                            ), in: 1...60, step: 1)
                            .tint(Color.primary)
                        }
                    }

                    LockSettingCard(
                        icon: "lock.open.fill",
                        title: "Unlock Duration After Quiz",
                        color: Color.secondary
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Minutes apps stay unlocked")
                                    .font(.lexendBody(14, weight: .semibold))
                                    .foregroundColor(Color.onSurface)
                                Spacer()
                                Text("\(unlockDurationMinutes) min")
                                    .font(.jakartaDisplay(16, weight: .bold))
                                    .foregroundColor(Color.secondary)
                            }

                            Slider(value: Binding(
                                get: { Double(unlockDurationMinutes) },
                                set: { unlockDurationMinutes = Int($0) }
                            ), in: 5...180, step: 5)
                            .tint(Color.secondary)
                        }
                    }

                    LockSettingCard(
                        icon: "building.2.fill",
                        title: "School Hours Lock",
                        color: Color(hex: "F59E0B")
                    ) {
                        Toggle(isOn: $enableSchoolHoursLock) {
                            Text("Lock apps during school hours")
                                .font(.lexendBody(14, weight: .semibold))
                                .foregroundColor(Color.onSurface)
                        }
                        .tint(Color(hex: "F59E0B"))
                    }

                    LockSettingCard(
                        icon: "moon.fill",
                        title: "Bedtime Lock",
                        color: Color(hex: "8B5CF6")
                    ) {
                        Toggle(isOn: $enableBedtimeLock) {
                            Text("Lock apps during bedtime")
                                .font(.lexendBody(14, weight: .semibold))
                                .foregroundColor(Color.onSurface)
                        }
                        .tint(Color(hex: "8B5CF6"))
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "apps.iphone")
                                .font(.system(size: 20))
                                .foregroundColor(Color.secondary)

                            Text("Select Apps to Lock")
                                .font(.lexendBody(18, weight: .semibold))
                                .foregroundColor(Color.onSurface)

                            Spacer()

                            Text("\(lockedAppsCount) apps")
                                .font(.lexendBody(14, weight: .semibold))
                                .foregroundColor(Color.secondary)
                        }

                        if !screenTimeManager.isAuthorized {
                            Button(action: {
                                Task {
                                    try? await screenTimeManager.requestAuthorization()
                                }
                            }) {
                                Text("Request Permission")
                                    .font(.lexendBody(14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.secondary)
                                    .cornerRadius(12)
                            }
                        } else {
                            Button(action: {
                                showAppPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "app.badge.checkmark")
                                    Text("Choose Apps to Block")
                                        .font(.lexendBody(14, weight: .semibold))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(Color.onSurface)
                                .padding(16)
                                .background(Color.surfaceContainer)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(20)
                    .popUpShadow()
                    .padding(.horizontal, 32)
                    .familyActivityPicker(isPresented: $showAppPicker, selection: $screenTimeManager.selectedAppsToBlock)

                    Button(action: {
                        if screenTimeManager.isAuthorized {
                            if hasSelectedRestrictions {
                                screenTimeManager.applyRestrictions()
                            } else {
                                screenTimeManager.removeRestrictions()
                            }
                        }

                        if let child = appData.selectedChild {
                            appData.readingRequirementMinutes = readingRequirementMinutes
                            appData.dailyScreenTimeLimitMinutes = dailyScreenTimeLimitMinutes
                            appData.unlockDurationMinutes = unlockDurationMinutes
                            Task {
                                await persistAppLockSettings(for: child)
                            }
                        }

                        withAnimation {
                            currentScreen = appData.userType == .guardian ? .parentDashboard : .lock
                        }
                    }) {
                        Text("Save Settings")
                            .font(.lexendBody(18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.secondary, Color(hex: "A855F7")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }

            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            currentScreen = appData.userType == .guardian ? .parentDashboard : .lock
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Dashboard")
                                .font(.lexendBody(16, weight: .semibold))
                        }
                        .foregroundColor(Color.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(20)
                        .popUpShadow()
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
        .onAppear {
            dailyScreenTimeLimitMinutes = appData.dailyScreenTimeLimitMinutes
            readingRequirementMinutes = appData.readingRequirementMinutes
            unlockDurationMinutes = appData.unlockDurationMinutes
        }
        .alert("Sync Error", isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "Unknown error")
        }
    }

    @MainActor
    private func persistAppLockSettings(for child: ChildProfile) async {
        guard let guardianId = appData.currentGuardianId else { return }

        do {
            try await SupabaseService.shared.saveParentSettings(
                child: child,
                guardianId: guardianId,
                settings: ParentAppSettings(
                    dailyGoal: child.dailyGoal,
                    readingLevel: child.readingLevel,
                    requiredTestScore: child.requiredTestScore,
                    readingMinutes: child.readingMinutes,
                    readingRequirementMinutes: readingRequirementMinutes,
                    dailyScreenTimeLimitMinutes: dailyScreenTimeLimitMinutes,
                    unlockDurationMinutes: unlockDurationMinutes,
                    selectedGenres: appData.availableGenres
                )
            )
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }
}

// MARK: - Supporting Views

struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.jakartaDisplay(24, weight: .bold))
                .foregroundColor(Color.onSurface)

            Text(label)
                .font(.lexendBody(10, weight: .regular))
                .foregroundColor(Color.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .popUpShadow()
    }
}

struct LockSettingCard<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(color)
                    )

                Text(title)
                    .font(.lexendBody(16, weight: .semibold))
                    .foregroundColor(Color.onSurface)

                Spacer()
            }

            content
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .popUpShadow()
        .padding(.horizontal, 32)
    }
}

struct AppLockToggle: View {
    @Binding var app: AppLockConfig

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                app.isLocked.toggle()
            }
        }) {
            HStack(spacing: 12) {
                Circle()
                    .fill(app.isLocked ? Color.secondary.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: app.icon)
                            .font(.system(size: 18))
                            .foregroundColor(app.isLocked ? Color.secondary : Color.gray)
                    )

                Text(app.appName)
                    .font(.lexendBody(13, weight: .semibold))
                    .foregroundColor(Color.onSurface)

                Spacer()

                Image(systemName: app.isLocked ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 14))
                    .foregroundColor(app.isLocked ? Color.secondary : Color.gray)
            }
            .padding(12)
            .background(app.isLocked ? Color.secondaryContainer.opacity(0.2) : Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(app.isLocked ? Color.secondary.opacity(0.3) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
