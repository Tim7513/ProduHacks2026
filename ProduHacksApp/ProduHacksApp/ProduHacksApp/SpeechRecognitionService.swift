import Foundation
import Speech
import AVFoundation

class SpeechRecognitionService: ObservableObject {
    @Published var isListening = false
    @Published var transcribedText: String = ""
    @Published var recognizedWords: [RecognizedWord] = []
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // Expected text for comparison
    private var expectedWords: [String] = []  // Cleaned words for matching
    private var originalWords: [String] = []  // Original words with punctuation for display
    private var currentWordIndex: Int = 0

    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.defaultTaskHint = .dictation
    }

    // MARK: - Authorization

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status
                completion(status == .authorized)
            }
        }
    }

    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - Speech Recognition

    /// Prepares the text for display without starting audio recording
    /// This initializes recognizedWords with all words in unspoken state
    func prepareText(_ text: String) {
        let allWords = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        // Keep original words with punctuation for display
        originalWords = allWords

        // Clean words for matching (no punctuation, lowercase)
        expectedWords = allWords.map { $0.trimmingCharacters(in: .punctuationCharacters).lowercased() }

        // Initialize recognizedWords with all words in unspoken state
        recognizedWords = originalWords.map { word in
            RecognizedWord(word: word, isCorrect: false, wasSpoken: false)
        }
    }

    func startListening(expectedText: String) throws {
        // Cancel previous task if exists
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        // Set expected words for comparison
        let allWords = expectedText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        // Keep original words with punctuation for display
        originalWords = allWords

        // Clean words for matching (no punctuation, lowercase)
        expectedWords = allWords.map { $0.trimmingCharacters(in: .punctuationCharacters).lowercased() }

        currentWordIndex = 0

        // Initialize recognizedWords with all words in unspoken state
        // This preserves layout, punctuation, and capitalization from the start
        recognizedWords = originalWords.map { word in
            RecognizedWord(word: word, isCorrect: false, wasSpoken: false)
        }

        transcribedText = ""

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "SpeechRecognition", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false // Use server for better accuracy

        // Get input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Install tap on input node
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()

        // Start recognition task
        isListening = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            var isFinal = false

            if let result = result {
                isFinal = result.isFinal
                self.processRecognitionResult(result)
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isListening = false
            }
        }
    }

    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest = nil
        recognitionTask = nil
        isListening = false
    }

    // MARK: - Process Recognition

    private func processRecognitionResult(_ result: SFSpeechRecognitionResult) {
        let bestTranscription = result.bestTranscription
        transcribedText = bestTranscription.formattedString

        // Split transcribed text into words
        let spokenWords = transcribedText.components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters).lowercased() }
            .filter { !$0.isEmpty }

        // Compare with expected words
        recognizedWords = expectedWords.enumerated().map { index, expectedWord in
            let isCorrect: Bool
            let wasSpoken: Bool

            if index < spokenWords.count {
                wasSpoken = true
                // Fuzzy match using Levenshtein distance or exact match
                isCorrect = areSimilar(spokenWords[index], expectedWord)
            } else {
                wasSpoken = false
                isCorrect = false
            }

            // Use original word with punctuation for display
            let displayWord = index < originalWords.count ? originalWords[index] : expectedWord

            return RecognizedWord(
                word: displayWord,
                isCorrect: isCorrect,
                wasSpoken: wasSpoken
            )
        }
    }

    // MARK: - Pronunciation Scoring

    func calculatePronunciationAccuracy() -> Double {
        guard !recognizedWords.isEmpty else { return 0.0 }

        let correctWords = recognizedWords.filter { $0.isCorrect && $0.wasSpoken }.count
        return Double(correctWords) / Double(recognizedWords.count)
    }

    // Simple similarity check (can be enhanced with Levenshtein distance)
    private func areSimilar(_ word1: String, _ word2: String) -> Bool {
        // Exact match
        if word1 == word2 {
            return true
        }

        // Allow for minor pronunciation differences
        let distance = levenshteinDistance(word1, word2)
        let maxLength = max(word1.count, word2.count)

        // Allow 1-2 character difference for longer words
        if maxLength > 5 {
            return distance <= 2
        } else if maxLength > 3 {
            return distance <= 1
        } else {
            return distance == 0 // Short words must be exact
        }
    }

    // Levenshtein distance algorithm
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1 = Array(s1)
        let s2 = Array(s2)

        var matrix = [[Int]](repeating: [Int](repeating: 0, count: s2.count + 1), count: s1.count + 1)

        for i in 0...s1.count {
            matrix[i][0] = i
        }

        for j in 0...s2.count {
            matrix[0][j] = j
        }

        for i in 1...s1.count {
            for j in 1...s2.count {
                if s1[i-1] == s2[j-1] {
                    matrix[i][j] = matrix[i-1][j-1]
                } else {
                    matrix[i][j] = min(
                        matrix[i-1][j] + 1,    // deletion
                        matrix[i][j-1] + 1,    // insertion
                        matrix[i-1][j-1] + 1   // substitution
                    )
                }
            }
        }

        return matrix[s1.count][s2.count]
    }
}

// MARK: - Models

struct RecognizedWord: Identifiable, Equatable {
    let id = UUID()
    let word: String
    let isCorrect: Bool
    let wasSpoken: Bool

    var color: String {
        if !wasSpoken {
            return "gray" // Not yet spoken
        } else if isCorrect {
            return "green" // Correctly pronounced
        } else {
            return "red" // Incorrectly pronounced
        }
    }

    // Equatable conformance - compare by properties, not id
    static func == (lhs: RecognizedWord, rhs: RecognizedWord) -> Bool {
        return lhs.word == rhs.word &&
               lhs.isCorrect == rhs.isCorrect &&
               lhs.wasSpoken == rhs.wasSpoken
    }
}
