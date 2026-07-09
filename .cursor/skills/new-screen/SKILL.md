# Skill: New Screen

How to create or refactor screens under `lib/presentation/`.

## Folder Structure

```text
lib/presentation/<feature>_screen/
  <feature>_screen.dart
  widgets/
    <feature>_<role>.dart
```

## Screen Boundaries

- Screen layer is UI only. No DB/API/SDK calls in widgets.
- Trigger data loading through provider/notifier, not `setState`.
- Keep explicit loading/error/success rendering states.
- Use named routes via `AppRoutes` with typed arguments.

## Extraction Rules

- Keep main screen file focused (`Screen` + required `State` only).
- Extract reusable or visually distinct blocks to `widgets/`.
- One widget class per widget file under `widgets/`.
- If screen file grows too much, extract before adding more logic.

## Naming

- Screen file: `<feature>_screen.dart`
- Widget file: `<feature>_<role>.dart`
- Screen class: `<Feature>Screen`

## Cross-Skill Ownership

- Riverpod provider policy: `.cursor/skills/dart-architecture/SKILL.md`
- Semantics and Maestro testability: `.cursor/skills/maestro-testing/SKILL.md`
- Fonts/colors/sizing: `.cursor/skills/theming/SKILL.md`
