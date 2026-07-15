---
name: async-ui-feedback
description: >-
  Fade-in on screen/component display, loading indicators for awaits (local DB
  forces 2s minimum), and API/local error UI with retry. Use when building or
  changing Flutter screens, widgets, providers, or any flow that loads data or
  first paints UI after an open/load.
---

# Skill: Async UI feedback (fade, loading, error)

Non-negotiable UX for opening screens and async data (API, local DB, SharedPreferences, or any `await`).

---

## 1. Fade on display

Whenever a screen opens and shows components, or whenever data finishes loading and components appear, show them with a **fade** — never a hard pop-in.

Apply fade when:
- Opening a screen and painting its body / main content
- Switching from loading → content (or error → content)
- Revealing list / card / section after fetch

Preferred patterns:
- Screen mount: `TweenAnimationBuilder<double>` opacity `0 → 1` (~400–450ms, `Curves.easeOut`) wrapping the main content
- Async state switch: `AnimatedSwitcher` + `FadeTransition` (same duration/curve family)
- Scoped component (e.g. score card): fade only that subtree is OK; whole-screen fade is OK when the whole page mounts

Do **not** skip fade because the load was fast.

---

## 2. Loading is mandatory for every await

Any load of API, local DB, SharedPreferences, or other `await` that feeds UI **must** show a clear loading state.

### API (network / Supabase / HTTP)

- Show loading for the natural request duration only
- No artificial delay

### Local (SharedPreferences, SQLite, local files, or similarly fast `await`)

- Still show a clear loading indicator
- **Force a minimum of 2 seconds** before leaving loading (even if the read finishes in milliseconds)
- Pattern: `Future.wait([ fetchLocal(), Future.delayed(const Duration(seconds: 2)) ])` (or equivalent timer gate) so the UI does not flash

### Loading visual

- Prefer `LoadingAnimationWidget.staggeredDotsWave` with `AppTheme.primary` (same family as CNPJ consulta overlay)
- Scope: **component / section** when only that block loads; full-screen overlay only when the whole interaction blocks (e.g. search submit)
- Loading exclusive to the component that is waiting — do not block unrelated siblings

---

## 3. Error treatment

Whenever there is loading from **API or local DB/storage**, handle errors explicitly.

### API operations

Required UI:
- Message: **Ops, tivemos um problema... tente novamente**
- A clear **Tente novamente** control (button or refresh `IconButton`) that retries the same load (invalidate provider / call notifier retry)

Do not swallow API errors into empty screens or silent fallbacks.

### Local DB / storage

Also require error UI (message + retry). Same copy is fine unless a more specific message is already product-defined.

### Wiring

- Use `AsyncValue.when(loading/error/data)` (or equivalent explicit states)
- Retry must re-trigger the load path (e.g. `ref.invalidate(...)` or notifier `refresh` / `retry`)

---

## 4. Layer rules (architecture)

- Views never call services/SDK for load — go through notifier → service
- Loading / error / fade live in presentation; fetch timing / min delay may live in notifier or a small presentation gate — prefer **provider/service** for the 2s local min when the fetch is owned there, so all UIs share behavior
- Keep success, loading, and error states mutually exclusive and visible

---

## 5. Checklist (before shipping a screen/widget with data)

- [ ] First paint / post-load content uses fade
- [ ] Every await that drives UI has a visible loading state
- [ ] Local/fast storage load enforces **≥ 2s** loading
- [ ] API load uses real duration only (no forced 2s)
- [ ] Error UI includes message + retry for API (and local loads)
- [ ] Loading scoped to the waiting component when possible

---

## Anti-patterns

- Content appearing instantly after `await` with no loading and no fade
- Local prefs/DB flash without the 2s gate
- API error → empty list / blank card with no retry
- Full-screen overlay for a small card-only fetch
- Retry button that does nothing / only closes the error

---

## Cross-skill ownership

- Layers / Riverpod: `.cursor/skills/dart-architecture/SKILL.md`
- Screen structure: `.cursor/skills/new-screen/SKILL.md`
- Visual tokens / fonts: `.cursor/skills/theming/SKILL.md`
- Flutter list/local style: `.cursor/skills/flutter-code-style/SKILL.md`
