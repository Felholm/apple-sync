import Capacitor

/// The bridge VC that also exposes our app-target plugins to JS — `cap sync`
/// rewrites packageClassList, so plugin classes that aren't pods register
/// here instead. capacitorDidLoad fires before the webview loads.
class RestBridgeViewController: CAPBridgeViewController {
    override func capacitorDidLoad() {
        super.capacitorDidLoad()
        bridge?.registerPluginInstance(RestLiveActivityPlugin())
    }
}
