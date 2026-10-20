import ActivityKit
import Foundation

/// Shared between the app target and RestTimerWidget — both must compile the
/// same attribute + content-state shape for the Live Activity to render.
struct RestActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endsAtMs: Double // epoch ms when the rest ends (0 when paused)
        var pausedLeftMs: Double // remaining when paused
        var paused: Bool
        var over: Bool
        var bpm: Int
        var zone: Int
    }

    var label: String
    var totalSecs: Int
}
