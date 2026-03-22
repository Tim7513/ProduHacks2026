import SwiftUI
import AVFoundation

struct ReadingScreen: View {
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var appData: AppData
    @StateObject private var speechService = SpeechRecognitionService()
    @State private var timeRemainingSeconds: Int = 15 * 60
    @State private var isPulsing = false
    @State private var timer: Timer?
    @State private var hasRequestedPermissions = false
    @State private var showPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @State private var selectedWord: String? = nil
    @State private var showWordDetail = false
    @State private var isGeneratingPassage = true
    @State private var passageLoadingMessage = "Creating a reading passage..."

    private var activeChild: ChildProfile? {
        appData.selectedChild ?? appData.children.first
    }

    private var passageText: String {
        appData.currentReadingPassage?.text ?? ""
    }

    private var difficultWords: Set<String> {
        Set(appData.currentReadingPassage?.difficultWords.map { $0.lowercased() } ?? [])
    }

    private var timeRemainingFormatted: String {
        let minutes = timeRemainingSeconds / 60
        let seconds = timeRemainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var canProceedToQuiz: Bool {
        if appData.isSilentReadingModeEnabled {
            return true
        }

        if appData.hasAchieved80Percent {
            return true
        }

        let accuracy = speechService.calculatePronunciationAccuracy()
        return !speechService.recognizedWords.isEmpty && accuracy >= 0.8
    }

    private var currentAccuracy: Double {
        speechService.calculatePronunciationAccuracy()
    }

    var body: some View {
        ZStack {
            Color.surfaceBackground
                .ignoresSafeArea()

            if isGeneratingPassage {
                loadingView
            } else {
                contentView
            }
        }
        .task {
            await prepareReadingSession()
        }
        .onDisappear {
            stopTimer()
            if speechService.isListening {
                speechService.stopListening()
            }
        }
        .onChange(of: speechService.recognizedWords) { _, newValue in
            let accuracy = speechService.calculatePronunciationAccuracy()
            if !appData.hasAchieved80Percent && accuracy >= 0.8 && !newValue.isEmpty {
                appData.hasAchieved80Percent = true
            }
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Permission Required"),
                message: Text(permissionAlertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showWordDetail) {
            if let word = selectedWord, let passage = appData.currentReadingPassage, let child = activeChild {
                WordDetailView(word: word, passage: passage, child: child)
            }
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            headerView
            passageMetaView
            textView
            controlsView
            if !appData.isSilentReadingModeEnabled && !canProceedToQuiz && !speechService.recognizedWords.isEmpty {
                accuracyFooter
            }
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: {
                withAnimation {
                    currentScreen = .lock
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                    Text(appData.currentReadingPassage?.genre ?? appData.selectedGenre)
                        .font(.jakartaDisplay(18, weight: .semibold))
                }
                .foregroundColor(Color.onSurface)
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "target")
                    .font(.system(size: 16))
                Text(timeRemainingFormatted)
                    .font(.lexendBody(16, weight: .bold))
            }
            .foregroundColor(Color.onTertiaryContainer)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.tertiaryContainer)
            .cornerRadius(16)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private var passageMetaView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Passage")
                        .font(.lexendBody(14, weight: .semibold))
                        .foregroundColor(Color.onSurface)
                    Text("\(appData.currentReadingPassage?.estimatedMinutes ?? 0) min • \(appData.selectedGenre)")
                        .font(.lexendBody(12, weight: .regular))
                        .foregroundColor(Color.onSurfaceVariant)
                }

                Spacer()

                Text("Keep going, \(appData.childName)!")
                    .font(.lexendBody(12, weight: .medium))
                    .foregroundColor(Color.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.surfaceContainer)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.secondary, Color.secondaryContainer],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(currentAccuracy, 1), height: 8)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var textView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    FlowLayout(spacing: 12) {
                        ForEach(Array(speechService.recognizedWords.enumerated()), id: \.element.id) { index, recognizedWord in
                            Text(recognizedWord.word)
                                .font(.jakartaDisplay(32, weight: .semibold))
                                .foregroundColor(wordColor(for: recognizedWord))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(wordBackground(for: recognizedWord))
                                .cornerRadius(8)
                                .overlay(alignment: .bottom) {
                                    let cleanWord = recognizedWord.word.trimmingCharacters(in: .punctuationCharacters).lowercased()
                                    if difficultWords.contains(cleanWord) && !recognizedWord.wasSpoken {
                                        Rectangle()
                                            .fill(Color.primary.opacity(0.5))
                                            .frame(height: 2)
                                            .offset(y: 6)
                                    }
                                }
                                .id("word_\(index)")
                                .onTapGesture {
                                    let cleanWord = recognizedWord.word.trimmingCharacters(in: .punctuationCharacters)
                                    if difficultWords.contains(cleanWord.lowercased()) {
                                        selectedWord = cleanWord
                                        showWordDetail = true
                                    }
                                }
                        }
                    }
                    .padding(24)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: speechService.recognizedWords) { _, newValue in
                if let lastSpokenIndex = newValue.lastIndex(where: { $0.wasSpoken }) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo("word_\(lastSpokenIndex)", anchor: .center)
                    }
                }
            }
        }
    }

    private var controlsView: some View {
        HStack(spacing: 12) {
            if appData.isSilentReadingModeEnabled {
                Label("Silent mode", systemImage: "ear.slash.fill")
                    .font(.lexendBody(14, weight: .semibold))
                    .foregroundColor(Color.onSurface)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.primaryContainer.opacity(0.25))
                    .cornerRadius(14)
            } else {
                Button(action: {
                    toggleListening()
                }) {
                    ZStack {
                        if speechService.isListening {
                            Circle()
                                .stroke(Color.red.opacity(0.3), lineWidth: 3)
                                .frame(width: 64, height: 64)
                                .scaleEffect(isPulsing ? 1.3 : 1.0)
                                .opacity(isPulsing ? 0 : 1)
                        }

                        Image(systemName: speechService.isListening ? "mic.fill" : "mic")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(speechService.isListening ? .white : Color.onSurface)
                            .frame(width: 56, height: 56)
                            .background(
                                speechService.isListening
                                ? LinearGradient(colors: [Color.red, Color.red.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .glassPanel()
                            .cornerRadius(16)
                    }
                }
            }

            Spacer()

            Button(action: {
                if canProceedToQuiz {
                    withAnimation {
                        currentScreen = .quiz
                    }
                }
            }) {
                Image(systemName: canProceedToQuiz ? "checkmark.circle.fill" : "lock.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        canProceedToQuiz
                        ? LinearGradient(colors: [Color.secondary, Color.secondaryContainer], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(
                            colors: [Color.onSurfaceVariant.opacity(0.3), Color.onSurfaceVariant.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .opacity(canProceedToQuiz ? 1.0 : 0.5)
            }
            .disabled(!canProceedToQuiz)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private var accuracyFooter: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(currentAccuracy >= 0.8 ? Color.secondary : Color.tertiary)

                Text(currentAccuracy >= 0.8 ? "Great job! Tap ✓ to continue" : "Read with 80% accuracy to unlock quiz")
                    .font(.lexendBody(13, weight: .medium))
                    .foregroundColor(Color.onSurface)

                Spacer()

                Text("\(Int(currentAccuracy * 100))%")
                    .font(.lexendBody(14, weight: .bold))
                    .foregroundColor(currentAccuracy >= 0.8 ? Color.secondary : Color.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                currentAccuracy >= 0.8
                ? Color.secondaryContainer.opacity(0.3)
                : Color.tertiaryContainer.opacity(0.3)
            )
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.3)
                .tint(Color.primary)

            Text("Preparing your reading")
                .font(.jakartaDisplay(28, weight: .bold))
                .foregroundColor(Color.onSurface)

            Text(passageLoadingMessage)
                .font(.lexendBody(16, weight: .regular))
                .foregroundColor(Color.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(32)
    }

    @MainActor
    private func prepareReadingSession() async {
        if !appData.isSilentReadingModeEnabled {
            requestPermissionsIfNeeded()
        }

        guard let child = activeChild else {
            isGeneratingPassage = false
            return
        }

        let requiredMinutes = max(1, appData.readingRequirementMinutes)
        timeRemainingSeconds = requiredMinutes * 60

        if appData.currentReadingPassage == nil {
            let genre = appData.selectedGenre
            let sourceParagraphs = appData.mockGenreContent[genre] ?? appData.mockGenreContent["Adventure"] ?? []
            passageLoadingMessage = "Finding a \(genre.lowercased()) passage for \(child.name)..."

            do {
                appData.currentReadingPassage = try await GeminiService.shared.generatePassage(
                    genre: genre,
                    child: child,
                    durationMinutes: requiredMinutes,
                    sourceParagraphs: sourceParagraphs
                )
            } catch {
                permissionAlertMessage = "Couldn't generate a reading passage right now."
                showPermissionAlert = true
            }
        }

        speechService.prepareText(passageText)
        isGeneratingPassage = false
        startTimer()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemainingSeconds > 0 {
                timeRemainingSeconds -= 1
            } else {
                stopTimer()
                withAnimation {
                    currentScreen = .quiz
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func requestPermissionsIfNeeded() {
        guard !hasRequestedPermissions else { return }
        hasRequestedPermissions = true

        speechService.requestAuthorization { authorized in
            if !authorized {
                permissionAlertMessage = "Speech recognition permission is required to provide pronunciation feedback. Please enable it in Settings."
                showPermissionAlert = true
            } else {
                speechService.requestMicrophonePermission { granted in
                    if !granted {
                        permissionAlertMessage = "Microphone access is required to listen to your reading. Please enable it in Settings."
                        showPermissionAlert = true
                    }
                }
            }
        }
    }

    private func toggleListening() {
        if speechService.isListening {
            speechService.stopListening()
            return
        }

        guard speechService.authorizationStatus == .authorized else {
            permissionAlertMessage = "Please grant speech recognition permission in Settings to use this feature."
            showPermissionAlert = true
            return
        }

        do {
            try speechService.startListening(expectedText: passageText)
        } catch {
            permissionAlertMessage = "Failed to start listening: \(error.localizedDescription)"
            showPermissionAlert = true
        }
    }

    private func wordColor(for recognizedWord: RecognizedWord) -> Color {
        switch recognizedWord.color {
        case "green":
            return Color.white
        case "red":
            return Color.white
        default:
            return Color.onSurface.opacity(0.4)
        }
    }

    private func wordBackground(for recognizedWord: RecognizedWord) -> Color {
        switch recognizedWord.color {
        case "green":
            return Color.secondary.opacity(0.9)
        case "red":
            return Color.red.opacity(0.9)
        default:
            let cleanWord = recognizedWord.word.trimmingCharacters(in: .punctuationCharacters).lowercased()
            return difficultWords.contains(cleanWord) ? Color.primaryContainer.opacity(0.25) : Color.clear
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

struct WordDetailView: View {
    let word: String
    let passage: ReadingPassage
    let child: ChildProfile

    @Environment(\.dismiss) private var dismiss
    @State private var isPlayingAudio = false
    @State private var definition = WordDefinition(word: "", definition: "Loading definition...", imageData: nil)
    @State private var isLoading = true

    private let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text(word)
                        .font(.jakartaDisplay(48, weight: .bold))
                        .foregroundColor(Color.primary)
                        .padding(.top, 40)

                    Button(action: {
                        speakWord()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: isPlayingAudio ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 24))
                            Text("Hear Pronunciation")
                                .font(.lexendBody(18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.primary, Color.primaryContainer],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                    }

                    if let imageData = definition.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
                    } else if isLoading {
                        ProgressView()
                            .tint(Color.primary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Definition")
                            .font(.lexendBody(16, weight: .bold))
                            .foregroundColor(Color.primary)

                        Text(definition.definition)
                            .font(.lexendBody(16, weight: .regular))
                            .foregroundColor(Color.onSurfaceVariant)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.surfaceContainer)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Word Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadDefinition()
        }
    }

    @MainActor
    private func loadDefinition() async {
        isLoading = true
        definition = (try? await GeminiService.shared.generateWordDefinition(for: word, in: passage, child: child))
            ?? WordDefinition(word: word, definition: "This word helps explain an important idea in the passage.", imageData: nil)
        isLoading = false
    }

    private func speakWord() {
        isPlayingAudio = true

        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0

        speechSynthesizer.speak(utterance)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isPlayingAudio = false
        }
    }
}
