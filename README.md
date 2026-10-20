# apple-sync — Devon Train iOS wrapper

A thin [Capacitor](https://capacitorjs.com/) shell that runs the deployed Devon
Train PWA inside a native `WKWebView`. The web app stays the single codebase —
server deploys reach the app instantly — while the shell unlocks the native
APIs Safari withholds:

- **CoreBluetooth** — pair a Polar H10 (or any BLE HR strap) directly to the
  iPhone. Live per-beat HR anywhere — no Deck, no Polar Beat, no Health Auto
  Export. Wired through `@capacitor-community/bluetooth-le`; the web app's
  `hr.ts` detects the native bridge and uses it automatically.
- **Background modes** — `bluetooth-central` + `audio` keep HR streaming and
  rest timers alive with the phone locked.
- **Real install** — App Store / sideload, icon, splash, deep links.

## Layout

| Path | What |
|---|---|
| `capacitor.config.json` | App id `net.felholm.devontrain`; `server.url` points the WebView at the live app (`CAP_SERVER_URL` overrides for dev) |
| `ios/` | The Xcode project — `pod install` then open `App.xcworkspace` |
| `.github/workflows/ios.yml` | macOS runner → CocoaPods → `xcodebuild archive` → unsigned `.ipa` artifact |

## Build locally (needs a Mac or xtool)

```sh
npm ci
npx cap sync ios
cd ios/App && pod install
open App.xcworkspace   # Xcode
```

No Mac? The GitHub Actions workflow builds the unsigned `.ipa` on a
`macos-latest` runner — grab it from the workflow artifacts.

## Signing / installing

- **Free Apple ID**: sideload via Xcode/`xtool` — works, but provisioning
  expires every 7 days (re-sign weekly).
- **Paid Developer account ($99/yr)**: proper provisioning, TestFlight,
  App Store, APNs push. Bluetooth/HealthKit/GPS work on the free tier.

## What stays in devon-train

Everything. `web/src/hr.ts` already branches: native shell → CoreBluetooth,
Chrome/Android → Web Bluetooth, otherwise → the server-side Deck bridge or the
Health Auto Export ingest URL. This repo adds only the shell.
