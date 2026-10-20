# apple-sync — Devon Train iOS wrapper

A thin [Capacitor](https://capacitorjs.com/) shell that runs the deployed Devon
Train PWA inside a native `WKWebView`. The web app stays the single codebase —
server deploys reach the app instantly — while the shell unlocks the native
APIs Safari withholds. **No Mac required anywhere in the loop.**

## What the shell unlocks

| Capability | Plugin | What it gives Devon Train |
|---|---|---|
| **CoreBluetooth** | `@capacitor-community/bluetooth-le` | Polar H10 pairs straight to the iPhone — per-beat live HR anywhere, no Deck/Polar Beat/HAE |
| **HealthKit** | `@capgo/capacitor-health` | Reads Apple Health directly — watch/strap HR, weight, distance; replaces Health Auto Export |
| **Local notifications** | `@capacitor/local-notifications` | "Rest over" alert fires locked/backgrounded — no server round-trip |
| **Haptics** | `@capacitor/haptics` | Timer buzz through the Taptic Engine |
| **Keep awake** | `@capacitor-community/keep-awake` | Screen stays on during workouts |
| **Background modes** | `Info.plist` | `bluetooth-central` + `audio` — HR keeps streaming with the phone locked |
| App plumbing | `@capacitor/app` | App lifecycle hooks |

The web code detects the shell via `Capacitor.isNativePlatform()` and branches
in `web/src/hr.ts` + `web/src/native.ts` — in a browser nothing changes.

## Layout

| Path | What |
|---|---|
| `capacitor.config.json` | App id `net.felholm.devontrain`; `server.url` → live app (devs override via `CAP_SERVER_URL`) |
| `ios/` | Xcode project — `pod install`, open `App.xcworkspace` |
| `ios/App/App/App.entitlements` | HealthKit capability |
| `.github/workflows/ios.yml` | macOS runner → CocoaPods → `xcodebuild archive` → unsigned `.ipa` artifact |

## Build — zero Mac hardware

The GitHub Actions workflow builds on a rented `macos-latest` runner — grab
`DevonTrain-unsigned-ipa` from the run artifacts.

## Install on your iPhone — zero Mac

**SideStore** (open-source, free): install SideStore on the iPhone once via a
computer (Windows/Linux works — AltServer runs on all three OSes), then it
sideloads and signs `.ipa`s with your free Apple ID and **auto-refreshes the
7-day cert in the background**. Feed it the CI-built `DevonTrain-unsigned.ipa`.

Alternatives: AltStore/Sideloadly (same idea, manual refresh), or plug into
Xcode/`xtool` if a Mac ever appears. A paid Developer account ($99/yr) is only
needed for App Store distribution, TestFlight, or APNs remote push —
Bluetooth, HealthKit, local notifications all work on the free tier.

## What stays in devon-train

Everything. The app code, offline outbox, sync, authz, timer, server-side BLE
bridge, HAE ingest — all unchanged. This repo is just the shell.
