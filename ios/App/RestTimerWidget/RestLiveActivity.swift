import ActivityKit
import WidgetKit
import SwiftUI

/// Rest timer Live Activity — lock screen + Dynamic Island. The countdown is
/// system-rendered from the target date, so it keeps ticking without the app
/// pushing updates; updates only carry bpm/zone/pause changes.
struct RestLiveActivityWidget: Widget {
    /// ClosedRange requires end > start — clamp a just-expired endsAt so the
    /// countdown renders "0:00" instead of crashing before `over` arrives.
    private func countdownRange(_ s: RestActivityAttributes.ContentState) -> ClosedRange<Date> {
        let end = Date(timeIntervalSince1970: s.endsAtMs / 1000)
        return Date() ... max(end, Date().addingTimeInterval(0.5))
    }

    private var zoneColor: [Color] {
        [.blue, .teal, .green, .orange, .red]
    }

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestActivityAttributes.self) { context in
            let s = context.state
            HStack(spacing: 10) {
                Image(systemName: "timer")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if s.over {
                        Text("GO").font(.title).bold()
                    } else if s.paused {
                        Text(Self.fmtMs(s.pausedLeftMs)).font(.title).bold().monospacedDigit()
                            + Text(" paused").font(.caption).foregroundStyle(.secondary)
                    } else {
                        Text(timerInterval: countdownRange(s), countsDown: true)
                            .font(.title).bold().monospacedDigit()
                    }
                }
                Spacer()
                if s.bpm > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(s.bpm)")
                            .font(.title2).bold().monospacedDigit()
                            .foregroundStyle(s.zone >= 1 && s.zone <= 5 ? zoneColor[s.zone - 1] : .primary)
                        Text(s.zone > 0 ? "Z\(s.zone) · bpm" : "bpm")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        } dynamicIsland: { context in
            let s = context.state
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.label, systemImage: "timer")
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if s.bpm > 0 {
                        Text("\(s.bpm) bpm").font(.caption).monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if s.over {
                        Text("GO").font(.title3).bold()
                    } else if s.paused {
                        Text(Self.fmtMs(s.pausedLeftMs) + " paused").font(.body).monospacedDigit()
                    } else {
                        Text(timerInterval: countdownRange(s), countsDown: true)
                            .font(.title3).bold().monospacedDigit()
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                if s.over {
                    Text("GO").font(.caption2).bold()
                } else if s.paused {
                    Text(Self.fmtMs(s.pausedLeftMs)).font(.caption2).monospacedDigit()
                } else {
                    Text(timerInterval: countdownRange(s), countsDown: true)
                        .font(.caption2).monospacedDigit()
                }
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }

    private static func fmtMs(_ ms: Double) -> String {
        let s = max(0, Int(ms / 1000))
        return "\(s / 60):\(String(format: "%02d", s % 60))"
    }
}
