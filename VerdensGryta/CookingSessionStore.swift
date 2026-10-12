import Foundation
import Observation

struct CookingTimer: Codable, Identifiable, Hashable {
    let id: UUID
    let stepNumber: Int
    let durationSeconds: TimeInterval
    var endDate: Date?
    var pausedRemainingSeconds: TimeInterval?
    var isFinished: Bool

    func remaining(at date: Date) -> TimeInterval {
        if isFinished { return 0 }
        if let pausedRemainingSeconds { return max(0, pausedRemainingSeconds) }
        guard let endDate else { return durationSeconds }
        return max(0, endDate.timeIntervalSince(date))
    }
}

struct CookingSession: Codable, Hashable {
    let recipeID: String
    let servings: Decimal
    let substitutionIDs: Set<String>
    var stepIndex: Int
    var timers: [CookingTimer]
}

@MainActor
@Observable
final class CookingSessionStore {
    private(set) var session: CookingSession?
    private let storageKey = "activeCookingSession"

    init() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(CookingSession.self, from: data) else { return }
        session = decoded
    }

    func start(recipeID: String, servings: Decimal, substitutionIDs: Set<String>) {
        session = CookingSession(
            recipeID: recipeID,
            servings: servings,
            substitutionIDs: substitutionIDs,
            stepIndex: 0,
            timers: []
        )
        save()
    }

    func setStep(_ index: Int, stepCount: Int) {
        guard var session else { return }
        session.stepIndex = min(max(index, 0), max(stepCount - 1, 0))
        self.session = session
        save()
    }

    func startTimer(minutes: Int, stepNumber: Int, now: Date = .now) {
        guard var session else { return }
        let duration = TimeInterval(minutes * 60)
        session.timers.append(CookingTimer(
            id: UUID(),
            stepNumber: stepNumber,
            durationSeconds: duration,
            endDate: now.addingTimeInterval(duration),
            pausedRemainingSeconds: nil,
            isFinished: false
        ))
        self.session = session
        save()
    }

    func pauseTimer(_ id: UUID, now: Date = .now) {
        guard var session, let index = session.timers.firstIndex(where: { $0.id == id }) else { return }
        session.timers[index].pausedRemainingSeconds = session.timers[index].remaining(at: now)
        session.timers[index].endDate = nil
        self.session = session
        save()
    }

    func resumeTimer(_ id: UUID, now: Date = .now) {
        guard var session,
              let index = session.timers.firstIndex(where: { $0.id == id }),
              let remaining = session.timers[index].pausedRemainingSeconds else { return }
        session.timers[index].pausedRemainingSeconds = nil
        session.timers[index].endDate = now.addingTimeInterval(remaining)
        self.session = session
        save()
    }

    func finishTimer(_ id: UUID) {
        guard var session else { return }
        session.timers.removeAll { $0.id == id }
        self.session = session
        save()
    }

    func endSession() {
        session = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func save() {
        guard let session, let data = try? JSONEncoder().encode(session) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
