# Release audit — 13 October 2026

**Decision: HOLD production upload.** Compilation and signing succeed, but
production services, product completeness and device acceptance are not verified.

## Original checks (13 October 2026)

| Check | Result |
| --- | --- |
| Full Flutter test suite | 22 tests passed |
| Final authentication/refresh regression rerun | 7 tests passed |
| Full Dart analysis | 0 errors; 172 warnings and 443 lint infos remain |
| Final Android release AAB build | Passed |
| AAB signature (`jarsigner -verify`) | Verified using newly generated upload key |
| Signing files ignored by Git | Verified for both local files |
| 64-bit ELF LOAD alignment | 20/20 libraries passed 16 KB alignment |
| Additional GNU_RELRO alignment | 12/20 flagged; production gate fails |
| Offline font loading | All four app families/weights passed asset-only test |
| Production configuration gate | Correctly refuses missing HTTPS/privacy config |
| Android runtime/backend acceptance | Not run; no Android device or authenticated backend session available |

The analysis command intentionally tolerates warnings/lint infos and fails on
errors. No diagnostics were hidden by modifying the analyzer configuration.
Most remaining diagnostics are unused declarations, redundant null-aware
expressions, deprecated APIs and style/context-use warnings; they are not proof
of runtime safety and require ongoing cleanup.

## Package rename verification (17 October 2026)

- Android application ID, namespace and Kotlin launcher package now use
  `com.pranam.smartbuddy`; the activity source is in the matching package folder.
- iOS/macOS app and test bundle identifiers, Linux application ID, Windows company
  metadata and release documentation were updated consistently.
- `flutter test --no-pub --reporter expanded`: all 28 tests passed, including
  the vitals voice session tests.
- `flutter analyze --no-pub --no-fatal-infos --no-fatal-warnings`: exit 0;
  0 errors, 170 warnings and 448 lint infos. Existing diagnostics remain.
- `flutter build appbundle --release --no-pub`: passed with the existing upload key.
- The AAB manifest contains the requested package and launcher activity;
  its DEX files contain `com.pranam.smartbuddy.MainActivity`.
- `jarsigner -verify`: exit 0, `jar verified`. It also reports self-signed,
  missing timestamp and ZIP manifest/order warnings; these were not suppressed.
- Native checker rerun: 20/20 64-bit libraries pass ELF LOAD alignment;
  12/20 still trigger the existing GNU_RELRO gate, so that check fails.
- `config/release.json` is absent. This is a diagnostic bundle with existing
  defaults; production HTTPS/privacy configuration and device acceptance remain
  required. Other platforms were updated in source but not built on this Windows host.

## Final diagnostic bundle (17 October 2026)

- Path: `build/app/outputs/bundle/release/app-release.aab`
- Size: 114,220,205 bytes (Flutter reports 108.9 MB)
- Application ID: `com.pranam.smartbuddy`
- Version configuration: `1.2.1+4`, target SDK 36
- SHA-256: `f9949c4d452b08226c9bdaca7c015d0b92449aa59713465a72500e025981697b`

**Do not upload this diagnostic bundle.** It was built without the required
production HTTPS/PRIVACY_POLICY_URL defines. Its default HTTP API endpoints are
blocked by the release network policy. Source changes or production configuration
require a fresh build and a new checksum.

Self-signed-certificate/no-timestamp warnings from `jarsigner` are expected for
this locally generated Android upload key; signature verification still succeeds.
The first compiler-only bundle was unsigned and was replaced by the signed build.

## Changes made

- Target SDK updated to 36; Android version now follows pubspec.
- Signing reads its configured keystore path and fails closed if signing files
  are absent. A new private upload key and local properties file were generated;
  neither was committed or printed. Existing root `key.jks` was preserved.
- Completed OTP marker is required to resume a session; OTP Skip removed.
  Password authentication keeps only a provisional session for OTP API headers.
- Login no longer navigates to dashboard when committing the session fails;
  post-login profile/employee bootstrap completes before dashboard navigation.
- Password whitespace is preserved; failed credential encryption no longer falls
  back to sending plaintext. Developer console output is disabled in release.
- Refreshed tokens synchronize both stored token keys; HR tenant/timezone headers
  preserve the existing suffix and saved timezone.
- Concurrent refresh calls share one request; logout invalidates pending refresh
  results. API client retry is limited to one, replaces stale authorization and
  preserves URL query parameters. Central HTTP calls have a 30-second timeout.
- Fake registration-to-dashboard navigation removed; account creation currently
  requires the staff administrator because no registration endpoint is wired.
- Plain HTTP traffic and Android app backup disabled in release. Debug/profile
  can still use the development HTTP endpoints. HTTPS origins can be supplied
  through release Dart defines; the portal uses the same configured origin.
- Privacy links open a configured public HTTPS policy instead of generic text.
- Calendar now shows the holiday list only, per the requested change. Holiday
  date formatting is reused on the dashboard to avoid index/substring crashes.
- Payroll short-month formatting and prescription preview logging handle short
  strings safely.
- Leave date counts, same-day/half-day validation, cycle selection, template
  response unwrapping, submission lifecycle and business-error handling improved.
- Scanner upgraded from 5.2.3 to 7.4.2 after actual ELF failures were found.
  The scanner/Camerax LOAD failures are resolved in the final package.
- 57 hash-verified font files plus licenses were bundled; external font fetching
  disabled. Duplicate/unused imports and a missing direct dependency were fixed.

## Remaining release blockers

1. **Real HTTPS services:** backend administrator must enable valid TLS for main,
   HR and SAM services, then supply the actual URLs. Frontend source alone cannot
   enable TLS on those servers. Verify each API using the signed release app.
2. **Privacy and store information:** operator/contact, published policy, real
   Data safety/health declarations and reviewer access account/instructions are
   missing. The audit has not created a Play Console account or published anything.
3. **Native compatibility review:** all LOAD segments pass, but additional RELRO
   flags remain in prebuilt libraries. Resolve/review SDK/toolchain dependencies
   and run 16 KB device tests. Do not treat LOAD alignment alone as full certification.
4. **Incomplete product features:** release face attendance is explicitly
   unavailable because matching/enrollment/liveness is incomplete. Several HR
   sections still use demo data. Integrate real services or remove those sections
   before presenting them as production features.
5. **Real device and backend testing:** permissions, biometrics, camera, scanner,
   uploads/PDF/WebView, offline/timeout behavior, tenant/employee mapping and leave/
   patient writes need approved test-account acceptance. Mocked tests cannot
   validate server-side authorization, OTP enforcement or business rules.
6. **Environment maintenance:** new plugin resolution on this Windows host can
   require Developer Mode for symlink support. Android dependencies emit legacy
   Kotlin/deprecation warnings; pin the verified Flutter toolchain until those
   plugins are migrated and retested.

No promise of zero runtime errors or guaranteed Play approval is made. Use the
[first-release guide](PLAY_STORE_RELEASE.md) for the exact next steps and official
Google requirements. `scripts/build_play_release.ps1` never uploads the app and
stops at unresolved configuration/signing/native checks.
