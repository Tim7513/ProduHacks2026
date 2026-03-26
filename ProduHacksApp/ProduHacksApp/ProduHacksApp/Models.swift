import Foundation

enum UserType {
    case guardian
    case child
}

struct Book: Identifiable {
    let id: String
    let title: String
    let chapter: String?
    let coverUrl: String
    var progress: Double // 0-100
    let category: String
}

struct ReadingStats {
    var wordsRead: Int
    var readingTime: Int // in minutes
    var weeklyMinutes: Int
    var streakDays: Int
    var badges: Int
    var booksCompleted: Int
}

struct WeeklyData: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Int
    let color: String // primary, tertiary, primaryContainer, variant
}

struct ChildProfile: Identifiable {
    let id: String
    var name: String
    var age: Int
    var readingLevel: Int
    var readingComprehension: Double // Base calculation: age * 100
    var stats: ReadingStats
    var weeklyData: [WeeklyData]
    var library: [Book]
    var dailyGoal: Int
    var requiredTestScore: Double
    var readingMinutes: Int
}

struct ReadingPassage: Identifiable, Codable {
    let id: String
    let text: String
    let genre: String
    let difficulty: Int
    let estimatedMinutes: Int
    let difficultWords: [String]
}

struct WordDefinition: Identifiable {
    let id = UUID()
    let word: String
    let definition: String
    let imageData: Data?
}

// Mock Data
class AppData: ObservableObject {
    static let defaultGuardianId = "5d22d0f7-1d4b-4b8b-9620-6f1340f90a11"
    static let leoChildId = "0dbf0d8a-fd03-4d7f-b3ff-1a7ceac4b8f1"
    static let emmaChildId = "b6fbac77-5ecf-46e5-9640-a663dd2f535a"
    static let noahChildId = "9d398752-6b91-4fd5-ad33-2616af2db6aa"

    @Published var currentBook = Book(
        id: "1",
        title: "The Brave Little Star",
        chapter: "Chapter 3: Lost in Space",
        coverUrl: "book-cover-1",
        progress: 75,
        category: "Adventure"
    )

    @Published var stats = ReadingStats(
        wordsRead: 412,
        readingTime: 15,
        weeklyMinutes: 124,
        streakDays: 5,
        badges: 12,
        booksCompleted: 4
    )

    @Published var library: [Book] = [
        Book(
            id: "1",
            title: "The Brave Little Star",
            chapter: nil,
            coverUrl: "book-cover-1",
            progress: 75,
            category: "Adventure"
        ),
        Book(
            id: "2",
            title: "The Brave Little Toaster",
            chapter: nil,
            coverUrl: "book-cover-2",
            progress: 85,
            category: "Adventure"
        ),
        Book(
            id: "3",
            title: "Cloudy with a Chance",
            chapter: nil,
            coverUrl: "book-cover-3",
            progress: 12,
            category: "Fantasy"
        )
    ]

    @Published var weeklyData: [WeeklyData] = [
        WeeklyData(day: "MON", minutes: 45, color: "primary"),
        WeeklyData(day: "TUE", minutes: 65, color: "primary"),
        WeeklyData(day: "WED", minutes: 80, color: "tertiary"),
        WeeklyData(day: "THU", minutes: 35, color: "primaryContainer"),
        WeeklyData(day: "FRI", minutes: 55, color: "primary"),
        WeeklyData(day: "SAT", minutes: 0, color: "variant"),
        WeeklyData(day: "SUN", minutes: 0, color: "variant")
    ]

    @Published var dailyGoal: Int = 15
    @Published var childName: String = "Leo"
    @Published var parentName: String = "Sarah"
    @Published var selectedGenre: String = "Adventure"
    @Published var currentReadingPassage: ReadingPassage?

    // Reading session state - persists across navigation
    @Published var hasAchieved80Percent: Bool = false

    // Onboarding & User Type
    @Published var isFirstLaunch: Bool = true
    @Published var userType: UserType = .child
    @Published var isParentAuthenticated: Bool = false
    @Published var currentGuardianId: String? = nil
    @Published var currentHouseholdUsername: String? = nil
    @Published var authErrorMessage: String? = nil
    @Published var isSyncingWithSupabase = false
    @Published var isSilentReadingModeEnabled = false

