import Foundation

struct QuizCompletionResult {
    let passed: Bool
    let score: Double
    let unlockSession: UnlockSession?
    let comprehensionDelta: Double
}

final class GeminiService {
    static let shared = GeminiService()

    private let textModel = "gemini-2.5-flash"
    private let imageModel = "gemini-3.1-flash-image-preview"
    private let baseURL = URL(string: "https://generativelanguage.googleapis.com/v1beta/models")!
    private let session = URLSession.shared

    private init() {}

    private var apiKey: String? {
        guard let rawValue = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String else {
            return nil
        }

        return rawValue.sanitizedConfigurationValue
    }

    func generatePassage(
        genre: String,
        child: ChildProfile,
        durationMinutes: Int,
        sourceParagraphs: [String]
    ) async throws -> ReadingPassage {
        let wordRange = targetWordRange(for: durationMinutes, child: child)

        guard let apiKey else {
            return fallbackPassage(genre: genre, child: child, durationMinutes: durationMinutes, sourceParagraphs: sourceParagraphs)
        }

        let prompt = """
        You are creating a reading passage for a child.

        Constraints:
        - Genre: \(genre)
        - Reading level: \(child.readingLevel)
        - Reading comprehension metric: \(Int(child.readingComprehension))
        - Target reading time in minutes: \(durationMinutes)
        - Write approximately \(wordRange.lowerBound)-\(wordRange.upperBound) words total.
        - Keep it to one short paragraph.
        - Use the source material below as inspiration and source content. Stay in the same genre and keep the content child-safe.
        - Return valid JSON only.
        - Output schema:
          {
            "text": "string",
            "genre": "string",
            "difficulty": 1,
            "estimated_minutes": 1,
            "difficult_words": ["word"]
          }
        - Keep difficult_words to 3-7 genuinely harder words suitable for this child.
        - Make the passage length appropriate for the target time.
        - Do not exceed \(wordRange.upperBound) words.
        - Prioritize a short, finishable passage over adding extra detail.

        Source material:
        \(sourceParagraphs.joined(separator: "\n\n"))
        """

        do {
            let text = try await generateText(prompt: prompt, model: textModel, apiKey: apiKey)
            let payload = try decodeJSON(PassagePayload.self, from: text)
            return ReadingPassage(
                id: UUID().uuidString,
                text: payload.text,
                genre: payload.genre,
                difficulty: payload.difficulty,
                estimatedMinutes: payload.estimatedMinutes,
                difficultWords: payload.difficultWords.map { $0.lowercased() }
            )
        } catch {
            return fallbackPassage(genre: genre, child: child, durationMinutes: durationMinutes, sourceParagraphs: sourceParagraphs)
        }
    }

    func generateQuiz(
        for passage: ReadingPassage,
        book: Book,
        child: ChildProfile,
        passingScore: Double
    ) async throws -> Quiz {
        guard let apiKey else {
            return fallbackQuiz(for: passage, book: book, passingScore: passingScore)
        }

        let prompt = """
        Create a comprehension quiz for a child.

        Constraints:
        - Reading level: \(child.readingLevel)
        - Reading comprehension metric: \(Int(child.readingComprehension))
        - Passage genre: \(passage.genre)
        - Return valid JSON only.
        - Output schema:
          {
            "multiple_choice": [
              {
                "question": "string",
                "options": ["a", "b", "c", "d"],
                "correct_answer_index": 0
              }
            ],
            "true_false": {
              "question": "string",
              "correct_answer": true
            },
            "free_response": {
              "question": "string",
              "expected_concepts": ["concept"]
            }
          }
        - Exactly 3 multiple_choice questions.
        - Exactly 1 true_false question.
        - Exactly 1 free_response question.
        - Questions must be answerable from the passage only.
        - Keep wording age-appropriate.

        Passage:
        \(passage.text)
        """

        do {
            let text = try await generateText(prompt: prompt, model: textModel, apiKey: apiKey)
            let payload = try decodeJSON(QuizPayload.self, from: text)

            let multipleChoiceQuestions = payload.multipleChoice.map {
                MultipleChoiceQuestion(
                    id: UUID().uuidString,
                    question: $0.question,
                    options: $0.options,
                    correctAnswerIndex: $0.correctAnswerIndex
                )
            } + [
                MultipleChoiceQuestion(
                    id: UUID().uuidString,
                    question: payload.trueFalse.question,
                    options: ["True", "False"],
                    correctAnswerIndex: payload.trueFalse.correctAnswer ? 0 : 1
                )
            ]

            let freeResponseQuestions = [
                FreeResponseQuestion(
                    id: UUID().uuidString,
                    question: payload.freeResponse.question,
                    acceptedAnswers: payload.freeResponse.expectedConcepts
                )
            ]

            return Quiz(
                id: UUID().uuidString,
                bookId: book.id,
                passage: passage.text,
                multipleChoiceQuestions: multipleChoiceQuestions,
                freeResponseQuestions: freeResponseQuestions,
                passingScore: passingScore
            )
        } catch {
            return fallbackQuiz(for: passage, book: book, passingScore: passingScore)
        }
    }

