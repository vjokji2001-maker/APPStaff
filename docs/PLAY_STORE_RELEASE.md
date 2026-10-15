# SmartBuddy: first Play Store release

Audit date: 13 October 2026 (Asia/Calcutta).

**Abhi production upload approve nahi hai.** Local code checks ko real Android device,
authenticated backend tests aur Google Play checks replace nahi kar sakte.

## App identity and signing

- Application ID: `com.pranam.smartmate`. First upload se pehle confirm karein ki
  isi permanent package name ko use karna hai. Published app ka package name change
  karke same listing update nahi hoti.
- Android label: `SmartBuddy APP`; internal Flutter package: `staff_mate`.
- Version: `1.2.1+4`; Gradle ab pubspec se version read karta hai. Agle upload ke
  liye versionCode badhana hoga, jaise `1.2.2+5`.
- Naya upload key locally generate hua: `android/app/upload-keystore.jks`.
- Signing credentials: `android/key.properties`. Dono Git-ignored hain. In dono
  files ka encrypted/offline backup abhi banayein. Passwords chat, screenshots ya
  Git mein share na karein. Play App Signing enable karna hai.
- Existing root `key.jks` Git-tracked hai; naye release mein use nahi hota.
  Repository owner ko uski exposure/history review karke old key ka use assess
  karna chahiye. Us file ko is audit ne delete ya overwrite nahi kiya.

## Sabse pehla blocker: HTTPS backend

Abhi main server `http://103.159.239.222:80` aur HR server
`http://103.177.84.241:9099` configured hain. Release mein plain HTTP blocked hai;
in default URLs ke saath release login/API calls nahi chalengi. Debug/profile
development builds mein HTTP allowed hai.

Backend/server administrator ko domain + valid TLS certificate + HTTPS reverse
proxy configure karne ko bolein. Sirf code mein `http` ko `https` likhne se server
HTTPS-enabled nahi hota. Existing API paths aur authentication headers preserve
hone chahiye. Main service routes include `/security`, `/smartcaremain`, `/ipd`,
`/billing`, `/master`, `/sclyte`, and `/SMARTCARE`. HR routes start with `/hr`.

Production origins milne ke baad:

```powershell
Copy-Item config/release.example.json config/release.json
```

`config/release.json` ke four empty values mein real, publicly reachable HTTPS
URLs fill karein:

- `SMARTCARE_BASE_URL`: main API origin; `/smartcaremain` suffix add na karein.
- `HR_BASE_URL`: HR origin; `/hr` suffix add na karein.
- `SAM_BASE_URL`: SAM origin for services that use it.
- `PRIVACY_POLICY_URL`: public policy page URL.

Dart defines compiled app mein visible hote hain: API keys, passwords ya tokens
is JSON mein na rakhein. Browser mein SSL certificate validity aur real API
responses verify karein. ADB/release device par bhi same URLs test karein.

## Privacy and Play Console information

Owner ki actual policy public HTTPS page par publish honi chahiye. App mein
Settings aur profile drawer se wahi configured URL open hota hai; pehle ka generic
one-line policy text replace hua hai.

Policy mein actual operator/contact, staff/patient data, uploaded documents,
camera/microphone/location use, backend/third-party processors, retention aur
deletion/contact process describe karein. Actual implementation jaane bina koi
retention period, legal entity ya claim invent na karein. Data safety answers ko
policy aur actual API behavior se match karein. Hospital/patient functionality ke
liye Health apps declaration review karein. Agar account creation introduce hota
hai, account deletion requirements bhi implement/review karein.

Current Register page mein account-create API nahi hai. Fake delay ke baad
dashboard access hata diya hai; account ke liye administrator se contact karna
padta hai. Backend-level authorization aur OTP enforcement bhi required hain;
client checks server security ka replacement nahi hain.

## Incomplete functionality to resolve before rollout

- Face recognition matching model/enrollment is not configured and liveness
  implementation is a stub. Release shows unavailable and makes no face punch.
  Working attendance must be provided through the approved HR workflow. Do not
  advertise face attendance as working until implementation/device verification.
- HR announcements, birthdays, training, documents and several secondary HR
  screens still use `HRMockData`. Convert them to real APIs or remove these demo
  sections from the production product before listing it as fully functional.
