# Braidflow

Salon operations for a braiding studio. One queue, three views: the front desk
checks a walk-in in under ten seconds, the braider only ever sees her own chair,
and the owner sees the day.

A Flutter port of the `Braidflow.dc.html` design canvas, kept in
[`design_source/`](design_source/) as the reference spec.

## The one state machine

```
WAITING  ──▶  IN PROGRESS  ──▶  COMPLETED
```

| Trigger | What happens |
| --- | --- |
| 1 | Supervisor checks in a walk-in → queue number issued |
| 2 | Auto-allocation to the longest-idle free braider (supervisor can override) |
| 3 | Braider taps **Finish client** → she flips to free and the next waiting customer is pulled to her chair |

**Braider availability is never entered by hand.** It is derived from "does this
braider hold an in-progress customer, and is she clocked in". That is what keeps
the supervisor's and the braider's views in sync — there is no separate
availability record to drift.

## Screens

| Role | Tabs |
| --- | --- |
| Supervisor · front desk | Queue · Check in · Chairs · Staff |
| Braider | My chair · Up next · Me |
| Owner | Today · Chairs · Staff |

Plus a customer timeline reachable from the queue, and an allocation sheet that
flags the braider auto-allocation would have picked.

## Running it on another machine

Everything the app needs is in the repo (fonts are bundled, data is seeded
in memory). No backend, API keys or `.env` file are required.

### 1. Install the prerequisites

| Tool | Why | Check |
| --- | --- | --- |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.10`, so a recent stable release) | builds and runs the app | `flutter --version` |
| [Git](https://git-scm.com) | clone the repo | `git --version` |
| Google Chrome | the web target, the quickest way to run it | `flutter devices` lists Chrome |
| Android Studio (only for Android) | SDK + emulator | `flutter doctor` |
| Xcode (only for iOS, macOS only) | simulator / device builds | `flutter doctor` |

Make sure `flutter` is on your `PATH`, then run `flutter doctor` and fix
anything it flags for the platform you care about. You can ignore the
platforms you do not need.

### 2. Clone and fetch dependencies

```bash
git clone <your-repo-url> braidflow
cd braidflow
flutter pub get
```

`pub get` reads `pubspec.yaml` / `pubspec.lock` and downloads the packages.
The `build/` and `.dart_tool/` folders are git-ignored, so they are created
fresh on the new machine.

### 3. Run it

```bash
flutter run -d chrome          # web (verified target)
flutter run                    # picks a connected device or emulator
flutter devices                # see what is available
```

While it runs, press `r` for hot reload, `R` for hot restart, `q` to quit.

### 4. Optional: serve a release web build

```bash
flutter build web --no-tree-shake-icons
node serve.js                  # static server for build/web
```

`rebuild.sh` does the build step; it assumes Flutter lives at
`/opt/homebrew/bin` (macOS Homebrew), so edit the `PATH` line on other setups.

### Troubleshooting

- **`flutter` not recognised**: see [Flutter not recognised](#flutter-not-recognised) below.
- **Dart SDK version error on `pub get`**: run `flutter upgrade`.
- **No Chrome device listed**: install Chrome, or set `CHROME_EXECUTABLE`.
- **Android licence errors**: `flutter doctor --android-licenses`.
- **iOS build fails**: needs full Xcode (not just Command Line Tools), then
  `sudo xcodebuild -runFirstLaunch` and `cd ios && pod install`.
- **Stale build weirdness**: `flutter clean && flutter pub get`.

### Flutter not recognised

Errors look like `flutter: command not found` (macOS/Linux) or
`'flutter' is not recognized as an internal or external command` /
`The term 'flutter' is not recognized` (Windows). Work through these in order.

**1. Is Flutter installed at all?** Look for a folder named `flutter` that
contains `bin/flutter` (and `bin/flutter.bat` on Windows). If not, install it:

- **Windows / macOS / Linux, manual:** download the SDK from
  <https://docs.flutter.dev/get-started/install>, extract it somewhere
  permanent, e.g. `C:\src\flutter` or `~/development/flutter`.
  Avoid `C:\Program Files` (needs admin rights) and paths with spaces.
- **macOS, Homebrew:** `brew install --cask flutter`
- **Linux, snap:** `sudo snap install flutter --classic`
- **VS Code:** the Flutter extension can download the SDK for you
  (Command Palette, "Flutter: New Project", then "Download SDK").
- **Git route (any OS):**
  `git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter`

**2. Installed but not on `PATH`: add `<flutter folder>/bin`.**

*Windows (GUI):* Start menu, search "Edit the system environment variables",
Environment Variables, select `Path` under *User variables*, Edit, New, and paste
`C:\src\flutter\bin`. Click OK on every dialog.

*Windows (PowerShell, current user):*

```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin", "User")
```

*macOS (zsh is the default shell):*

```bash
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

*Linux / macOS with bash:* same line, but append to `~/.bashrc` (Linux) or
`~/.bash_profile` (macOS bash).

*fish:* `fish_add_path ~/development/flutter/bin`

