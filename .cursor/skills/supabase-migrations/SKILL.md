# Skill: Supabase Migrations

Safety rules for SQL migrations under `supabase/migrations/`.

## Non-negotiable

- Do not use `TRUNCATE`.
- Do not commit `DELETE` data operations.
- Do not commit broad mass `UPDATE` over domain/user data.

## Preferred Migration Shape

- Additive and idempotent DDL:
  - `CREATE ... IF NOT EXISTS`
  - `ADD COLUMN IF NOT EXISTS`
  - `CREATE INDEX IF NOT EXISTS`
  - guarded `DO $$ ... $$` for constraints/policies
- Use `CREATE OR REPLACE FUNCTION` when safe and contract-preserving.

## Operational Guidance

- If destructive data correction is needed, propose a reviewed manual runbook instead of a committed migration.
- Do not rewrite legacy migrations that already executed in production unless explicitly requested via a repair plan.
