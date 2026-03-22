import SwiftUI

struct ParentDashboard: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData
    @State private var selectedTab = "Progress" // "Progress" or "Library"

    var child: ChildProfile? {
        appData.selectedChild
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.surfaceBackground
                .ignoresSafeArea()

            if let child = child {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            HStack(spacing: 12) {
                                BrandLogoView(size: 36, cornerRadius: 10)

                                Text("The Tactile Explorer")
                                    .font(.jakartaDisplay(20, weight: .bold))
                                    .foregroundColor(Color.onSurface)
                            }

                            Spacer()

                            // Sign Out Button
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
                                        .font(.lexendBody(13, weight: .semibold))
                                }
                                .foregroundColor(Color.onSurfaceVariant)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .popUpShadow()
                            }

                            // Child avatar/selector
                            Button(action: {
                                withAnimation {
                                    currentScreen = .childSelection
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.primary, Color.primaryContainer],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(child.name.prefix(1))
                                                .font(.jakartaDisplay(18, weight: .bold))
                                                .foregroundColor(.white)
                                        )

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color.onSurfaceVariant)
                                }
                            }
                        }
                        .padding()

                        // Welcome Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("\(child.name)'s Dashboard")
                                .font(.jakartaDisplay(32, weight: .bold))
                                .foregroundColor(Color.onSurface)

                            Text("\(child.name) has read **\(child.stats.weeklyMinutes) minutes** this week")
                                .font(.lexendBody(16, weight: .regular))
                                .foregroundColor(Color.onSurfaceVariant)

                            // Settings Buttons
                            HStack(spacing: 12) {
                                CustomButton(
                                    title: "Reading Settings",
                                    icon: "gearshape",
                                    variant: .outline
                                ) {
                                    withAnimation {
                                        currentScreen = .parentSettings
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Tab Content
                        if selectedTab == "Progress" {
                            ProgressTabContent(child: child)
                        } else {
                            LibraryTabContent(child: child, currentScreen: $currentScreen)
                        }

                        Spacer().frame(height: 100)
                    }
                    .padding(.top)
                }

                // Bottom Navigation Tabs
                HStack(spacing: 0) {
                    TabButton(
                        icon: "chart.bar.fill",
                        label: "Progress",
                        isActive: selectedTab == "Progress"
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = "Progress"
                        }
                    }

                    TabButton(
                        icon: "books.vertical.fill",
                        label: "Library",
                        isActive: selectedTab == "Library"
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = "Library"
                        }
                    }
                }
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            } else {
                // No child selected
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color.onSurfaceVariant)

                    Text("No Child Selected")
                        .font(.jakartaDisplay(24, weight: .bold))
                        .foregroundColor(Color.onSurface)

                    Button(action: {
                        withAnimation {
                            currentScreen = .childSelection
                        }
                    }) {
                        Text("Select a Child")
                            .font(.lexendBody(16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.primary)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
}

// MARK: - Tab Content Views

struct ProgressTabContent: View {
    let child: ChildProfile

    var body: some View {
        VStack(spacing: 24) {
            // Weekly Progress Chart
            WeeklyProgressChart(child: child)

            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                StatCard(
                    title: "Books Completed",
                    value: "\(child.stats.booksCompleted)",
                    icon: "book.fill",
                    color: Color.primary
                )

                StatCard(
                    title: "Badges Earned",
                    value: "\(child.stats.badges)",
                    icon: "award.fill",
                    color: Color.secondary
                )

                StatCard(
                    title: "Reading Streak",
                    value: "\(child.stats.streakDays) days",
                    icon: "flame.fill",
                    color: Color.tertiary
                )

                StatCard(
                    title: "Daily Goal",
                    value: "\(child.dailyGoal) min",
                    icon: "target",
                    color: Color(hex: "F59E0B")
                )
            }
            .padding(.horizontal)
        }
    }
}

struct LibraryTabContent: View {
    let child: ChildProfile
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Current Library")
                    .font(.jakartaDisplay(24, weight: .bold))
                    .foregroundColor(Color.onSurface)

                Spacer()

                Text("\(child.library.count) books")
                    .font(.lexendBody(14, weight: .semibold))
                    .foregroundColor(Color.onSurfaceVariant)
            }
            .padding(.horizontal)

            // Books Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(child.library) { book in
                    LibraryBookCard(book: book)
                }

                // Add New Book Button
                Button(action: {
                    withAnimation {
                        currentScreen = .bookLibrary
                    }
                }) {
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.surfaceContainerLow)
                                .aspectRatio(3/4, contentMode: .fit)

                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.primary)

                                Text("New Book")
                                    .font(.lexendBody(12, weight: .semibold))
                                    .foregroundColor(Color.onSurfaceVariant)
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isActive ? Color.primary : Color.onSurfaceVariant)

                Text(label)
                    .font(.lexendBody(12, weight: .semibold))
                    .foregroundColor(isActive ? Color.primary : Color.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isActive ?
                    Color.primaryContainer.opacity(0.3) :
                    Color.clear
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WeeklyProgressChart: View {
    let child: ChildProfile
    @State private var animatedBars: [Double] = Array(repeating: 0, count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Reading Progress")
                    .font(.jakartaDisplay(18, weight: .bold))
                    .foregroundColor(Color.onSurface)

                Spacer()

                Text("\(child.stats.weeklyMinutes) min total")
                    .font(.lexendBody(14, weight: .semibold))
                    .foregroundColor(Color.primary)
            }

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(child.weeklyData.enumerated()), id: \.offset) { index, data in
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.surfaceContainer)
                                .frame(height: 120)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorForData(data.color))
                                .frame(height: 120 * (animatedBars[index] / 100))
                        }
                        .frame(maxWidth: .infinity)

                        Text(data.day)
                            .font(.lexendBody(10, weight: .medium))
                            .foregroundColor(Color.onSurfaceVariant)

                        Text("\(data.minutes)")
                            .font(.lexendBody(12, weight: .bold))
                            .foregroundColor(Color.onSurface)
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                    animatedBars = child.weeklyData.map { Double($0.minutes) }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .popUpShadow()
        .padding(.horizontal)
    }

    func colorForData(_ colorName: String) -> Color {
        switch colorName {
        case "primary": return Color.primary
        case "tertiary": return Color.tertiary
        case "primaryContainer": return Color.primaryContainer
        default: return Color.surfaceContainer
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(color)
                    )

                Spacer()
            }

            Text(value)
                .font(.jakartaDisplay(28, weight: .bold))
                .foregroundColor(Color.onSurface)

            Text(title)
                .font(.lexendBody(12, weight: .medium))
                .foregroundColor(Color.onSurfaceVariant)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .popUpShadow()
    }
}

struct LibraryBookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.primary, Color.primaryContainer],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(3/4, contentMode: .fit)

                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.lexendBody(11, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(book.category)
                    .font(.lexendBody(9, weight: .medium))
                    .foregroundColor(Color.onSurfaceVariant)

                Text("\(Int(book.progress))% Complete")
                    .font(.lexendBody(9, weight: .bold))
                    .foregroundColor(Color.primary)
            }
        }
    }
}
