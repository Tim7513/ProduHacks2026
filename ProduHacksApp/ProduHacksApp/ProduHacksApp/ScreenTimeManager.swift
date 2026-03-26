import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    let center = AuthorizationCenter.shared
    let store = ManagedSettingsStore()

    @Published var isAuthorized = false
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selectedAppsToBlock = FamilyActivitySelection()
    @Published private(set) var unlockEndsAt: Date?

    private var relockTimer: Timer?

    private init() {
        updateAuthorizationStatus()
    }

    func updateAuthorizationStatus() {
        authorizationStatus = center.authorizationStatus
        isAuthorized = (authorizationStatus == .approved)
    }

    // Request authorization for Family Controls
    func requestAuthorization() async throws {
        do {
            try await center.requestAuthorization(for: .individual)
            updateAuthorizationStatus()
        } catch {
            print("Failed to authorize Family Controls: \(error)")
            throw error
        }
    }

    // Apply app restrictions based on selected apps
    func applyRestrictions() {
        relockTimer?.invalidate()
        relockTimer = nil
        unlockEndsAt = nil

        // Block selected apps
        store.shield.applications = selectedAppsToBlock.applicationTokens
        store.shield.applicationCategories = .specific(selectedAppsToBlock.categoryTokens)
        store.shield.webDomains = selectedAppsToBlock.webDomainTokens

        print("Applied restrictions to \(selectedAppsToBlock.applicationTokens.count) apps")
    }

    // Remove all restrictions
    func removeRestrictions() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        print("Removed all app restrictions")
    }

    func beginUnlockSession(durationMinutes: Int) {
        guard isAuthorized else { return }

        let normalizedDuration = max(1, durationMinutes)
        relockTimer?.invalidate()
        removeRestrictions()

        unlockEndsAt = Calendar.current.date(byAdding: .minute, value: normalizedDuration, to: Date())
        relockTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(normalizedDuration * 60), repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.applyRestrictions()
            }
        }
    }

    // Check if apps should be blocked based on reading requirement
    func shouldBlockApps(readingMinutesCompleted: Int, requiredMinutes: Int) -> Bool {
        return readingMinutesCompleted < requiredMinutes
    }

    // Update blocking based on reading progress
    func updateBlockingBasedOnReading(readingMinutesCompleted: Int, requiredMinutes: Int) {
        if shouldBlockApps(readingMinutesCompleted: readingMinutesCompleted, requiredMinutes: requiredMinutes) {
            applyRestrictions()
        } else {
            removeRestrictions()
        }
    }
}