    func evaluateFreeResponse(
        question: String,
        answer: String,
        expectedConcepts: [String],
        passage: String,
        child: ChildProfile
    ) async -> Bool {
        guard let apiKey, !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return evaluateFallbackFreeResponse(answer: answer, expectedConcepts: expectedConcepts)
        }

        let prompt = """
        Evaluate a child's free-response answer for reading comprehension.

        Constraints:
        - Reading level: \(child.readingLevel)
        - Reading comprehension metric: \(Int(child.readingComprehension))
        - Determine correctness based on understanding of the passage and whether the answer covers the important concepts.
        - Return valid JSON only.
        - Output schema:
          {
            "is_correct": true
          }

        Passage:
        \(passage)

        Question:
        \(question)

        Expected concepts:
        \(expectedConcepts.joined(separator: ", "))

        Child answer:
        \(answer)
        """

        do {
            let text = try await generateText(prompt: prompt, model: textModel, apiKey: apiKey)
            let payload = try decodeJSON(FreeResponseEvaluationPayload.self, from: text)
            return payload.isCorrect
        } catch {
            return evaluateFallbackFreeResponse(answer: answer, expectedConcepts: expectedConcepts)
        }
    }

    func generateWordDefinition(
        for word: String,
        in passage: ReadingPassage,
        child: ChildProfile
    ) async throws -> WordDefinition {
        guard let apiKey else {
            return fallbackDefinition(for: word)
        }

        let prompt = """
        Explain a difficult word for a child.

        Constraints:
        - Word: \(word)
        - Reading level: \(child.readingLevel)
        - Keep the definition short, concrete, and age-appropriate.
        - Use the passage context to choose the correct meaning.
        - Return valid JSON only.
        - Output schema:
          {
            "definition": "string",
            "image_prompt": "string"
          }

        Passage:
        \(passage.text)
        """

        do {
            let text = try await generateText(prompt: prompt, model: textModel, apiKey: apiKey)
            let payload = try decodeJSON(WordDefinitionPayload.self, from: text)
            let imageData = try await generateWordImage(prompt: payload.imagePrompt, apiKey: apiKey)
            return WordDefinition(word: word, definition: payload.definition, imageData: imageData)
        } catch {
            return fallbackDefinition(for: word)
        }
    }

    private func generateText(prompt: String, model: String, apiKey: String) async throws -> String {
        let requestBody = GenerateContentRequest(
            contents: [Content(parts: [Part(text: prompt)])],
            generationConfig: GenerationConfig(temperature: 0.4)
        )
        let response = try await performRequest(model: model, apiKey: apiKey, requestBody: requestBody)

        let text = response.candidates?
            .flatMap { $0.content.parts }
            .compactMap(\.text)
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let text, !text.isEmpty else {
            throw GeminiError.invalidResponse
        }

        return text
    }

    private func generateWordImage(prompt: String, apiKey: String) async throws -> Data? {
        let requestBody = GenerateContentRequest(
            contents: [Content(parts: [Part(text: prompt)])],
            generationConfig: GenerationConfig(
                temperature: 0.6,
                responseModalities: ["IMAGE"],
                imageConfig: ImageConfig(aspectRatio: "1:1")
            )
        )
        let response = try await performRequest(model: imageModel, apiKey: apiKey, requestBody: requestBody)

        guard let dataString = response.candidates?
            .flatMap({ $0.content.parts })
            .first(where: { $0.inlineData?.data != nil })?
            .inlineData?.data else {
            return nil
        }

        return Data(base64Encoded: dataString)
    }

    private func performRequest(
        model: String,
        apiKey: String,
        requestBody: GenerateContentRequest
    ) async throws -> GenerateContentResponse {
        let url = baseURL.appendingPathComponent("\(model):generateContent")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw GeminiError.requestFailed
        }

        return try JSONDecoder().decode(GenerateContentResponse.self, from: data)
    }

    private func decodeJSON<T: Decodable>(_ type: T.Type, from text: String) throws -> T {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let data = cleaned.data(using: .utf8), let decoded = try? JSONDecoder.snakeCase.decode(T.self, from: data) {
            return decoded
        }

        guard let start = cleaned.firstIndex(of: "{"), let end = cleaned.lastIndex(of: "}") else {
            throw GeminiError.invalidJSON
        }

        let jsonSlice = String(cleaned[start...end])
        guard let data = jsonSlice.data(using: .utf8) else {
            throw GeminiError.invalidJSON
        }

        return try JSONDecoder.snakeCase.decode(T.self, from: data)
    }

    private func fallbackPassage(
        genre: String,
        child: ChildProfile,
        durationMinutes: Int,
        sourceParagraphs: [String]
    ) -> ReadingPassage {
        let source = sourceParagraphs.first ?? "A curious child set out to learn something new."
        let wordRange = targetWordRange(for: durationMinutes, child: child)
        let targetWordCount = wordRange.upperBound
        let words = source.split(separator: " ")
        let limitedWords = words.prefix(min(words.count, targetWordCount))
        let text = limitedWords.joined(separator: " ")
        let difficultWords = Array(Set(words.map { $0.trimmingCharacters(in: .punctuationCharacters).lowercased() }
            .filter { $0.count > max(5, child.readingLevel + 3) })).sorted().prefix(5)

        return ReadingPassage(
            id: UUID().uuidString,
            text: text,
            genre: genre,
            difficulty: child.readingLevel,
            estimatedMinutes: durationMinutes,
            difficultWords: Array(difficultWords)
        )
    }

    private func targetWordRange(for durationMinutes: Int, child: ChildProfile) -> ClosedRange<Int> {
        let normalizedMinutes = max(1, durationMinutes)
        let childAdjustedUpperBound: Int

        switch normalizedMinutes {
        case 1:
            childAdjustedUpperBound = child.readingLevel <= 2 ? 32 : (child.readingLevel <= 4 ? 38 : 45)
        case 2:
            childAdjustedUpperBound = child.readingLevel <= 2 ? 45 : (child.readingLevel <= 4 ? 55 : 65)
        case 3...4:
            childAdjustedUpperBound = child.readingLevel <= 2 ? 60 : (child.readingLevel <= 4 ? 75 : 90)
        default:
            let scaledUpperBound = 90 + ((normalizedMinutes - 4) * 15)
            childAdjustedUpperBound = min(160, scaledUpperBound + max(0, child.readingLevel - 3) * 4)
        }

        let lowerBound = max(22, Int(Double(childAdjustedUpperBound) * 0.7))
        let upperBound = max(lowerBound + 8, childAdjustedUpperBound)
        return lowerBound...upperBound
    }

    private func fallbackQuiz(for passage: ReadingPassage, book: Book, passingScore: Double) -> Quiz {
        let difficultWord = passage.difficultWords.first ?? "important"

        return Quiz(
            id: UUID().uuidString,
            bookId: book.id,
            passage: passage.text,
            multipleChoiceQuestions: [
                MultipleChoiceQuestion(
                    id: UUID().uuidString,
                    question: "What is the main idea of the passage?",
                    options: [
                        "It describes the main event or discovery",
                        "It is only a list of names",
                        "It explains how to cook food",
                        "It is about a math problem"
                    ],
                    correctAnswerIndex: 0
                ),
                MultipleChoiceQuestion(
                    id: UUID().uuidString,
                    question: "Which detail best supports the main idea?",
                    options: [
                        "A detail from the passage that explains what happened",
                        "A random detail not mentioned",
                        "An opinion from outside the story",
                        "A fact about a different topic"
                    ],
                    correctAnswerIndex: 0
                ),
                MultipleChoiceQuestion(
                    id: UUID().uuidString,
                    question: "What does '\(difficultWord)' most likely mean in the passage?",
                    options: [
                        "A word connected to the passage context",
                        "A type of food",
                        "A loud machine",
                        "A sports team"
                    ],
                    correctAnswerIndex: 0
                ),
                MultipleChoiceQuestion(
                    id: UUID().uuidString,
                    question: "True or False: The passage gives important details about what happened.",
                    options: ["True", "False"],
                    correctAnswerIndex: 0
                )
            ],
            freeResponseQuestions: [
                FreeResponseQuestion(
                    id: UUID().uuidString,
                    question: "Explain the most important thing that happened in the passage.",
                    acceptedAnswers: ["main idea", "important event", "what happened", "discovery", "lesson"]
                )
            ],
            passingScore: passingScore
        )
    }

    private func fallbackDefinition(for word: String) -> WordDefinition {
        WordDefinition(
            word: word,
            definition: "\(word.capitalized) is an important word from the passage. It describes something in the story or explains an idea.",
            imageData: nil
        )
    }

    private func evaluateFallbackFreeResponse(answer: String, expectedConcepts: [String]) -> Bool {
        let normalizedAnswer = answer.lowercased()
        return expectedConcepts.contains { normalizedAnswer.contains($0.lowercased()) }
    }
}

