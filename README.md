# LitLink

LitLink is an iOS SwiftUI prototype for a parent-controlled reading unlock flow for kids.

## Current Scope

- Shared household sign-in with parent and child mode
- Parent-managed child profiles and settings
- Child reading flow with quiz-based unlock
- Supabase-backed household/profile/settings storage
- Gemini-backed passage, definition, and quiz generation with fallback logic

## Project Structure

- `ProduHacksApp/` app source
- `ProduHacksApp.xcodeproj/` Xcode project
- `ProduHacksApp/Assets.xcassets/` images and app icons

## Requirements

- Xcode
- iOS Simulator or device
- Supabase project keys in `ProduHacksApp/Info.plist`
- Gemini API key in `ProduHacksApp/Info.plist`

## Run

1. Open `ProduHacksApp.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Build and run the `ProduHacksApp` scheme.

## Notes

- `Info.plist` is intentionally kept tracked in git for this prototype.
- Gemini calls fall back to hardcoded content when the API key is invalid or the request fails.
- Some local Xcode and build artifacts are intentionally not committed.
