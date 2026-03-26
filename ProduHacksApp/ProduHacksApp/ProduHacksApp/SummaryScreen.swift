import SwiftUI

struct SummaryScreen: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData

    var body: some View {
        ZStack {
            // Background with decorative dots
            Color.surfaceBackground
                .ignoresSafeArea()

            GeometryReader { geometry in
                // Blue dots
                Circle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.3)

                Circle()
                    .fill(Color.primaryContainer.opacity(0.15))
                    .frame(width: 150, height: 150)
                    .position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.1)

                // Yellow dots
                Circle()
                    .fill(Color.tertiaryContainer.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.1)

                Circle()
                    .fill(Color.tertiary.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.8)
            }

            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)

                    // Header Section
                    VStack(spacing: 20) {
                        ZStack(alignment: .topTrailing) {
                            // Mascot
                            Circle()
                                .fill(Color.secondaryContainer)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(Color.secondary)
                                )

                            // Trophy Badge
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.tertiary, Color.tertiaryContainer],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                )
                                .asymmetricTiltRight()
                                .offset(x: 20, y: -10)
                        }

                        VStack(spacing: 8) {
                            Text("Great job!")
                                .font(.jakartaDisplay(48, weight: .bold))
                                .foregroundColor(Color.primary)

                            Text("You finished your reading!")
                                .font(.lexendBody(20, weight: .regular))
                                .foregroundColor(Color.onSurfaceVariant)
                        }
                    }

                    // Stats Stack (Vertical)
                    VStack(spacing: 16) {
                        // Words Read Card
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(appData.stats.wordsRead)")
                                    .font(.jakartaDisplay(48, weight: .black))
                                    .foregroundColor(Color.primary)

                                Text("Words Read")
                                    .font(.lexendBody(14, weight: .medium))
                                    .foregroundColor(Color.onSurfaceVariant)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("+12%")
                                    .font(.lexendBody(16, weight: .bold))
                                    .foregroundColor(Color.secondary)

                                Text("vs last week")
                                    .font(.lexendBody(11, weight: .regular))
                                    .foregroundColor(Color.onSurfaceVariant)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .popUpShadow()
                        .asymmetricTiltLeft()

                        // Reading Time Card
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(appData.stats.readingTime) min")
                                    .font(.jakartaDisplay(48, weight: .black))
                                    .foregroundColor(Color.primary)

                                Text("Reading Time")
                                    .font(.lexendBody(14, weight: .medium))
                                    .foregroundColor(Color.onSurfaceVariant)
                            }

                            Spacer()
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .popUpShadow()

                        // Badge Earned Card
                        HStack(spacing: 16) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.tertiary, Color.tertiaryContainer],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Deep Sea Diver")
                                    .font(.lexendBody(18, weight: .bold))
                                    .foregroundColor(Color.tertiary)

                                Text("Badge Earned")
                                    .font(.lexendBody(12, weight: .medium))
                                    .foregroundColor(Color.onSurfaceVariant)
                            }

                            Spacer()
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .popUpShadow()
                        .asymmetricTiltRight()
                    }
                    .padding(.horizontal)

                    // Action Buttons
                    VStack(spacing: 16) {
                        CustomButton(
                            title: "Unlock Device",
                            icon: "lock.open.fill",
                            variant: .primary
                        ) {
                            ScreenTimeManager.shared.beginUnlockSession(durationMinutes: appData.unlockDurationMinutes)
                            appData.currentReadingPassage = nil
                            appData.hasAchieved80Percent = false
                            appData.isSilentReadingModeEnabled = false

                            withAnimation {
                                currentScreen = appData.userType == .guardian ? .parentDashboard : .lock
                            }
                        }

                        Button(action: {
                            withAnimation {
                                currentScreen = .lock
                            }
                        }) {
                            Text("Back to Library")
                                .font(.lexendBody(16, weight: .semibold))
                                .foregroundColor(Color.primary)
                        }
                    }
                    .padding(.horizontal, 40)

                    Spacer().frame(height: 40)
                }
            }
        }
    }
}
