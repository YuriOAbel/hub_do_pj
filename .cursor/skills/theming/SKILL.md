# Skill: Theming & UI

Visual standards for all screens in the project.

---

## Fonts

### Default type scale (logical pt)

Use these as the baseline for new screens and settings-style lists. Prefer `AppTypography` helpers (`title`, `subtitle`, `caption`) or the constants below — avoid one-off sizes smaller than 12pt.

| Role | Size | `AppTypography` |
|---|---|---|
| Title (row labels, section emphasis) | **16pt** | `fontTitle` / `AppTypography.title()` |
| Subtitle (secondary line under a title) | **14pt** | `fontSubtitle` / `AppTypography.subtitle()` |
| Body / captions (dialogs, hints, legal) | **12pt** | `fontBody` / `AppTypography.caption()` |

Nav bar display titles may still use **Bebas Neue** via `AppTypography.navTitle()`. Legacy screens may use `fontSizeBump`; new UI should start from the scale above.

### App-wide
| Role | Font | Rule |
|---|---|---|
| Body / UI text | `GoogleFonts.inter()` | **Never** set `letterSpacing` — distorts appearance |
| Display headers | `GoogleFonts.bebasNeue()` | `letterSpacing: 1.2` only on intentional display headers |

### Paywall & RecoveryOfferBottomSheet only
SF Pro (iOS system font) via `DefaultTextStyle` at the root of `build()`:

```dart
@override
Widget build(BuildContext context) {
  return DefaultTextStyle(
    style: const TextStyle(
      inherit: false,           // breaks Inter inheritance from global theme
      decoration: TextDecoration.none,
      letterSpacing: -0.41,    // Apple HIG value for SF Pro at 17pt
    ),
    child: /* screen or sheet content */,
  );
}
```

- `inherit: false` + null `fontFamily` = SF Pro on iOS
- Bebas Neue texts still override correctly via `GoogleFonts.bebasNeue()`
- **Never** apply `letterSpacing: -0.41` to Inter — it compresses it horizontally
- SF Pro **cannot** be distributed as an asset — only use the `DefaultTextStyle` approach

---

## Colors

| Token | Value | Usage |
|---|---|---|
| Background | `Color(0xFFF4F6FA)` | All screen backgrounds |
| Surface | `Color(0xFFFFFFFF)` | Cards, inputs |
| Primary | `Color(0xFF2563EB)` | Buttons, accents, titles |
| Primary dark | `Color(0xFF1D4ED8)` | Header gradient end |
| Text primary | `Color(0xFF1E293B)` | Body titles on light bg |
| Text secondary | `Color(0xFF6B7280)` | Subtitles, hints |
| Primary (iOS) | `CupertinoAppTheme.primaryColor` | Buttons, accents |
| Primary (Material) | `AppTheme.primary` | Fallback / Android |

Theme files:
- `lib/theme/cupertino_theme.dart` — iOS theme
- `lib/theme/app_theme.dart` — Material theme

### Mandatory (new UI and refactors)

- **No new hardcoded hex / `Color(0x…)`** unless explicitly approved by product/design. Use `AppTheme` / `CupertinoAppTheme` getters and `AppDesignService` tokens from `design.json`.
- **Do not introduce font families** other than **Inter** and **Bebas Neue** (via `GoogleFonts`) without explicit approval.

---

## Responsive Sizing

Use the `sizer` package for all dimensions:
- `sp` — font sizes
- `h` — height as % of screen height
- `w` — width as % of screen width

Use `DeviceScaleUtils` (`lib/core/utils/device_scale_utils.dart`) for device-specific scaling:

```dart
final scale = DeviceScaleUtils.getScaleFactor(context);
// small device (SE/8): 0.9 | regular iPhone: 1.0 | tablet: 1.45

final maxSize = DeviceScaleUtils.getMaxLimit(context, baseMax);
// use with .clamp() for upper bounds
```

**Mandatory:** combine **`sizer` (`sp` / `h` / `w`)** with **`DeviceScaleUtils.getScaleFactor`** and **`getMaxLimit`** for font sizes and caps on new screens and widgets — match patterns in existing screens (e.g. paywall, result details).

**Text scaling is locked to 1.0 in `main.dart` — never remove this.**

---

## App Platform

- Primary: `CupertinoApp` (iOS)
- Fallback: `MaterialApp` (Android)
- Use Cupertino widgets (`CupertinoButton`, `CupertinoActivityIndicator`, etc.) for iOS-first screens
- Use `showCupertinoModalPopup` for bottom sheets on iOS

---

## PaywallPlanCard Layout Rules

Documented in `.cursor/skills/paywall/SKILL.md` — read that skill when working on plan cards.

---

## Common Anti-Patterns

```dart
// ❌ letterSpacing on Inter
Text('hello', style: GoogleFonts.inter(letterSpacing: -0.41))

// ❌ FittedBox on plan cards (causes size inconsistency)
FittedBox(child: Text(plan.title))

// ❌ Local font assets for SF Pro
fontFamily: 'SFPro'  // SF Pro cannot be bundled

// ❌ Hardcoded pixel sizes without sizer
SizedBox(height: 24)  // use 3.h or similar instead

// ❌ Ad-hoc tiny labels in settings/lists
Text('Privacy', style: GoogleFonts.inter(fontSize: 11.sp))

// ✅ Standard title / subtitle / body
Text('Privacy Policy', style: AppTypography.title())
Text('Membership Status: Free', style: AppTypography.subtitle())
Text('Version 0.1.0', style: AppTypography.caption())

// ✅ Correct Inter usage (when not using AppTypography helpers)
Text('hello', style: GoogleFonts.inter(fontSize: AppTypography.fontSubtitle.sp))

// ✅ Correct Bebas Neue header
Text('SCAN', style: GoogleFonts.bebasNeue(fontSize: 32.sp, letterSpacing: 1.2))
```
