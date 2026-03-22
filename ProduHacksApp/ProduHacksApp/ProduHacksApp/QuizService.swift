import Foundation

@MainActor
class QuizService: ObservableObject {
    static let shared = QuizService()

    @Published var currentQuiz: Quiz?
    @Published var currentUnlockSession: UnlockSession?

    func loadQuiz(for book: Book, passage: ReadingPassage, child: ChildProfile) async {
        currentQuiz = try? await GeminiService.shared.generateQuiz(
            for: passage,
            book: book,
            child: child,
            passingScore: child.requiredTestScore
        )
    }

    // Submit answer for multiple choice question
    func submitAnswer(quizId: String, questionId: String, answerIndex: Int) {
        guard var quiz = currentQuiz, quiz.id == quizId else { return }

        if let index = quiz.multipleChoiceQuestions.firstIndex(where: { $0.id == questionId }) {
            quiz.multipleChoiceQuestions[index].userAnswerIndex = answerIndex
            currentQuiz = quiz
        }
    }

    // Submit answer for free response question
    func submitFreeResponse(quizId: String, questionId: String, answer: String) {
        guard var quiz = currentQuiz, quiz.id == quizId else { return }

        if let index = quiz.freeResponseQuestions.firstIndex(where: { $0.id == questionId }) {
            quiz.freeResponseQuestions[index].userAnswer = answer
            // For prototype: auto-verify using keyword matching
            // TODO: Replace with AI verification
            currentQuiz = quiz
        }
    }

    func completeQuiz(
        child: ChildProfile,
        passage: ReadingPassage?,
        unlockDurationMinutes: Int
    ) async -> QuizCompletionResult {
        guard var quiz = currentQuiz else {
            return QuizCompletionResult(passed: false, score: 0, unlockSession: nil, comprehensionDelta: 0)
        }

        if let passage {
            for index in quiz.freeResponseQuestions.indices {
                let question = quiz.freeResponseQuestions[index]
                let isCorrect = await GeminiService.shared.evaluateFreeResponse(
                    question: question.question,
                    answer: question.userAnswer ?? "",
                    expectedConcepts: question.acceptedAnswers,
                    passage: passage.text,
                    child: child
                )
                quiz.freeResponseQuestions[index].isVerifiedCorrect = isCorrect
            }
        }

        quiz.completedAt = Date()
        quiz.attemptCount += 1
        currentQuiz = quiz

        let passed = quiz.isPassed
        let score = quiz.score

        // Create unlock session if passed
        var unlockSession: UnlockSession? = nil
        if passed {
            unlockSession = UnlockSession(
                id: UUID().uuidString,
                quizId: quiz.id,
                unlockedAt: Date(),
                durationMinutes: unlockDurationMinutes
            )
            currentUnlockSession = unlockSession
        }

        return QuizCompletionResult(
            passed: passed,
            score: score,
            unlockSession: unlockSession,
            comprehensionDelta: comprehensionDelta(for: quiz)
        )
    }

    // Check if apps are currently unlocked
    func isUnlocked() -> Bool {
        return currentUnlockSession?.isActive ?? false
    }

    // Get time remaining in unlock session
    func getTimeRemaining() -> String? {
        return currentUnlockSession?.timeRemainingFormatted
    }

    // Verify master PIN
    func verifyMasterPIN(_ pin: String, config: AppGatingConfig) -> Bool {
        return config.masterPIN == pin
    }

    private func comprehensionDelta(for quiz: Quiz) -> Double {
        let mcDelta = quiz.multipleChoiceQuestions.reduce(0.0) { partial, question in
            partial + (question.isCorrect ? 5.0 : -3.0)
        }
        let frDelta = quiz.freeResponseQuestions.reduce(0.0) { partial, question in
            partial + (question.isCorrect ? 7.0 : -3.0)
        }

        return mcDelta + frDelta
    }
}