**3. Close and reopen the terminal (and the IDE).** `PATH` changes are only
read when a terminal starts. VS Code and Android Studio need a full restart,
not just a new terminal tab.

**4. Check you edited the right thing.**

- The entry must end in `flutter/bin`, not `flutter` or `flutter/bin/flutter`.
- Check what the shell sees: `echo $PATH` (macOS/Linux) or `echo $env:Path`
  (PowerShell) or `echo %PATH%` (cmd).
- Check where it resolves: `which flutter` (macOS/Linux) or `where flutter`
  (Windows).
- Wrong shell file: on macOS check `echo $SHELL`. zsh reads `~/.zshrc`, bash
  reads `~/.bash_profile`.

**5. Works in one terminal but not another.** GUI apps (VS Code, Android Studio)
may not inherit your shell profile. Launch them from a terminal that has
`flutter` on its `PATH`, or set `PATH` in the system settings (Windows) or in
`~/.zprofile` (macOS).

**6. Use the full path without touching `PATH` (quick workaround).**

```bash
~/development/flutter/bin/flutter doctor
```

```powershell
C:\src\flutter\bin\flutter doctor
```

**7. `flutter` is found but fails.**

- *Windows, "Git not found":* install Git for Windows, restart the terminal.
- *Windows, PowerShell script blocked:* run
  `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.
- *"Unable to find git in your PATH":* install Git and add it to `PATH`.
- *"Permission denied" (macOS/Linux):* `chmod +x ~/development/flutter/bin/flutter`
  or fix ownership with `sudo chown -R $USER ~/development/flutter`.
- *"dubious ownership" git error:*
  `git config --global --add safe.directory <flutter folder>`.
- *Corporate proxy or no internet:* set `HTTPS_PROXY`, or use a mirror via
  `PUB_HOSTED_URL` and `FLUTTER_STORAGE_BASE_URL`.
- *Apple Silicon Mac, "bad CPU type":* `sudo softwareupdate --install-rosetta`.
- *Linux, missing libs:* install `curl git unzip xz-utils zip libglu1-mesa`.
- *Corrupt install:* delete the Flutter folder and reinstall, or run
  `flutter doctor -v` to see the exact failing check.

**8. Verify.** In a fresh terminal:

```bash
flutter --version
flutter doctor
```

Both should print without errors for the platform you need (Chrome is enough
for the web target). Then continue from step 2 above.

Android and iOS targets are scaffolded. The project was developed against
Command Line Tools only, so the web target is the verified one.

## Tests

```bash
flutter test
```

- `test/state_machine_test.dart` — the three triggers, derived availability,
  allocation order, shift rules, wait estimates.
- `test/widget_test.dart` — renders every screen in every role, and re-renders
  them at 1.3× and 1.6× accessibility text sizes, on a small phone, and with an
  on-screen keyboard raised. This suite exists because a `borderRadius` on a
  non-uniform `Border` throws only at paint time — invisible to the analyser,
  and invisible in a release web build where assertions are stripped.

## Theme

The palette follows the DSE investor portal (investor.dse.co.tz), read off its
computed styles rather than eyeballed:

| Role | Value | Source |
| --- | --- | --- |
| Ground gradient | `#0A1628` → `#0F1E32` | `--background-start-rgb` / `--background-end-rgb` |
| Raised surface | `#132035` | DSE card colour |
| Text | `#E2E8F0` | portal body colour |
| Accent gradient | `#10B981` → `#2DD4BF` → `#09A0DB` | portal CTA |
| Glass | `rgba(255,255,255,.15)` + `blur(40px)` | portal nav pill |

Both projects already used **Manrope**, so only colour and surface treatment
changed; Instrument Serif is retained for display type.

**On the glass:** a real `BackdropFilter` costs a full offscreen render pass, so
it is reserved for floating chrome — the tab bar, the allocation sheet — where
there is genuinely something moving behind it. Cards use a translucent fill and
a light hairline instead. Over a flat gradient ground the two are visually
near-identical, and a blur layer per row in a six-item list is not.

Token *names* were kept from the original warm-sand theme: `ink` is the colour
you write with, so on a dark ground it is light, and the ~70 `inkA()` muted-text
call sites stayed correct without edits.

## Layout notes

- **Data is in-memory and seeded.** There is no persistence layer; a reload
  restores the seed. The design is a v1 structure, not a backend contract.
- **Allocation behaviour** (`autoAssign`, `pullNext`, `showWaitEstimate`) exists
  as fields on `AppState`, defaulting to the design's values. They were canvas
  editor knobs rather than app UI, so they are not surfaced on a screen.
- **Fonts are bundled** (`assets/fonts/`) rather than fetched at runtime, so the
  typography is identical offline and on every platform.
- **`PhoneFrame`** pins the app to the design's 402×874 artboard on wide
  viewports and lets it fill the screen on a phone.

## Out of scope for v1

Per the design's own notes: SMS "you're next" notifications, deposit capture at
check-in, skill-matched allocation, the weekly owner report, and multi-branch.
