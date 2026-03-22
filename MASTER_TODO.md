# LitLink - Master TODO List

## 🔴 Critical TODOs - Must Complete

### AI Integration
- [ ] **Gemini API Quiz Generation** - Replace hardcoded questions with AI-generated contextual questions from reading passages
  - File: `QuizService.swift:117` - `generateQuizWithAI()`
  - Requires: Gemini API key, HTTP client integration

- [ ] **AI Free Response Verification** - Replace keyword matching with semantic analysis
  - File: `QuizService.swift:124` - `verifyFreeResponseWithAI()`
  - Requires: Gemini API for natural language understanding

### App Gating & Control
- [ ] **iOS Screen Time API Integration** - Actually block apps until reading complete
  - Requires: Family Controls entitlement from Apple
  - Requires: Parental permission flow
  - Files: New service needed - `AppGatingService.swift`

- [ ] **Unlock Timer Enforcement** - Activate timer to re-lock apps after duration
  - File: `QuizService.swift` - Add background timer
  - Requires: Background execution permissions

### Speech Recognition
- [ ] **Microphone Permission Handling** - Request and manage microphone access
  - Info.plist: Add NSMicrophoneUsageDescription

- [ ] **Speech-to-Text Integration** - Capture verbal reading in real-time
  - iOS Speech Framework integration
  - File: New `SpeechRecognitionService.swift`

- [ ] **Pronunciation Accuracy Scoring** - Compare spoken words to expected text
  - Algorithm needed for phonetic matching
  - File: `SpeechRecognitionService.swift`

### Dictionary & Definitions
- [ ] **Long-Press Word Definition Popup** - Show simplified definitions
  - File: `ReadingScreen.swift` - Add gesture recognizer
  - Integration: Dictionary API or local dictionary database

- [ ] **Audio Pronunciation** - Play correct pronunciation of words
  - iOS AVSpeechSynthesizer integration

- [ ] **Image Generation for Nouns** - Generate visual aids
  - Integration: nanabanana API
  - File: New `ImageGenerationService.swift`

### Parent-Child Account System
- [ ] **User Authentication** - Parent and child login system
  - Backend: Firebase Auth or similar
  - Files: New `AuthService.swift`, `User.swift` models

- [ ] **Account Linking** - Connect parent accounts to child accounts
  - Database schema for relationships

- [ ] **Remote Settings Control** - Parents adjust settings from their device
  - Real-time sync (Firebase Realtime Database or similar)

### Analytics & Reporting
- [ ] **Words Per Minute Tracking** - Calculate and store reading speed
  - File: `Models.swift` - Enhance ReadingSession

- [ ] **Tricky Words Analysis** - Track words child struggles with
  - Database: Store word click/pronunciation data
  - File: New analytics model

- [ ] **Weekly Reading Report Card** - Generate parent reports
  - File: `ParentDashboard.swift` - Enhance with real data

### Gamification
- [ ] **Currency System** - Earn coins for high scores
  - File: `Models.swift` - Add currency tracking
  - UI: Currency display, shop interface

- [ ] **Currency Shop** - Spend coins on extra screen time
  - New screen: `CurrencyShopScreen.swift`
  - Integration with unlock duration

### Parent Features
- [ ] **Custom Question Writing** - Parents create quiz questions
  - New screen: `CustomQuestionEditor.swift`
  - File: `QuizModels.swift` - Add custom question source

- [ ] **Master PIN System** - Emergency bypass
  - File: `LockScreen.swift` - Add PIN entry UI
  - Validation in `QuizService.swift:110`

### Genre Selection
- [ ] **Genre Picker Before Reading** - Let child choose category
  - File: `LockScreen.swift` or new `GenreSelectionScreen.swift`
  - Update book library filtering

### Content Management
- [ ] **PDF Upload System** - Parents upload custom books
  - File handling and parsing
  - PDF text extraction

- [ ] **Dynamic Book Library** - Fetch from database instead of hardcoded
  - Backend integration
  - File: `Models.swift` - Update AppData

---

## ⚠️ Known Issues & Bugs

### Current Implementation
- [ ] Quiz questions are hardcoded - only works for "The Brave Little Star"
- [ ] Free response validation is too simplistic (keyword matching)
- [ ] No actual app blocking - unlock session creates but doesn't enforce
- [ ] Timer display in reading screen is static ("14:52")
- [ ] No persistence - data lost on app restart
- [ ] Book covers use placeholder gradients instead of images

---

## 🟡 Nice-to-Have Features

### UX Improvements
- [ ] Add haptic feedback for correct/incorrect answers
- [ ] Loading states for AI quiz generation
- [ ] Skeleton screens while loading
- [ ] Error handling and retry mechanisms
- [ ] Offline mode support

### Accessibility
- [ ] VoiceOver support
- [ ] Dynamic type support
- [ ] Color contrast improvements for readability
- [ ] Reduced motion option

### Analytics
- [ ] Reading streak visualization
- [ ] Progress over time charts
- [ ] Badge collection showcase
- [ ] Leaderboard (optional, for siblings)

---

## 📝 Documentation TODOs

- [ ] Add inline code documentation
- [ ] Create parent user guide
- [ ] Create child onboarding tutorial
- [ ] API documentation for integrations
- [ ] Privacy policy & data handling docs

---

## 🔐 Security & Privacy

- [ ] Encrypt stored reading data
- [ ] Secure parent PIN storage
- [ ] COPPA compliance review (children's privacy)
- [ ] Data retention policies
- [ ] Parental consent mechanisms

---

## 📱 Platform & Deployment

- [ ] App Store submission checklist
- [ ] Screenshots & marketing materials
- [ ] Privacy nutrition labels
- [ ] TestFlight beta testing
- [ ] Production backend setup

---

## Progress Tracking

**Phase 1 (Core Quiz System):** ✅ COMPLETE
- Quiz data models
- Quiz generation service
- Quiz UI (multiple choice + free response)
- Scoring and validation
- Navigation flow

**Phase 2 (Speech Recognition):** 🔄 IN PROGRESS
- Microphone integration
- Real-time pronunciation feedback
- Word highlighting (green/red)

**Phase 3 (Enhanced Reading):** ⏳ PENDING
- Long-press definitions
- Audio pronunciation
- Image generation
- Currency system

**Phase 4 (Parent Features):** ⏳ PENDING
- Account system
- Remote settings
- Analytics dashboard
- Custom questions

**Phase 5 (App Gating):** ⏳ PENDING
- Screen Time API
- App blocking
- Unlock enforcement

---

Last Updated: 2026-03-21
