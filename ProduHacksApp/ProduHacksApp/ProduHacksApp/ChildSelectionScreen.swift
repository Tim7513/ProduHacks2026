import SwiftUI

struct ChildSelectionScreen: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData
    @State private var showAddChildSheet = false
    @State private var addChildErrorMessage: String?

    var body: some View {
        ZStack {
            Color.surfaceBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color.primary)

                        Text("Select a Child")
                            .font(.jakartaDisplay(32, weight: .bold))
                            .foregroundColor(Color.onSurface)

                        Text("Choose which child's progress to view")
                            .font(.lexendBody(16, weight: .regular))
                            .foregroundColor(Color.onSurfaceVariant)
                    }
                    .padding(.top, 40)

                    // Children Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(appData.children) { child in
                            ChildCard(child: child) {
                                Task {
                                    await selectChild(child)
                                }
                            }
                        }

                        Button(action: {
                            showAddChildSheet = true
                        }) {
                            AddChildCard()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showAddChildSheet) {
            AddChildProfileSheet { name, age, readingLevel in
                Task {
                    await addChild(name: name, age: age, readingLevel: readingLevel)
                }
            }
        }
        .alert("Add Child Error", isPresented: Binding(
            get: { addChildErrorMessage != nil },
            set: { if !$0 { addChildErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(addChildErrorMessage ?? "Unknown error")
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
            currentScreen = .parentDashboard
        }
    }

    @MainActor
    private func addChild(name: String, age: Int, readingLevel: Int) async {
        guard let guardianId = appData.currentGuardianId else {
            addChildErrorMessage = "You need to sign in as the parent account before creating children."
            return
        }

        do {
            let remoteChild = try await SupabaseService.shared.createChildProfile(
                name: name,
                age: age,
                readingLevel: readingLevel,
                guardianId: guardianId,
                selectedGenres: appData.availableGenres
            )

            var updated = appData.children
            updated.append(
                ChildProfile(
                    id: remoteChild.id,
                    name: remoteChild.name,
                    age: remoteChild.age,
                    readingLevel: remoteChild.readingLevel,
                    readingComprehension: remoteChild.readingComprehension,
                    stats: ReadingStats(wordsRead: 0, readingTime: 0, weeklyMinutes: 0, streakDays: 0, badges: 0, booksCompleted: 0),
                    weeklyData: [
                        WeeklyData(day: "MON", minutes: 0, color: "variant"),
                        WeeklyData(day: "TUE", minutes: 0, color: "variant"),
                        WeeklyData(day: "WED", minutes: 0, color: "variant"),
                        WeeklyData(day: "THU", minutes: 0, color: "variant"),
                        WeeklyData(day: "FRI", minutes: 0, color: "variant"),
                        WeeklyData(day: "SAT", minutes: 0, color: "variant"),
                        WeeklyData(day: "SUN", minutes: 0, color: "variant")
                    ],
                    library: [],
                    dailyGoal: remoteChild.dailyGoal,
                    requiredTestScore: remoteChild.requiredTestScore,
                    readingMinutes: remoteChild.readingMinutes
                )
            )
            appData.children = updated
            showAddChildSheet = false
        } catch {
            addChildErrorMessage = error.localizedDescription
        }
    }
}

struct ChildCard: View {
    let child: ChildProfile
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.primary, Color.primaryContainer],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(child.name.prefix(1))
                            .font(.jakartaDisplay(36, weight: .bold))
                            .foregroundColor(.white)
                    )

                // Name
                Text(child.name)
                    .font(.lexendBody(18, weight: .semibold))
                    .foregroundColor(Color.onSurface)

                // Quick Stats
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.primary)
                        Text("\(child.stats.booksCompleted) books")
                            .font(.lexendBody(12, weight: .regular))
                            .foregroundColor(Color.onSurfaceVariant)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.secondary)
                        Text("\(child.stats.streakDays) day streak")
                            .font(.lexendBody(12, weight: .regular))
                            .foregroundColor(Color.onSurfaceVariant)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.tertiary)
                        Text("\(child.stats.weeklyMinutes) min/week")
                            .font(.lexendBody(12, weight: .regular))
                            .foregroundColor(Color.onSurfaceVariant)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .popUpShadow()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddChildCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color.surfaceContainerLow)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(Color.onSurfaceVariant)
                )

            Text("Add Child")
                .font(.lexendBody(18, weight: .semibold))
                .foregroundColor(Color.onSurfaceVariant)

            VStack(spacing: 8) {
                Text("Create a new")
                    .font(.lexendBody(12, weight: .regular))
                    .foregroundColor(Color.onSurfaceVariant)
                Text("child profile")
                    .font(.lexendBody(12, weight: .regular))
                    .foregroundColor(Color.onSurfaceVariant)
            }
            .opacity(0.7)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .popUpShadow()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.outline, style: StrokeStyle(lineWidth: 2, dash: [8]))
        )
    }
}

struct AddChildProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var age = 8
    @State private var readingLevel = 3

    let onCreate: (String, Int, Int) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("Child Details") {
                    TextField("Name", text: $name)

                    Stepper("Age: \(age)", value: $age, in: 3...18)

                    Stepper("Reading Level: \(readingLevel)", value: $readingLevel, in: 1...12)
                }
            }
            .navigationTitle("Add Child")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        onCreate(name.trimmingCharacters(in: .whitespacesAndNewlines), age, readingLevel)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