private enum GeminiError: Error {
    case invalidResponse
    case invalidJSON
    case requestFailed
}

private struct GenerateContentRequest: Encodable {
    let contents: [Content]
    let generationConfig: GenerationConfig?
}

private struct Content: Encodable {
    let parts: [Part]
}

private struct Part: Encodable {
    let text: String?

    init(text: String) {
        self.text = text
    }
}

private struct GenerationConfig: Encodable {
    let temperature: Double?
    let responseModalities: [String]?
    let imageConfig: ImageConfig?

    init(
        temperature: Double? = nil,
        responseModalities: [String]? = nil,
        imageConfig: ImageConfig? = nil
    ) {
        self.temperature = temperature
        self.responseModalities = responseModalities
        self.imageConfig = imageConfig
    }
}

private struct ImageConfig: Encodable {
    let aspectRatio: String
}

private struct GenerateContentResponse: Decodable {
    let candidates: [Candidate]?
}

private struct Candidate: Decodable {
    let content: CandidateContent
}

private struct CandidateContent: Decodable {
    let parts: [CandidatePart]
}

private struct CandidatePart: Decodable {
    let text: String?
    let inlineData: InlineData?
}

private struct InlineData: Decodable {
    let mimeType: String?
    let data: String?
}

private struct PassagePayload: Decodable {
    let text: String
    let genre: String
    let difficulty: Int
    let estimatedMinutes: Int
    let difficultWords: [String]
}

private struct QuizPayload: Decodable {
    let multipleChoice: [QuizMCItem]
    let trueFalse: QuizTFItem
    let freeResponse: QuizFRItem
}

private struct QuizMCItem: Decodable {
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
}

private struct QuizTFItem: Decodable {
    let question: String
    let correctAnswer: Bool
}

private struct QuizFRItem: Decodable {
    let question: String
    let expectedConcepts: [String]
}

private struct FreeResponseEvaluationPayload: Decodable {
    let isCorrect: Bool
}

private struct WordDefinitionPayload: Decodable {
    let definition: String
    let imagePrompt: String
}

private extension JSONDecoder {
    static var snakeCase: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
