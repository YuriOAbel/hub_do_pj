# Skill: Database Requests

Guidelines to avoid duplicate or wasteful DB calls (Supabase/PostgREST/SQLite).

## Objectives

- Prevent repeated identical requests in the same user flow.
- Deduplicate concurrent fetches.
- Invalidate cache only when data actually changed.

## Practical Checklist

- Audit call sites for duplicated `select`/`load` chains.
- Add in-memory cache per resource when appropriate.
- Keep one in-flight `Future` for parallel callers.
- Use explicit `forceRefresh` only on real mutation boundaries.
- Avoid invalidating cache on every read.
- Keep plan/entitlement identifiers dynamic (never hardcoded).

## Applies To

- Flutter services/providers making Supabase/PostgREST/SQLite calls.
- Supabase Edge Functions querying Postgres.
