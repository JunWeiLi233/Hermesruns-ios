# Hermes iOS app

This directory contains the native SwiftUI client for Hermesruns.

## Open and run

1. Open `HermesRuns.xcodeproj` on macOS with Xcode 15 or newer.
2. Select the `HermesRuns` scheme and an iOS 16+ simulator.
3. Run the app. The sign-in screen defaults to `http://localhost:8080`, matching the local Hermes backend.
4. For a physical device, enter the HTTPS URL of a reachable Hermes deployment in the sign-in or Settings screen.

The app uses the existing Spring Boot API. Runner session tokens are stored in the iOS Keychain, and the API base URL is stored in `UserDefaults` so local development settings do not become source code.

## Current native surface

- Sign in and secure session restore
- Today Run readiness, workout blueprint, coach message, recommended shoe, and recent runs
- Read-only run history
- Read-only shoe rotation and mileage
- More tab with read-only Analysis (using `/api/activities/analysis` when available), Schedule, Races, Weather, Rewards, and Profile views
- API connection settings and sign out

Admin operations, OAuth linking, file imports, GPS heatmaps, race maps/planning, and editing flows remain follow-up native surfaces; the web app remains the source of truth for those features.
