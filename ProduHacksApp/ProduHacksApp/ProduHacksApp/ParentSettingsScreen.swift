import SwiftUI

struct ParentSettingsScreen: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData

    @State private var readingLevel: Int = 3
    @State private var requiredTestScore: Double = 0.8
    @State private var dailyReadingMinutes: Int = 15
    @State private var isSaving = false
    @State private var saveErrorMessage: String?

    private var activeChild: ChildProfile? {
        appData.selectedChild ?? appData.children.first
    }

    private var calculatedPassageLength: Int {
        let estimatedWordsPerMinute = max(70, 70 + (readingLevel * 12))
        return dailyReadingMinutes * estimatedWordsPerMinute
    }

    private var readingLevelLabel: String {
        switch readingLevel {
        case 1...3: return "Beginner (Grades 1-3)"
        case 4...6: return "Intermediate (Grades 4-6)"
        case 7...9: return "Advanced (Grades 7-9)"
        case 10...12: return "Expert (Grades 10-12)"
        default: return "Grade \(readingLevel)"
        }
    }

    var body: some View {
        ZStack {
            Color.surfaceBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color.primary)

                        Text("Reading Settings")
                            .font(.jakartaDisplay(32, weight: .bold))
                            .foregroundColor(Color.onSurface)

                        Text("Customize \(appData.childName)'s reading experience")
                            .font(.lexendBody(16, weight: .regular))
                            .foregroundColor(Color.onSurfaceVariant)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 24) {
                        SettingsCard(
                            icon: "book.fill",
                            title: "Reading Level",
                            color: Color.primary
                        ) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Grade Level: \(readingLevel)")
                                        .font(.lexendBody(16, weight: .semibold))
                                        .foregroundColor(Color.onSurface)
                                    Spacer()
                                    Text(readingLevelLabel)
                                        .font(.lexendBody(14, weight: .regular))
                                        .foregroundColor(Color.onSurfaceVariant)
                                }

                                Slider(value: Binding(
                                    get: { Double(readingLevel) },
                                    set: { readingLevel = Int($0) }
                                ), in: 1...12, step: 1)
                                .tint(Color.primary)
                            }
                        }

                        SettingsCard(
                            icon: "checkmark.circle.fill",
                            title: "Required Test Score",
                            color: Color.secondary
                        ) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Minimum Score to Pass")
                                        .font(.lexendBody(16, weight: .semibold))
                                        .foregroundColor(Color.onSurface)
                                    Spacer()
                                    Text("\(Int(requiredTestScore * 100))%")
                                        .font(.jakartaDisplay(24, weight: .bold))
                                        .foregroundColor(Color.secondary)
                                }

                                Slider(value: $requiredTestScore, in: 0.6...1.0, step: 0.05)
                                    .tint(Color.secondary)

                                HStack {
                                    Text("60%")
                                        .font(.lexendBody(12, weight: .regular))
                                        .foregroundColor(Color.onSurfaceVariant)
                                    Spacer()
                                    Text("100%")
                                        .font(.lexendBody(12, weight: .regular))
                                        .foregroundColor(Color.onSurfaceVariant)
                                }
                            }
                        }

                        SettingsCard(
                            icon: "clock.fill",
                            title: "Daily Reading Time",
                            color: Color.tertiary
                        ) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Required Reading Time")
                                        .font(.lexendBody(16, weight: .semibold))
                                        .foregroundColor(Color.onSurface)
                                    Spacer()
                                    Text("\(dailyReadingMinutes) min")
                                        .font(.jakartaDisplay(24, weight: .bold))
                                        .foregroundColor(Color.tertiary)
                                }

                                Slider(value: Binding(
                                    get: { Double(dailyReadingMinutes) },
                                    set: { dailyReadingMinutes = Int($0) }
                                ), in: 5...60, step: 5)
                                .tint(Color.tertiary)

                                HStack {
                                    Text("5 min")
                                        .font(.lexendBody(12, weight: .regular))
                                        .foregroundColor(Color.onSurfaceVariant)
                                    Spacer()
                                    Text("60 min")
                                        .font(.lexendBody(12, weight: .regular))
                                        .foregroundColor(Color.onSurfaceVariant)
                                }
                            }
                        }

                        SettingsCard(
                            icon: "brain.head.profile",
                            title: "Reading Comprehension",
                            color: Color(hex: "FF6B35")
                        ) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Current Comprehension Score")
                                        .font(.lexendBody(16, weight: .semibold))
                                        .foregroundColor(Color.onSurface)
                                    Spacer()
                                    Text("\(Int(activeChild?.readingComprehension ?? 0))")
                                        .font(.jakartaDisplay(24, weight: .bold))
                                        .foregroundColor(Color(hex: "FF6B35"))
                                }

                                Text("This score starts at age × 100 and adjusts automatically from quiz performance.")
                                    .font(.lexendBody(13, weight: .regular))
                                    .foregroundColor(Color.onSurfaceVariant)
                            }
                        }

                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.primary)
                                Text("Calculated Passage Length")
                                    .font(.lexendBody(16, weight: .semibold))
                                    .foregroundColor(Color.onSurface)
                                Spacer()
                            }

                            HStack(alignment: .firstTextBaseline) {
                                Text("\(calculatedPassageLength)")
                                    .font(.jakartaDisplay(48, weight: .bold))
                                    .foregroundColor(Color.primary)
                                Text("words")
                                    .font(.lexendBody(18, weight: .regular))
                                    .foregroundColor(Color.onSurfaceVariant)
                                Spacer()
                            }

                            Text("Based on daily reading time and the child's current reading level")
                                .font(.lexendBody(14, weight: .regular))
                                .foregroundColor(Color.onSurfaceVariant)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(24)
                        .background(Color.primaryContainer.opacity(0.2))
                        .cornerRadius(16)
                        .padding(.horizontal, 32)
                    }

                    Button(action: {
                        saveLocally()
                        if let child = activeChild {
                            Task {
                                await persistSettings(for: child)
                            }
                        }
                        withAnimation {
                            currentScreen = .parentDashboard
                        }
                    }) {
                        Text(isSaving ? "Saving..." : "Save Settings")
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
                    .disabled(isSaving)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }

            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            currentScreen = .parentDashboard
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Dashboard")
                                .font(.lexendBody(16, weight: .semibold))
                        }
                        .foregroundColor(Color.primary)
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
            if let child = activeChild {
                readingLevel = child.readingLevel
                requiredTestScore = child.requiredTestScore
                dailyReadingMinutes = child.dailyGoal
            }
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

    private func saveLocally() {
        appData.dailyGoal = dailyReadingMinutes
        guard let selectedChildId = appData.selectedChildId,
              let index = appData.children.firstIndex(where: { $0.id == selectedChildId }) else {
            return
        }

        appData.children[index].dailyGoal = dailyReadingMinutes
        appData.children[index].readingMinutes = dailyReadingMinutes
        appData.children[index].readingLevel = readingLevel
        appData.children[index].requiredTestScore = requiredTestScore
    }

    @MainActor
    private func persistSettings(for child: ChildProfile) async {
        guard let guardianId = appData.currentGuardianId else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            try await SupabaseService.shared.saveParentSettings(
                child: child,
                guardianId: guardianId,
                settings: ParentAppSettings(
                    dailyGoal: dailyReadingMinutes,
                    readingLevel: readingLevel,
                    requiredTestScore: requiredTestScore,
                    readingMinutes: dailyReadingMinutes,
                    readingRequirementMinutes: appData.readingRequirementMinutes,
                    dailyScreenTimeLimitMinutes: appData.dailyScreenTimeLimitMinutes,
                    unlockDurationMinutes: appData.unlockDurationMinutes,
                    selectedGenres: appData.availableGenres
                )
            )
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }
}

struct SettingsCard<Content: View>: View {
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
                    .font(.lexendBody(18, weight: .semibold))
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
