import Capacitor
import ActivityKit
import Foundation

/// JS-facing Live Activity bridge — registered manually by
/// RestBridgeViewController since `cap sync` regenerates packageClassList.
@objc(RestLiveActivityPlugin)
public class RestLiveActivityPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "RestLiveActivityPlugin"
    public let jsName = "RestLiveActivity"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "isSupported", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "start", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "update", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "end", returnType: CAPPluginReturnPromise),
    ]

    /// Activity<T> is iOS 16.1+ and can't be stored typed on a 15.0-target
    /// class — keep it untyped and cast inside availability-gated methods.
    private var activity: Any?

    @objc func isSupported(_ call: CAPPluginCall) {
        if #available(iOS 16.1, *) {
            call.resolve(["supported": ActivityAuthorizationInfo().areActivitiesEnabled])
        } else {
            call.resolve(["supported": false])
        }
    }

    @objc func start(_ call: CAPPluginCall) {
        guard #available(iOS 16.1, *) else {
            return call.reject("Live Activities require iOS 16.1")
        }
        let attrs = RestActivityAttributes(
            label: call.getString("label") ?? "Rest",
            totalSecs: call.getInt("totalSecs") ?? 0
        )
        let state = Self.state(from: call)
        do {
            let a = try Activity<RestActivityAttributes>.request(
                attributes: attrs,
                content: .init(state: state, staleDate: nil)
            )
            activity = a
            call.resolve(["activityId": a.id])
        } catch {
            call.reject("start failed: \(error.localizedDescription)")
        }
    }

    @objc func update(_ call: CAPPluginCall) {
        guard #available(iOS 16.1, *) else {
            return call.reject("Live Activities require iOS 16.1")
        }
        guard let a = activity as? Activity<RestActivityAttributes> else { return call.resolve() }
        let state = Self.state(from: call)
        Task { await a.update(.init(state: state, staleDate: nil)) }
        call.resolve()
    }

    @objc func end(_ call: CAPPluginCall) {
        guard #available(iOS 16.1, *) else {
            return call.reject("Live Activities require iOS 16.1")
        }
        guard let a = activity as? Activity<RestActivityAttributes> else { return call.resolve() }
        activity = nil
        Task { await a.end(nil, dismissalPolicy: .immediate) }
        call.resolve()
    }

    private static func state(from call: CAPPluginCall) -> RestActivityAttributes.ContentState {
        RestActivityAttributes.ContentState(
            endsAtMs: call.getDouble("endsAtMs") ?? 0,
            pausedLeftMs: call.getDouble("pausedLeftMs") ?? 0,
            paused: call.getBool("paused") ?? false,
            over: call.getBool("over") ?? false,
            bpm: call.getInt("bpm") ?? 0,
            zone: call.getInt("zone") ?? 0
        )
    }
}
