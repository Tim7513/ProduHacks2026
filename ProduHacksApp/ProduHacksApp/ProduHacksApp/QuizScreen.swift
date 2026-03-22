import SwiftUI

struct QuizScreen: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData
    @ObservedObject private var quizService = QuizService.shared

    @State private var currentQuestionIndex = 0
    @State private var selectedMCAnswer: Int? = nil
    @State private var freeResponseText: String = ""
    @State private var showResults = false
    @State private var quizPassed = false
    @State private var finalScore: Double = 0
    @State private var isLoadingQuiz = true
    @State private var isSubmittingQuiz = false

    private var activeChild: ChildProfile? {
        appData.selectedChild ?? appData.children.first
    }

    private var activePassage: ReadingPassage? {
        appData.currentReadingPassage
    }

    var body: some View {
        ZStack {
            Color.surfaceBackground
                .ignoresSafeArea()

            if isLoadingQuiz {
                loadingView
            } else if showResults {
                resultsView
            } else {
                quizView
            }
        }
        .task {
            await loadQuizIfNeeded()
        }
    }

    // MARK: - Quiz View

    var quizView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    withAnimation {
                        currentScreen = .reading
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Back to Reading")
                            .font(.lexendBody(16, weight: .semibold))
                    }
                    .foregroundColor(Color.onSurface)
                }

                Spacer()

                // Progress indicator
                HStack(spacing: 6) {
                    ForEach(0..<totalQuestions, id: \.self) { index in
                        Circle()
                            .fill(index < currentQuestionIndex ? Color.primary : Color.surfaceContainer)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)

            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 20)

                    // Question header
                    VStack(spacing: 12) {
                        Text("Question \(currentQuestionIndex + 1) of \(totalQuestions)")
                            .font(.lexendBody(14, weight: .medium))
                            .foregroundColor(Color.onSurfaceVariant)

                        Text(currentQuestion)
                            .font(.jakartaDisplay(24, weight: .bold))
                            .foregroundColor(Color.onSurface)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Question content
                    if isMultipleChoice {
                        multipleChoiceView
                    } else {
                        freeResponseView
                    }

                    Spacer().frame(height: 40)
                }
            }

            // Bottom action button
            VStack(spacing: 0) {
                Divider()

                CustomButton(
                    title: isLastQuestion ? "Submit Quiz" : "Next Question",
                    icon: isLastQuestion ? "checkmark.circle.fill" : "arrow.right",
                    variant: .primary
                ) {
                    handleNextQuestion()
                }
                .padding()
                .disabled(!canProceed)
                .opacity(canProceed ? 1.0 : 0.5)
            }
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Multiple Choice View

    var multipleChoiceView: some View {
        VStack(spacing: 16) {
            ForEach(Array(currentMCOptions.enumerated()), id: \.offset) { index, option in
                Button(action: {
                    selectedMCAnswer = index
                    if let quiz = quizService.currentQuiz {
                        quizService.submitAnswer(
                            quizId: quiz.id,
                            questionId: currentMCQuestionId,
                            answerIndex: index
                        )
                    }
                }) {
                    HStack {
                        Text(option)
                            .font(.lexendBody(16, weight: .medium))
                            .foregroundColor(selectedMCAnswer == index ? .white : Color.onSurface)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if selectedMCAnswer == index {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        selectedMCAnswer == index ?
                            LinearGradient(
                                colors: [Color.primary, Color.primaryContainer],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
                    .popUpShadow()
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Free Response View

    var freeResponseView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Type your answer:")
                .font(.lexendBody(14, weight: .medium))
                .foregroundColor(Color.onSurfaceVariant)

            ZStack(alignment: .topLeading) {
                if freeResponseText.isEmpty {
                    Text("Share your thoughts here...")
                        .font(.lexendBody(16, weight: .regular))
                        .foregroundColor(Color.onSurfaceVariant.opacity(0.5))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }

                TextEditor(text: $freeResponseText)
                    .font(.lexendBody(16, weight: .regular))
                    .foregroundColor(Color.onSurface)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .frame(minHeight: 150)
                    .scrollContentBackground(.hidden)
                    .onChange(of: freeResponseText) { _, newValue in
                        if let quiz = quizService.currentQuiz {
                            quizService.submitFreeResponse(
                                quizId: quiz.id,
                                questionId: currentFRQuestionId,
                                answer: newValue
                            )
                        }
                    }
            }
            .background(Color.white)
            .cornerRadius(16)
            .popUpShadow()

            Text("💡 Tip: Answer in complete sentences for best results")
                .font(.lexendBody(12, weight: .regular))
                .foregroundColor(Color.onSurfaceVariant)
        }
        .padding(.horizontal)
    }

    // MARK: - Loading View

    var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.primary)

            Text(isSubmittingQuiz ? "Checking Answers..." : "Generating Quiz...")
                .font(.jakartaDisplay(24, weight: .semibold))
                .foregroundColor(Color.onSurface)

            Text(isSubmittingQuiz ? "We’re reviewing your answers and updating your reading score." : "Hold tight! We're creating personalized questions for you.")
                .font(.lexendBody(16, weight: .regular))
                .foregroundColor(Color.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Results View

    var resultsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                ZStack {
                    Circle()
                        .fill(quizPassed ? Color.secondaryContainer : Color.red.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: quizPassed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(quizPassed ? Color.secondary : .red)
                }

                VStack(spacing: 12) {
                    Text(quizPassed ? "Quiz Passed!" : "Not Quite...")
                        .font(.jakartaDisplay(40, weight: .bold))
                        .foregroundColor(quizPassed ? Color.primary : .red)

                    Text("You scored \(Int(finalScore * 100))%")
                        .font(.lexendBody(20, weight: .medium))
                        .foregroundColor(Color.onSurfaceVariant)

                    if !quizPassed {
                        Text("You need \(Int((activeChild?.requiredTestScore ?? 0.8) * 100))% to unlock your apps")
                            .font(.lexendBody(16, weight: .regular))
                            .foregroundColor(Color.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                    }
                }

                answerReviewSection

                VStack(spacing: 16) {
                    if quizPassed {
                        CustomButton(
                            title: "See Results",
                            icon: "chart.bar.fill",
                            variant: .primary
                        ) {
                            withAnimation {
                                currentScreen = .summary
                            }
                        }
                    } else {
                        CustomButton(
                            title: "Generate New Quiz",
                            icon: "arrow.clockwise",
                            variant: .primary
                        ) {
                            retryQuiz()
                        }

                        Button(action: {
                            withAnimation {
                                currentScreen = .reading
                            }
                        }) {
                            Text("Back to Reading")
                                .font(.lexendBody(16, weight: .semibold))
                                .foregroundColor(Color.primary)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 24)
            }
            .padding()
        }
    }

    private var answerReviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Answers")
                .font(.jakartaDisplay(28, weight: .bold))
                .foregroundColor(Color.onSurface)

            if let quiz = quizService.currentQuiz {
                ForEach(Array(quiz.multipleChoiceQuestions.enumerated()), id: \.element.id) { index, question in
                    AnswerReviewCard(
                        number: index + 1,
                        question: question.question,
                        userAnswer: question.userAnswerIndex.flatMap { question.options.indices.contains($0) ? question.options[$0] : nil } ?? "No answer",
                        correctAnswer: question.options[question.correctAnswerIndex],
                        isCorrect: question.isCorrect
                    )
                }

                ForEach(Array(quiz.freeResponseQuestions.enumerated()), id: \.element.id) { index, question in
                    AnswerReviewCard(
                        number: quiz.multipleChoiceQuestions.count + index + 1,
                        question: question.question,
                        userAnswer: question.userAnswer?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? question.userAnswer! : "No answer",
                        correctAnswer: question.acceptedAnswers.joined(separator: ", "),
                        isCorrect: question.isCorrect
                    )
                }
            }
        }
    }

    // MARK: - Helper Properties

    var totalQuestions: Int {
        guard let quiz = quizService.currentQuiz else { return 0 }
        return quiz.totalQuestions
    }

    var isMultipleChoice: Bool {
        guard let quiz = quizService.currentQuiz else { return true }
        return currentQuestionIndex < quiz.multipleChoiceQuestions.count
    }

    var currentQuestion: String {
        guard let quiz = quizService.currentQuiz else { return "" }

        if isMultipleChoice {
            let mcIndex = currentQuestionIndex
            return quiz.multipleChoiceQuestions[mcIndex].question
        } else {
            let frIndex = currentQuestionIndex - quiz.multipleChoiceQuestions.count
            return quiz.freeResponseQuestions[frIndex].question
        }
    }

    var currentMCOptions: [String] {
        guard let quiz = quizService.currentQuiz, isMultipleChoice else { return [] }
        let mcIndex = currentQuestionIndex
        return quiz.multipleChoiceQuestions[mcIndex].options
    }

    var currentMCQuestionId: String {
        guard let quiz = quizService.currentQuiz, isMultipleChoice else { return "" }
        let mcIndex = currentQuestionIndex
        return quiz.multipleChoiceQuestions[mcIndex].id
    }

    var currentFRQuestionId: String {
        guard let quiz = quizService.currentQuiz, !isMultipleChoice else { return "" }
        let frIndex = currentQuestionIndex - quiz.multipleChoiceQuestions.count
        return quiz.freeResponseQuestions[frIndex].id
    }

    var isLastQuestion: Bool {
        return currentQuestionIndex == totalQuestions - 1
    }

    var canProceed: Bool {
        if isMultipleChoice {
            return selectedMCAnswer != nil
        } else {
            return !freeResponseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    // MARK: - Actions

    func handleNextQuestion() {
        if isLastQuestion {
            Task {
                await submitQuiz()
            }
        } else {
            // Move to next question
            withAnimation {
                currentQuestionIndex += 1
                selectedMCAnswer = nil
                freeResponseText = ""
            }
        }
    }

    func retryQuiz() {
        withAnimation {
            currentQuestionIndex = 0
            selectedMCAnswer = nil
            freeResponseText = ""
            showResults = false
        }
        quizService.currentQuiz = nil
        isLoadingQuiz = true
        Task {
            await loadQuizIfNeeded(forceReload: true)
        }
    }

    @MainActor
    private func loadQuizIfNeeded(forceReload: Bool = false) async {
        guard let child = activeChild, let passage = activePassage else {
            isLoadingQuiz = false
            return
        }

        if forceReload {
            quizService.currentQuiz = nil
        }

        guard quizService.currentQuiz == nil else {
            isLoadingQuiz = false
            return
        }

        await quizService.loadQuiz(for: appData.currentBook, passage: passage, child: child)
        isLoadingQuiz = false
    }

    @MainActor
    private func submitQuiz() async {
        guard let child = activeChild else { return }

        isSubmittingQuiz = true
        isLoadingQuiz = true

        let result = await quizService.completeQuiz(
            child: child,
            passage: activePassage,
            unlockDurationMinutes: 60
        )

        applyComprehensionDelta(result.comprehensionDelta)

        quizPassed = result.passed
        finalScore = result.score
        isSubmittingQuiz = false
        isLoadingQuiz = false

        withAnimation {
            showResults = true
        }
    }

    private func applyComprehensionDelta(_ delta: Double) {
        guard let selectedChildId = appData.selectedChildId,
              let index = appData.children.firstIndex(where: { $0.id == selectedChildId }) else {
            return
        }

        let baseScore = Double(appData.children[index].age * 100)
        let updated = max(baseScore * 0.5, appData.children[index].readingComprehension + delta)
        appData.children[index].readingComprehension = updated
    }
}

private struct AnswerReviewCard: View {
    let number: Int
    let question: String
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(isCorrect ? Color.secondary : Color.red.opacity(0.85))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: isCorrect ? "checkmark" : "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    )

                Text("Question \(number)")
                    .font(.lexendBody(14, weight: .semibold))
                    .foregroundColor(Color.onSurfaceVariant)
            }

            Text(question)
                .font(.lexendBody(17, weight: .semibold))
                .foregroundColor(Color.onSurface)

            VStack(alignment: .leading, spacing: 8) {
                Text("Your answer")
                    .font(.lexendBody(12, weight: .semibold))
                    .foregroundColor(Color.onSurfaceVariant)
                Text(userAnswer)
                    .font(.lexendBody(15, weight: .regular))
                    .foregroundColor(Color.onSurface)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Correct answer")
                    .font(.lexendBody(12, weight: .semibold))
                    .foregroundColor(isCorrect ? Color.secondary : Color.primary)
                Text(correctAnswer)
                    .font(.lexendBody(15, weight: .regular))
                    .foregroundColor(Color.onSurface)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .popUpShadow()
    }
}
