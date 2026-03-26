# LitLink

LitLink is an iOS hackathon project that turns reading into the unlock path for kids' screen time.

The app gives parents a shared household account, lets them manage child profiles and reading requirements, and uses speech recognition plus quiz completion to gate access to selected apps.

## What It Does

- Parent and child flows from the same app
- Shared household sign-in and child profile selection
- AI-assisted reading passage generation
- Speech recognition for read-aloud progress
- Comprehension quiz before unlock
- Family Controls based app blocking and timed unlock sessions
- Parent settings for reading difficulty, required score, reading time, and unlock duration

## Tech Stack

- SwiftUI
- FamilyControls / ManagedSettings
- Speech framework + AVFoundation
- Gemini API
- Supabase
- Xcode project targeting iOS 17+

## Repo Layout

```text
.
├── README.md
└── ProduHacksApp/
    └── ProduHacksApp/
        ├── ProduHacksApp.xcodeproj/
        ├── Secrets.xcconfig.example
        ├── Secrets.xcconfig
        └── ProduHacksApp/
            ├── ContentView.swift
            ├── OnboardingScreens.swift
            ├── LockScreen.swift
            ├── ReadingScreen.swift
            ├── QuizScreen.swift
            ├── SummaryScreen.swift
            ├── ParentDashboard.swift
            ├── ParentSettingsScreen.swift
            ├── AppLockSettingsScreen.swift
            ├── SupabaseService.swift
            ├── GeminiService.swift
            ├── SpeechRecognitionService.swift
            └── ScreenTimeManager.swift
```

## Core Flow

1. A parent creates or signs into a household account.
2. The parent selects or creates a child profile.
3. The child starts a reading session and picks a genre.
4. The app generates a reading passage and tracks read-aloud progress.
5. Once the reading requirement is met, the child takes a quiz.
6. Passing the quiz unlocks selected apps for a limited time.

## Setup

### Requirements

- Xcode 15+
- iOS 17 simulator or device
- Apple developer entitlements for Family Controls if you want to test app locking on real hardware
- Gemini API key
- Supabase project URL and keys

### Secrets

This repo does not store live secrets.

1. Open [Secrets.xcconfig.example](/mnt/c/Users/vueri/Desktop/CS_PROJECT/ProduHacks2026-1/ProduHacksApp/ProduHacksApp/Secrets.xcconfig.example).
2. Copy its values into `ProduHacksApp/ProduHacksApp/Secrets.xcconfig`.
3. Fill in:
   - `GEMINI_API_KEY`
   - `SUPABASE_URL`
   - `SUPABASE_PUBLISHABLE_KEY`
   - `SUPABASE_ANON_KEY`

`Secrets.xcconfig` is git-ignored and already wired into the Xcode target.

## Running The App

1. Open `ProduHacksApp/ProduHacksApp/ProduHacksApp.xcodeproj` in Xcode.
2. Make sure `Secrets.xcconfig` contains valid values.
3. Choose an iPhone simulator or device.
4. Build and run the `ProduHacksApp` target.

## Current Prototype Notes

- This is a hackathon prototype, not a production-hardened app.
- Family Controls behavior is best validated on properly entitled hardware.
- The app now uses placeholder-based secret injection instead of committed API keys.
- The reading gate no longer auto-advances to the quiz when the requirement has not been met.
- Unlock duration is configurable and tied into the app restriction flow.

## Demo Areas

- Household onboarding
- Child profile selection
- Reading session and word assistance
- Quiz pass / fail flow
- Parent reading settings
- App lock settings and unlock duration

## Next Steps

- Replace prototype auth/data flows with production-grade backend enforcement
- Persist more device management settings end-to-end
- Add tests around reading, quiz, and unlock state transitions
- Improve real-device validation for Family Controls flows


