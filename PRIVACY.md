# Privacy and repository hygiene

This repository contains the sanitized native iOS client for Hermesruns.

- No API keys, passwords, session tokens, cookies, OAuth secrets, or signing credentials are committed.
- Preview data is synthetic (`runner@example.com`, `Alex`, and generated run values); it is not production account data.
- The app stores the authenticated session token and account email in the device Keychain, and stores only the user-selected Hermes API base URL in `UserDefaults`.
- The source does not include personal filesystem paths, private deployment URLs, database exports, or parent-workspace history.
- Production use should use an HTTPS Hermes deployment. `http://localhost:8080` is a development default only.

Before publishing future changes, audit the staged tree for secrets and personal data, and keep Xcode user state, build output, and local configuration ignored.