    // Multi-child support
    @Published var children: [ChildProfile] = [
        ChildProfile(
            id: AppData.leoChildId,
            name: "Leo",
            age: 8,
            readingLevel: 3,
            readingComprehension: 800, // age * 100
            stats: ReadingStats(
                wordsRead: 412,
                readingTime: 15,
                weeklyMinutes: 124,
                streakDays: 5,
                badges: 12,
                booksCompleted: 4
            ),
            weeklyData: [
                WeeklyData(day: "MON", minutes: 45, color: "primary"),
                WeeklyData(day: "TUE", minutes: 65, color: "primary"),
                WeeklyData(day: "WED", minutes: 80, color: "tertiary"),
                WeeklyData(day: "THU", minutes: 35, color: "primaryContainer"),
                WeeklyData(day: "FRI", minutes: 55, color: "primary"),
                WeeklyData(day: "SAT", minutes: 0, color: "variant"),
                WeeklyData(day: "SUN", minutes: 0, color: "variant")
            ],
            library: [
                Book(id: "1", title: "The Brave Little Star", chapter: nil, coverUrl: "book-cover-1", progress: 75, category: "Adventure"),
                Book(id: "2", title: "The Brave Little Toaster", chapter: nil, coverUrl: "book-cover-2", progress: 85, category: "Adventure"),
                Book(id: "3", title: "Cloudy with a Chance", chapter: nil, coverUrl: "book-cover-3", progress: 12, category: "Fantasy")
            ],
            dailyGoal: 15,
            requiredTestScore: 0.8,
            readingMinutes: 15
        ),
        ChildProfile(
            id: AppData.emmaChildId,
            name: "Emma",
            age: 10,
            readingLevel: 5,
            readingComprehension: 1000,
            stats: ReadingStats(
                wordsRead: 687,
                readingTime: 22,
                weeklyMinutes: 156,
                streakDays: 12,
                badges: 18,
                booksCompleted: 8
            ),
            weeklyData: [
                WeeklyData(day: "MON", minutes: 55, color: "primary"),
                WeeklyData(day: "TUE", minutes: 45, color: "primary"),
                WeeklyData(day: "WED", minutes: 60, color: "tertiary"),
                WeeklyData(day: "THU", minutes: 50, color: "primaryContainer"),
                WeeklyData(day: "FRI", minutes: 70, color: "primary"),
                WeeklyData(day: "SAT", minutes: 30, color: "variant"),
                WeeklyData(day: "SUN", minutes: 25, color: "variant")
            ],
            library: [
                Book(id: "4", title: "Where the Wild Things Are", chapter: nil, coverUrl: "book-cover-4", progress: 60, category: "Adventure"),
                Book(id: "8", title: "Charlotte's Web", chapter: nil, coverUrl: "book-cover-8", progress: 45, category: "Friendship")
            ],
            dailyGoal: 20,
            requiredTestScore: 0.85,
            readingMinutes: 20
        ),
        ChildProfile(
            id: AppData.noahChildId,
            name: "Noah",
            age: 7,
            readingLevel: 2,
            readingComprehension: 700,
            stats: ReadingStats(
                wordsRead: 245,
                readingTime: 10,
                weeklyMinutes: 78,
                streakDays: 3,
                badges: 6,
                booksCompleted: 2
            ),
            weeklyData: [
                WeeklyData(day: "MON", minutes: 25, color: "primary"),
                WeeklyData(day: "TUE", minutes: 30, color: "primary"),
                WeeklyData(day: "WED", minutes: 0, color: "tertiary"),
                WeeklyData(day: "THU", minutes: 35, color: "primaryContainer"),
                WeeklyData(day: "FRI", minutes: 40, color: "primary"),
                WeeklyData(day: "SAT", minutes: 0, color: "variant"),
                WeeklyData(day: "SUN", minutes: 0, color: "variant")
            ],
            library: [
                Book(id: "9", title: "The Cat in the Hat", chapter: nil, coverUrl: "book-cover-9", progress: 90, category: "Fun"),
                Book(id: "10", title: "Green Eggs and Ham", chapter: nil, coverUrl: "book-cover-10", progress: 50, category: "Fun")
            ],
            dailyGoal: 10,
            requiredTestScore: 0.75,
            readingMinutes: 10
        )
    ]

    @Published var selectedChildId: String? = nil
    @Published var readingRequirementMinutes: Int = 1 // Default 1 minute to unlock apps
    @Published var dailyScreenTimeLimitMinutes: Int = 120
    @Published var unlockDurationMinutes: Int = 60

