# Skill: Flutter code style (lists & locals)

Conventions for widget lists and local variables in presentation/theme code.

---

## 1. Conditionals inside list literals: `if` / `else`, not ternary

In `children: [ ... ]`, `slivers: [ ... ]`, and similar **lists of widgets**, branch with **`if (condition) ... else ...`** — not the **ternary operator** `condition ? a : b`.

**Do:**

```dart
children: [
  if (atLimit)
    Text(headlineLimit!, style: baseStyle)
  else
    _buildActiveHeadlineRichText(
      context,
      remaining: remaining,
      scale: scale,
      baseStyle: baseStyle,
    ),
],
```

**Don’t:**

```dart
children: [
  atLimit
      ? Text(headlineLimit!, style: baseStyle)
      : _buildActiveHeadlineRichText(...),
],
```

Rationale: keeps the tree readable and consistent with Dart collection `if` / `else` style for widgets.

---

## 2. Local variables: reuse, conditions, or non-trivial logic

Inside a **`build` method** (or a private widget method), use a **`final` local** only when at least one of these applies:

- **Same value in more than one place** — e.g. one `fontSize` (or padding, height) shared by several `Text` / widgets in that method. Then extract once and reference it everywhere it repeats.
- **Conditional or non-trivial logic** — extracting makes the tree easier to read (see `fraction` below).

If a value is used **only once**, set it **directly on the widget** (inline in the constructor / `TextStyle` / `BoxDecoration`, etc.). Do not introduce a `final` just to name a single-use literal.

**Good — shared style used on multiple widgets:**

```dart
final titleSize = (16.sp * scale).clamp(14.0, 22.0);
// ...
Text('A', style: TextStyle(fontSize: titleSize)),
Text('B', style: TextStyle(fontSize: titleSize)),
```

**Good — conditional / meaningful extraction:**

```dart
final fraction = quota.max <= 0
    ? 0.0
    : (quota.used / quota.max).clamp(0.0, 1.0);
```

**Avoid — single use; prefer inline:**

```dart
final barHeight = (42.0 * scale).clamp(24.0, 50.0);
// ...
height: barHeight, // only reference — use height: (42.0 * scale).clamp(24.0, 50.0) instead
```

Rationale: names should signal **reuse** or **logic**; a one-off constant adds indirection without benefit.

---

## Scope

These rules apply to **new and touched code** in `lib/presentation/` and `lib/theme/`. Do not mass-refactor existing files solely to match this skill.

---

## See also

- **Duplicated widget trees / repeated logic:** follow **Code reuse (DRY)** in `.cursor/skills/dart-architecture/SKILL.md` — extract helpers or small widgets instead of copy-paste.
