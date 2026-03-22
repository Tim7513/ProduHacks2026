# Parental Platform Implementation Plan

## Overview
Comprehensive parental control and monitoring platform for LitLink reading app.

## Phase 1: Onboarding Flow ✅ (Foundation Created)

### 1.1 User Type Selection
**File:** `OnboardingScreens.swift` (to be created)
- Guardian/Child selection buttons
- Visual differentiation
- Navigate to appropriate setup flow

### 1.2 Guardian Account Setup
**Screens:**
- Login / Create Account
- Basic Information (Name, Email, Password)
- Setup PIN for child device
- Create first child profile

### 1.3 Child Profile Setup
**Information Collected:**
- Child's name
- Birthday (for age-appropriate content)
- Reading proficiency level (Beginner/Intermediate/Advanced)
- Avatar selection

## Phase 2: Parent Dashboard Features

### 2.1 Main Dashboard
**Location:** Enhanced `ParentDashboard.swift`
**Features:**
- Overview of all children
- Quick stats (reading time, books completed)
- Alerts/notifications
- Access to settings

###2.2 Book Library Management
**New Screen:** `BookLibrarySettingsScreen.swift`
**Features:**
- Browse all available books
- Assign books to specific children
- Set reading difficulty filters
- Upload custom books (future)
- Organize by category/grade level

### 2.3 Screen Time & App Lock Settings
**New Screen:** `DeviceControlScreen.swift`
**Features:**
- Set daily screen time limits
- Configure which apps to lock
- Set unlock conditions (reading time required)
- Schedule (school hours, bedtime)
- Emergency override code

**Data Structure:**
```swift
struct AppLockSettings {
    var lockedApps: [String] // Bundle identifiers
    var dailyScreenTimeMinutes: Int
    var readingRequirementMinutes: Int
    var schedule: [WeeklySchedule]
    var emergencyPIN: String
}
```

### 2.4 Reading Configuration
**New Screen:** `ReadingSettingsScreen.swift`
**Settings:**
- Reading level (grade 1-12)
- Required test score (60%-100%)
- Difficulty multiplier
- Time-to-passage conversion:
  - Set words per minute based on level
  - Auto-calculate passage length from time requirement
  - Example: 15 min × 100 WPM = 1500 words

**Data Structure:**
```swift
struct ReadingConfig {
    var readingLevel: Int // 1-12
    var requiredTestScore: Double // 0.6-1.0
    var wordsPerMinute: Int
    var dailyReadingMinutes: Int
    var calculatedPassageLength: Int {
        dailyReadingMinutes * wordsPerMinute
    }
}
```

### 2.5 Progress Tracking
**New Screen:** `ProgressDashboardScreen.swift`
**Metrics:**
- Reading time (daily/weekly/monthly)
- Books completed
- Test scores over time
- Pronunciation accuracy trends
- Vocabulary growth
- Charts and visualizations

### 2.6 Multiple Children Support
**Updated:** `Models.swift`
**Features:**
- Child profile switcher
- Independent settings per child
- Aggregate family statistics
- Comparison views (optional)

**Data Structure:**
```swift
struct ChildProfile: Identifiable {
    let id: UUID
    var name: String
    var birthday: Date
    var readingLevel: Int
    var avatar: String
    var readingConfig: ReadingConfig
    var appLockSettings: AppLockSettings
    var library: [Book]
    var stats: ReadingStats
}

class ParentAccount {
    var name: String
    var email: String
    var pin: String
    var children: [ChildProfile]
    var selectedChildID: UUID?
}
```

## Phase 3: Child Platform Restrictions

### 3.1 Access Control
**Implementation:**
- Check user type on app launch
- Hide parent dashboard/settings from child view
- Require parent PIN for any config changes
- Device-specific sessions (child can't access parent account)

**Code Pattern:**
```swift
@Published var userType: UserType = .child
@Published var isParentAuthenticated: Bool = false

enum UserType {
    case guardian
    case child
}
```

### 3.2 Cross-Device Sync
**Requirements:**
- Parent manages from their device
- Changes sync to child device
- CloudKit or Firebase backend
- Offline mode with sync on connection

## Implementation Priority

### Immediate (MVP):
1. ✅ Update AppScreen enum
2. ⏳ Create OnboardingScreens.swift
3. ⏳ Update AppData with UserType
4. ⏳ Create basic Parent Settings screen
5. ⏳ Add reading configuration UI

### Phase 2:
6. Book library selection
7. Screen time settings
8. Progress dashboard
9. Multiple children support

### Phase 3 (Advanced):
10. Cloud sync
11. Advanced analytics
12. Custom book upload
13. Parental reports/emails

## File Structure
```
ProduHacksApp/
├── Onboarding/
│   ├── OnboardingScreens.swift (user type selection)
│   ├── GuardianSetupScreen.swift
│   └── ChildSetupScreen.swift
├── Parent/
│   ├── ParentDashboard.swift (enhanced)
│   ├── ParentSettingsScreen.swift
│   ├── BookLibraryScreen.swift
│   ├── DeviceControlScreen.swift
│   ├── ReadingSettingsScreen.swift
│   └── ProgressDashboardScreen.swift
├── Models/
│   ├── Models.swift (updated)
│   ├── ChildProfile.swift
│   ├── ParentAccount.swift
│   └── AppLockSettings.swift
└── Services/
    ├── AuthService.swift
    └── SyncService.swift
```

## Next Steps

1. Create OnboardingScreens.swift with user type selection
2. Update ContentView.swift to handle onboarding flow
3. Enhance AppData model with parent/child structures
4. Create ParentSettingsScreen.swift
5. Build out each feature incrementally

---

**Status:** Foundation created, ready for implementation
**Last Updated:** 2026-03-22