    let mockGenreContent: [String: [String]] = [
        "Adventure": [
            "Mira tightened the straps on her little glider and stepped onto the windy cliff. Below, the sea flashed like scattered coins, and beyond it rose a chain of green islands no one in her village had ever visited. She took one steady breath, leaped into the air, and felt the machine catch the wind. As she glided over the waves, a silver bird circled beside her, almost as if it were guiding her toward a hidden landing place.",
            "The trail through the forest was narrow, damp, and full of roots that twisted like sleeping snakes. Eli held the map with both hands while his flashlight bounced over mossy stones. Somewhere ahead, water dripped in a slow rhythm, and the sound made the cave seem alive. When he rounded the final bend, he froze. In the center of the cavern stood an old bronze door stamped with stars, and its handle was still warm."
        ],
        "Fantasy": [
            "At sunrise, the lantern flowers opened all at once, filling the garden with gold light. Nia knelt beside the tallest stem and whispered the password her grandmother had taught her. The petals folded back like tiny curtains, revealing a staircase made of glowing leaves. Far below, small voices sang in harmony, and a breeze smelling of cinnamon drifted upward from a hidden city beneath the roots.",
            "The river should have flowed straight through the valley, but on moonlit nights it lifted into the air and curled across the sky. Tovin watched from the hill as fish made of light swam through the floating water. Then he noticed a narrow boat with no oars drifting toward him. Inside sat a folded note sealed with blue wax, and his name was written on the front in shimmering ink."
        ],
        "Science": [
            "When Dr. Lin placed the seed in the clear growth chamber, everyone in the lab expected to wait days for results. Instead, tiny sensors showed the roots changing direction within minutes. The plant was not reacting to sunlight or water alone. It was also responding to faint vibrations in the soil, almost as if it could feel the movement of the world around it and choose the safest path to grow.",
            "Far above Earth, a weather satellite circles the planet again and again, taking pictures of clouds, storms, and oceans. The images help scientists notice patterns that are too large to see from the ground. By comparing temperature, wind, and moisture, they can predict where a storm may travel next. This gives communities more time to prepare, protect homes, and move people out of danger."
        ],
        "History": [
            "Before sunrise, the market street was already crowded with carts, baskets, and voices from many different towns. A young apprentice named Tomas hurried between the stalls, carrying rolls of printed paper that still smelled of ink. People gathered to read the latest news because printed pages could now be made much faster than handwritten copies. With each sheet he delivered, ideas traveled farther than they ever had before.",
            "On a cold morning, workers stood beside the new iron tracks and listened for a distant whistle. Soon the train appeared, breathing steam into the air and pulling carriages filled with mail, tools, and passengers. Travel that once took days by wagon could now happen in hours. Towns along the railway began to grow quickly because goods, letters, and people were suddenly able to move with remarkable speed."
        ],
        "Friendship": [
            "Jun noticed that Amara had stopped talking during lunch, even though she was usually the first to laugh at every joke. Instead of pretending not to see, he slid half of his orange across the table and asked if she wanted to walk outside. They sat under the big sycamore tree until she explained what had gone wrong that morning. By the time the bell rang, her shoulders looked lighter.",
            "The new student did not know the rules of the playground games, so Leila stayed back to explain each step slowly. At first, this meant her team started late and nearly lost the round. But by the next game, the new student was passing the ball with confidence and cheering for everyone else. What began as a small act of patience turned into a day when nobody had to feel left out."
        ],
        "Fun": [
            "Baxter the dog had one strange talent: he could tell when pancakes were about to flip. The moment a bubble popped in the batter, he zoomed into the kitchen, slid across the floor, and barked exactly once. On Saturday morning he became so excited that he wore a dish towel like a cape and pranced around the table until even Grandpa laughed hard enough to spill his orange juice.",
            "At the school talent show, Priya rolled onto the stage with a backpack full of rubber ducks. One by one, she lined them up on the piano and tapped each duck's beak to a different note. The crowd stared in confusion for exactly three seconds. Then she began playing a silly marching tune, and soon the whole room was clapping along while the ducks bobbed like a tiny yellow orchestra."
        ]
    ]

    var selectedChild: ChildProfile? {
        children.first { $0.id == selectedChildId }
    }

    var availableGenres: [String] {
        let genres = Set(library.map(\.category)).union(mockGenreContent.keys)
        return genres.sorted()
    }

    func applyRemoteSettings(_ settings: RemoteChildSettings, to childId: String) {
        guard let index = children.firstIndex(where: { $0.id == childId }) else { return }

        children[index].readingLevel = settings.readingLevel
        children[index].readingComprehension = settings.readingComprehension
        children[index].dailyGoal = settings.dailyGoal
        children[index].requiredTestScore = settings.requiredTestScore
        children[index].readingMinutes = settings.readingMinutes
        readingRequirementMinutes = settings.readingRequirementMinutes
        dailyScreenTimeLimitMinutes = settings.dailyScreenTimeLimitMinutes
        unlockDurationMinutes = settings.unlockDurationMinutes

        if selectedChildId == childId {
            childName = children[index].name
        }
    }

    func replaceChildren(with remoteChildren: [RemoteHouseholdChild]) {
        children = remoteChildren.map { child in
            ChildProfile(
                id: child.id,
                name: child.name,
                age: child.age,
                readingLevel: child.readingLevel,
                readingComprehension: child.readingComprehension,
                stats: ReadingStats(
                    wordsRead: 0,
                    readingTime: child.readingMinutes,
                    weeklyMinutes: 0,
                    streakDays: 0,
                    badges: 0,
                    booksCompleted: 0
                ),
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
                dailyGoal: child.dailyGoal,
                requiredTestScore: child.requiredTestScore,
                readingMinutes: child.readingMinutes
            )
        }
    }
}
