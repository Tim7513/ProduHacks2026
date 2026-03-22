import SwiftUI

struct BookLibraryScreen: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData

    // Available books in the full library
    @State private var allAvailableBooks: [Book] = [
        Book(id: "1", title: "The Brave Little Star", chapter: nil, coverUrl: "book-cover-1", progress: 0, category: "Adventure"),
        Book(id: "2", title: "The Brave Little Toaster", chapter: nil, coverUrl: "book-cover-2", progress: 0, category: "Adventure"),
        Book(id: "3", title: "Cloudy with a Chance", chapter: nil, coverUrl: "book-cover-3", progress: 0, category: "Fantasy"),
        Book(id: "4", title: "Where the Wild Things Are", chapter: nil, coverUrl: "book-cover-4", progress: 0, category: "Adventure"),
        Book(id: "5", title: "The Very Hungry Caterpillar", chapter: nil, coverUrl: "book-cover-5", progress: 0, category: "Educational"),
        Book(id: "6", title: "Goodnight Moon", chapter: nil, coverUrl: "book-cover-6", progress: 0, category: "Bedtime"),
        Book(id: "7", title: "The Giving Tree", chapter: nil, coverUrl: "book-cover-7", progress: 0, category: "Life Lessons"),
        Book(id: "8", title: "Charlotte's Web", chapter: nil, coverUrl: "book-cover-8", progress: 0, category: "Friendship"),
        Book(id: "9", title: "The Cat in the Hat", chapter: nil, coverUrl: "book-cover-9", progress: 0, category: "Fun"),
        Book(id: "10", title: "Green Eggs and Ham", chapter: nil, coverUrl: "book-cover-10", progress: 0, category: "Fun"),
        Book(id: "11", title: "Matilda", chapter: nil, coverUrl: "book-cover-11", progress: 0, category: "Adventure"),
        Book(id: "12", title: "The Little Prince", chapter: nil, coverUrl: "book-cover-12", progress: 0, category: "Philosophy")
    ]

    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""

    private var selectedChildIndex: Int? {
        guard let selectedChildId = appData.selectedChildId else { return nil }
        return appData.children.firstIndex(where: { $0.id == selectedChildId })
    }

    private var assignedBooks: [Book] {
        if let selectedChildIndex {
            return appData.children[selectedChildIndex].library
        }

        return appData.library
    }

    var categories: [String] {
        var cats = Set(allAvailableBooks.map { $0.category })
        cats.insert("All")
        return Array(cats).sorted()
    }

    var filteredBooks: [Book] {
        var books = allAvailableBooks

        // Filter by category
        if selectedCategory != "All" {
            books = books.filter { $0.category == selectedCategory }
        }

        // Filter by search
        if !searchText.isEmpty {
            books = books.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }

        return books
    }

    func isBookAssigned(_ book: Book) -> Bool {
        assignedBooks.contains(where: { $0.id == book.id })
    }

    func toggleBookAssignment(_ book: Book) {
        if isBookAssigned(book) {
            if let selectedChildIndex {
                appData.children[selectedChildIndex].library.removeAll(where: { $0.id == book.id })
            } else {
                appData.library.removeAll(where: { $0.id == book.id })
            }
        } else {
            if let selectedChildIndex {
                appData.children[selectedChildIndex].library.append(book)
            } else {
                appData.library.append(book)
            }
        }
    }

    var body: some View {
        ZStack {
            Color.surfaceBackground
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "books.vertical.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color.primary)

                            Text("Book Library")
                                .font(.jakartaDisplay(32, weight: .bold))
                                .foregroundColor(Color.onSurface)

                            Text("Select books for \(appData.childName)")
                                .font(.lexendBody(16, weight: .regular))
                                .foregroundColor(Color.onSurfaceVariant)
                        }
                        .padding(.top, 20)

                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.onSurfaceVariant)

                            TextField("Search books...", text: $searchText)
                                .font(.lexendBody(16, weight: .regular))

                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color.onSurfaceVariant)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .popUpShadow()
                        .padding(.horizontal, 32)

                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.self) { category in
                                    CategoryChip(
                                        title: category,
                                        isSelected: selectedCategory == category,
                                        action: { selectedCategory = category }
                                    )
                                }
                            }
                            .padding(.horizontal, 32)
                        }

                        // Stats Summary
                        HStack(spacing: 16) {
                            StatBadge(
                                icon: "checkmark.circle.fill",
                                count: assignedBooks.count,
                                label: "Assigned",
                                color: Color.primary
                            )

                            StatBadge(
                                icon: "book.fill",
                                count: allAvailableBooks.count,
                                label: "Total Available",
                                color: Color.secondary
                            )
                        }
                        .padding(.horizontal, 32)

                        // Book Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(filteredBooks) { book in
                                SelectableBookCard(
                                    book: book,
                                    isAssigned: isBookAssigned(book),
                                    onToggle: { toggleBookAssignment(book) }
                                )
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    }
                }
            }

            // Back Button
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

                    // Book count badge
                    Text("\(assignedBooks.count) books")
                        .font(.lexendBody(14, weight: .semibold))
                        .foregroundColor(Color.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.primaryContainer.opacity(0.3))
                        .cornerRadius(12)
                }
                .padding()
                Spacer()
            }
        }
    }

// MARK: - Supporting Views

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.lexendBody(14, weight: .semibold))
                .foregroundColor(isSelected ? .white : Color.onSurface)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    LinearGradient(
                        colors: [Color.primary, Color.primaryContainer],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [Color.white, Color.white],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .popUpShadow()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatBadge: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.jakartaDisplay(20, weight: .bold))
                    .foregroundColor(Color.onSurface)

                Text(label)
                    .font(.lexendBody(10, weight: .regular))
                    .foregroundColor(Color.onSurfaceVariant)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .popUpShadow()
    }
}

struct SelectableBookCard: View {
    let book: Book
    let isAssigned: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 12) {
                // Book Cover Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: bookCoverColor(for: book.id)),
                                    Color(hex: bookCoverColor(for: book.id)).opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 140)

                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.8))

                    // Checkmark overlay
                    if isAssigned {
                        VStack {
                            HStack {
                                Spacer()
                                Circle()
                                    .fill(Color.primary)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.lexendBody(14, weight: .semibold))
                        .foregroundColor(Color.onSurface)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(book.category)
                        .font(.lexendBody(10, weight: .regular))
                        .foregroundColor(Color.onSurfaceVariant)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondaryContainer.opacity(0.3))
                        .cornerRadius(6)
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .popUpShadow()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isAssigned ? Color.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // Generate consistent colors based on book ID
    func bookCoverColor(for id: String) -> String {
        let colors = [
            "6366F1", // Indigo
            "8B5CF6", // Purple
            "EC4899", // Pink
            "F59E0B", // Amber
            "10B981", // Emerald
            "3B82F6", // Blue
            "EF4444", // Red
            "14B8A6", // Teal
            "F97316", // Orange
            "A855F7", // Violet
            "06B6D4", // Cyan
            "84CC16"  // Lime
        ]

        let index = Int(id) ?? 0
        return colors[index % colors.count]
    }
}
