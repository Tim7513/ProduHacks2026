import Foundation

// MARK: - Question Types

enum QuestionType: Codable {
    case multipleChoice
    case freeResponse
}

struct MultipleChoiceQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    var userAnswerIndex: Int?

    var isCorrect: Bool {
        guard let userAnswer = userAnswerIndex else { return false }
        return userAnswer == correctAnswerIndex
    }
}

struct FreeResponseQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let acceptedAnswers: [String] // Multiple valid answers
    var userAnswer: String?
    var isVerifiedCorrect: Bool? // nil = pending AI/parent verification

    var needsVerification: Bool {
        return userAnswer != nil && isVerifiedCorrect == nil
    }

    var isCorrect: Bool {
        if let verified = isVerifiedCorrect {
            return verified
        }
        // Simple keyword matching for prototype
        guard let answer = userAnswer?.lowercased() else { return false }
        return acceptedAnswers.contains { accepted in
            answer.contains(accepted.lowercased())
        }
    }
}

// MARK: - Quiz Structure

struct Quiz: Identifiable, Codable {
    let id: String
    let bookId: String
    let passage: String
    var multipleChoiceQuestions: [MultipleChoiceQuestion]
    var freeResponseQuestions: [FreeResponseQuestion]
    let passingScore: Double // 0.0 to 1.0 (e.g., 0.8 = 80%)
    var attemptCount: Int = 0
    var completedAt: Date?

    var totalQuestions: Int {
        multipleChoiceQuestions.count + freeResponseQuestions.count
    }

    var answeredQuestions: Int {
        let mcAnswered = multipleChoiceQuestions.filter { $0.userAnswerIndex != nil }.count
        let frAnswered = freeResponseQuestions.filter { $0.userAnswer != nil }.count
        return mcAnswered + frAnswered
    }

    var correctAnswers: Int {
        let mcCorrect = multipleChoiceQuestions.filter { $0.isCorrect }.count
        let frCorrect = freeResponseQuestions.filter { $0.isCorrect }.count
        return mcCorrect + frCorrect
    }

    var score: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }

    var isPassed: Bool {
        return score >= passingScore
    }

    var isComplete: Bool {
        return answeredQuestions == totalQuestions
    }
}

// MARK: - Unlock System

struct UnlockSession: Codable {
    let id: String
    let quizId: String
    let unlockedAt: Date
    let durationMinutes: Int
    var isActive: Bool {
        let expirationDate = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: unlockedAt)!
        return Date() < expirationDate
    }

    var timeRemaining: TimeInterval {
        let expirationDate = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: unlockedAt)!
        return expirationDate.timeIntervalSince(Date())
    }

    var timeRemainingFormatted: String {
        let remaining = max(0, timeRemaining)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - App Gating Configuration

struct AppGatingConfig: Codable {
    var blockedApps: [String] // Bundle IDs (e.g., "com.zhiliaoapp.musically" for TikTok)
    var requiredReadingMinutes: Int
    var unlockDurationMinutes: Int
    var masterPIN: String?
    var curfewTime: Date? // Apps lock at this time regardless

    static var `default`: AppGatingConfig {
        AppGatingConfig(
            blockedApps: ["com.zhiliaoapp.musically", "com.google.ios.youtube", "com.roblox.robloxmobile"],
            requiredReadingMinutes: 15,
            unlockDurationMinutes: 60,
            masterPIN: nil,
            curfewTime: nil
        )
    }
}

// MARK: - Reading Session

struct ReadingSession: Codable {
    let id: String
    let bookId: String
    let childId: String
    let startedAt: Date
    var completedAt: Date?
    var durationSeconds: Int
    var wordsRead: Int
    var pronunciationAccuracy: Double? // 0.0 to 1.0
    var quiz: Quiz?

    var wordsPerMinute: Double {
        guard durationSeconds > 0 else { return 0 }
        return Double(wordsRead) / (Double(durationSeconds) / 60.0)
    }

    var isComplete: Bool {
        return completedAt != nil && quiz?.isPassed == true
    }
}
