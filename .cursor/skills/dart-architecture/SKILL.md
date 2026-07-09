# Skill: Dart Architecture

Non-negotiable architecture for all Dart/Flutter code in this project.

## Layer Boundaries

- **Presentation (`lib/presentation`)**: UI/rendering/user interaction only.
- **Domain (`lib/domain`)**: typed models + provider state orchestration.
- **Services (`lib/services`)**: only layer that touches DB/API/SDK/platform I/O.

Dependency direction is always: `presentation -> domain -> services`.

## Core Rules

- **Views NEVER call services directly.** Any access to `lib/services/**` from `lib/presentation/**` must go through a provider/notifier in `lib/domain/providers/**`: **View → Notifier → Service**. Direct calls like `SomeService.instance.method()` inside widgets or `State` classes are forbidden.
- Never put business/data access logic in widgets.
- Never call DB/API/SDK directly outside services.
- Never load provider data via `setState`; call notifier methods and `watch` state.
- Keep state shapes explicit (`loading/error/success`).
- Use named routes via `AppRoutes`; avoid raw route strings.

## Riverpod Policy (Single Source)

- Prioritize `Notifier`/`AsyncNotifier` generated with `@riverpod`.
- Avoid `StateProvider` for business rules; use it only for ephemeral local UI state.
- Do not create new `StateNotifierProvider` unless justified by legacy constraints.

## Conflict Handling

If a requested change conflicts with these boundaries, do not bypass architecture.
Explain the conflict and propose a compliant implementation.

### Anti-pattern vs correct (service from presentation)

```dart
// WRONG — view → service
await MonitoringService.instance.register(card);
await PlanUsageTrackerService.instance.incrementScans();

// CORRECT — view → notifier/guard → service
await ref.read(monitoringNotifierProvider.notifier).register(card);
await ref.read(planLimitGuardProvider).registrarScanRealizado();
```

---

## Hardcoded business IDs (prohibition)

Never hardcode business identifiers (plan IDs, slugs, product flags)
directly in Dart domain or presentation code. These values must come from:
- Database tables (e.g., `plan_limits.plan_id`).
- Firebase Remote Config (e.g., `paywall_offering_config`).
- JSON assets (e.g., `remote_config.json`).

**Anti-pattern:**
```dart
// WRONG — hardcoded list of plan_ids in domain
const directIds = {'essential_direct', 'popular_direct'};
if (directIds.contains(planId)) { ... }
```

**Correct:**
```dart
// CORRECT — dynamic lookup against the source of truth (table)
for (final r in rows) {
  if (r.planId == planId) return r;
}
// fallback to 'default' if not found
```

If a business identifier appears as a string literal outside a config/asset/migration file,
question it and propose migrating it to the source of truth.

---

## Code reuse (DRY)

- **Do not copy-paste** identical or near-identical widget subtrees, style maps, or logic branches. If two branches differ only by a wrapper (e.g. `GestureDetector` vs none) or a flag, **extract once** and vary the minimum needed.
- **Prefer** private methods (`_buildSection(...)`), small `StatelessWidget` files under the feature `widgets/` folder, or shared helpers **when the same structure appears more than once** in a file or across files.
- **When not to extract**: one-off layout that is unlikely to repeat; extracting would add more indirection than clarity. Use judgment; default is toward reuse when duplication appears.