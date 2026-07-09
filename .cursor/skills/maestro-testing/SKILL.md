# Maestro Testing Skill

## Overview

Maestro is the E2E testing framework used in this project. All tests live in `maestro/` at the project root:

```
maestro/
├── utils/
│   └── launch_app.yaml        # Reusable app launch with isMaestro flag
├── flows/
│   └── <feature>.yaml         # One flow file per feature/screen
└── screenshots/
    └── .gitkeep               # Screenshots written here during test runs
```

---

## Running Tests

```bash
# Run a single flow
maestro test maestro/flows/onboarding_v2.yaml

# Run all flows
./maestro/run_tests.sh
```

---

## launchApp — Standard Pattern

**Always start every flow with `runFlow: ../utils/launch_app.yaml`** to get a clean state and enable test mode.

`maestro/utils/launch_app.yaml`:
```yaml
- launchApp:
    id: com.appsideasfactory.sportsscanner.ai
    arguments:
      isMaestro: "true"
    permissions:
      all: allow
    clearState: true
```

- `clearState: true` — resets SharedPreferences/SQLite between test runs
- `permissions: { all: allow }` — auto-grants camera, notification, tracking permissions
- `arguments.isMaestro: "true"` — read by Flutter via `flutter_launch_arguments` to disable custom animations

---

## Flutter Integration — isMaestro Flag

The app reads `isMaestro` at startup in `main.dart`:

```dart
import 'package:flutter_launch_arguments/flutter_launch_arguments.dart';

// In main() before runApp:
final launchArgs = await FlutterLaunchArguments.getAll();
final isMaestro = launchArgs['isMaestro'] == 'true';
```

Use `isMaestro` to:
- Disable animated page transitions (set duration to `Duration.zero`)
- Keep snackbars/toasts visible longer (extend duration)
- Skip any intro animations that block tap targets

---

## Semantics Identifiers — Mandatory Convention

Every interactive element that will be tapped or asserted in a test **must** have a `Semantics` widget with `identifier` + the appropriate type flag:

| Element type | Semantics flag |
|---|---|
| Button, GestureDetector, InkWell, CupertinoButton | `button: true` |
| TextField, TextFormField | `textField: true` |
| Image | `image: true` |
| Switch / CupertinoSwitch | `toggled: true` or `toggled: false` |
| Checkbox / Radio | `checked: true` or `checked: false` |

```dart
// ✅ Correct
Semantics(
  identifier: 'onboarding_hero_get_started',
  button: true,
  child: CupertinoButton(onPressed: widget.onGetStarted, ...),
)

// ❌ Never wrap a widget that already has its own Semantics with another Semantics
```

**Naming convention:** `<screen>_<element>` using snake_case.
Examples: `onboarding_hero_get_started`, `onboarding_scan_tap_to_scan`, `result_details_cta_scan_without_limits`.

---

## Flow File Structure

```yaml
appId: com.appsideasfactory.sportsscanner.ai
---
# Step 1: Launch with clean state
- runFlow: ../utils/launch_app.yaml

# Step 2: Screenshot before each interaction
- takeScreenshot: screenshots/step_01_hero

# Step 3: Wait for animations to settle before tapping
- waitForAnimationToEnd

# Step 4: Tap using Semantics identifier (never raw text as primary selector)
- tapOn:
    id: onboarding_hero_get_started

# Step 5: Assert elements are visible
- assertVisible:
    id: onboarding_scan_tap_to_scan
```

---

## Selectors Reference

```yaml
# By Semantics identifier (preferred)
- tapOn:
    id: onboarding_hero_get_started

# By text (fallback only, avoid as primary selector)
- tapOn: "Get Started"

# By index when multiple identical elements exist
- tapOn:
    id: onboarding_sample_card
    index: 1

# Scroll until visible
- scrollUntilVisible:
    element:
      id: result_details_cta_scan_without_limits
    direction: DOWN

# Descendants check
- assertVisible:
    id: onboarding_scan_page
    containsDescendants:
      - id: onboarding_scan_tap_to_scan
      - id: onboarding_sample_card_0
```

---

## Handling System Dialogs and Edge Cases

```yaml
# Optional steps: system permission dialogs that may or may not appear
- tapOn:
    text: "Allow"
    optional: true

# Wait for heavy async ops (DB seed, API calls in preview mode)
- extendedWaitUntil:
    visible:
      id: result_details_tab_info
    timeout: 8000
```

---

## Screenshots

```yaml
- takeScreenshot: screenshots/onboarding_01_hero
```

Screenshots are saved to `maestro/screenshots/` and committed to git for visual regression tracking.

---

## Semantics-First Development Convention

When building views, widgets, or screens, **always add `Semantics` identifiers to all interactive elements** — even if no Maestro flow exists yet. This keeps the codebase test-ready at all times.

> **Test execution is on-demand only.** Do NOT write or run Maestro flows unless the user explicitly requests it. Adding `Semantics` identifiers is part of normal development; running tests is a separate, user-triggered step.

---

## Writing a New Flow (when requested)

When the user asks to create or run a test for a feature:
1. Create `maestro/flows/<feature>.yaml`
2. Add any reusable navigation helpers in `maestro/utils/<nav_helper>.yaml`
3. Always start with `runFlow: ../utils/launch_app.yaml`
4. Verify `Semantics` identifiers exist on all interactive elements in the Flutter code
5. Add the flow to `maestro/run_tests.sh`

---

## Checklist Before Committing a Flow

- [ ] All `tapOn` use `id:` (Semantics identifier), not raw text
- [ ] `waitForAnimationToEnd` after every screen transition
- [ ] System permission dialogs use `optional: true`
- [ ] `takeScreenshot` at each meaningful step
- [ ] `runFlow: ../utils/launch_app.yaml` as the first step
- [ ] `flutter analyze` passes with zero errors after adding Semantics