- Android device/emulator is not connected in this environment. Permissions,
  biometrics, camera, OCR/scanning, speech, files, PDF and WebView flows need actual
  device tests. Windows Visual Studio missing is irrelevant to Android upload.
- No authenticated backend session was available for live create/update testing.
  Local mocks validate client behavior; they do not prove server acceptance.
- Updated scanner fixes the two observed ELF LOAD alignment failures. The
  additional RELRO check still flags some prebuilt libraries, including the
  Flutter engine and ML Kit/native plugins. See `build/release-audit/native-alignment.json`.
  Full 16 KB compatibility is not certified. Resolve/review the flagged binaries
  and test a real 16 KB emulator/device; the release script stops on this signal.
- Old installed sessions without the new completed-OTP marker must sign in and
  verify OTP once again after this update. Persistent login resumes after that.

## Build after configuration

On this Windows machine, `flutter pub get` can report that plugins need symlink
support. Enable Windows Settings > For developers > Developer Mode, then retry.
This is a local setup requirement, not an Android app error.

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/build_play_release.ps1
```

Script rejects missing/placeholder HTTPS config and missing signing files, then
runs dependencies, Dart error analysis, tests and signed AAB build. Existing lint
warnings are printed and tolerated; this is intentional, not a claim that every
warning has been fixed. It never uploads anything.

Output: `build/app/outputs/bundle/release/app-release.aab`.

Fonts used by the app are bundled with their licenses; runtime font downloads are
disabled so that opening screens doesn't depend on Google's font server.

Direct `flutter build appbundle --release` without production configuration is
only a compiler/package verification build. **Do not upload that diagnostic build**:
it retains development HTTP defaults and no public privacy URL.

## Test before uploading

Record each test's device/Android version, result and backend response:

| Flow | Required checks |
| --- | --- |
| Startup/login | Clean install, valid/invalid password, expired subscription, OTP success/failure/resend/cancel, restart before OTP, no Skip bypass |
| Sessions | Restart after completed OTP, biometric cancel/failure/enrollment changes, token refresh, revoked token, logout/re-login with different staff account |
| Networking | Airplane mode, weak connection, server timeout, 401/403/500, empty/malformed JSON; no endless spinner |
| HR | Correct employee and tenant, balances, holidays, current year, full/half-day leave, create and read back request, cancel/delete, shifts/payroll |
| IPD | Correct patient/admission, vitals/notes, prescriptions/investigations, documents, charges and bed changes; use approved test records |
| Hardware | Denied/permanently denied camera/mic/location, location disabled, no biometrics, OCR/barcode, gallery/file picker |
| UI | Small screen, large font, dark mode, keyboard, back button, app resume, rapid double taps |
| Files | PDFs, document upload errors, downloads, WebView on Android; never test writes against live patient records without authorization |
| Packaging | Signature, target SDK 36, native 16 KB alignment, Play pre-launch report, install/update from Play internal track |

## First Play Console upload sequence

1. Create/verify the appropriate Google Play developer account and app listing.
2. Prepare actual icon, screenshots, descriptions, support email and policy URL.
3. Fill App content: Data safety, Health declaration where applicable, content
   rating, target audience, ads status, and App access instructions.
4. Reviewers need a working, non-sensitive test account and an accessible OTP/test
   mechanism approved on the backend. Do not reintroduce a client-side Skip bypass.
5. Upload the production-configured signed AAB to Internal testing first.
6. Install via the internal test link on real Android devices; examine Play
   pre-launch errors/ANRs and Bundle Explorer memory page size support.
7. If your new personal developer account falls under Google's testing rule,
   complete closed testing with at least 12 continuously opted-in testers for
   14 days, then apply for production access.
8. Fix observed issues, increment versionCode, rebuild, and only then request
   production rollout. This audit has not published or submitted the app.

## Official references (verified 13 October 2026)

- [Target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878): new phone apps/updates require API 36.
- [16 KB native library checks](https://developer.android.com/guide/practices/page-sizes): verify ELF, package alignment and actual 16 KB devices.
- [New personal account testing](https://support.google.com/googleplay/android-developer/answer/14151465): account-specific closed test requirement.
- [Google Play user data/account deletion](https://support.google.com/googleplay/android-developer/answer/13327111).
- [Google Play developer policy](https://support.google.com/googleplay/android-developer/answer/18258653).
