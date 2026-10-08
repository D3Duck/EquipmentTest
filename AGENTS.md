# Repository Guidance for Agents

## Project Intent

Build a portfolio-quality equipment-hire application that demonstrates transactional booking, role-based authorization, physical inventory management, real-time updates, testing, and cloud deployment.

Read these documents before making architectural or workflow changes:

- `documentation/plan document.md` — product scope, roles, domain rules, delivery phases, and acceptance criteria.
- `documentation/dev cycle documentation.md` — development, Atlas migration, backup, deployment, and verification procedures.

If implementation and documentation disagree, do not silently choose one. Preserve working behaviour, identify the conflict, and update the relevant documentation as part of the change when the intended behaviour is clear.

## Expected Structure

- `frontend/` — Svelte 5 frontend.
- `backend/` — Go/Fiber API, WebSocket server, and application services.
- `backend/database/schema.hcl` — desired PostgreSQL schema managed by Atlas.
- `backend/database/migrations/` — immutable versioned Atlas migrations and `atlas.sum`.
- `documentation/` — product and operational documentation.

Some paths may not exist during initial scaffolding. Create them only when the corresponding implementation requires them.

## Working Rules

- Inspect the repository and current diff before editing. Preserve unrelated user changes.
- Keep changes narrowly aligned with the requested task; avoid opportunistic rewrites.
- Prefer clear domain names from the plan: product, physical unit, booking, booking item, allocation, maintenance record, and audit event.
- Treat all client input as untrusted. Validate and authorize on the server.
- Keep customer, store-administrator, and system-administrator permissions distinct.
- Store timestamps in UTC and expose timezone context in the UI.
- Model hire periods as half-open intervals: `[start, end)`.
- Never log credentials, session tokens, database URLs, or simulated payment fields.
- Do not introduce real payment processing or collect real card details.
- Update tests and documentation when behaviour, commands, configuration, or architecture changes.

## Database and Atlas Rules

- Use versioned Atlas migrations. Do not mutate the database schema manually as a normal development workflow.
- Update `backend/database/schema.hcl`, generate a migration, and commit the migration with `atlas.sum` and the dependent code.
- Review generated SQL before applying it. Atlas generation does not replace engineering review.
- Use `docker://postgres/15/dev?search_path=public` as the disposable Atlas development database unless the project's PostgreSQL version is deliberately changed.
- Never point Atlas `--dev-url` at a persistent development or production database.
- Never edit a migration that has been applied to a shared or production database. Add a forward-fix migration instead.
- Use `atlas migrate set`, `--allow-dirty`, and `--skip-lock` only for a specifically reviewed recovery procedure, never to suppress a routine error.
- Preserve online compatibility through expand/migrate/contract changes when a schema change would otherwise break the running development environment.
- Back up before destructive migrations or significant data transformations.
- Do not expose database credentials in committed files, command output, fixtures, or documentation.

## Quality Expectations

- Format changed Go, Svelte, TypeScript, JavaScript, SQL, and Markdown files with the project's configured tools.
- Run the smallest relevant tests while iterating, followed by the broader affected suite before handoff.
- For database changes, run Atlas validation and lint plus applicable integration tests.
- Add or update tests for interval boundaries, concurrency, cancellation, maintenance exclusion, permissions, and price snapshots when those areas change.
- Confirm error paths as well as the happy path. Loading, empty, validation, conflict, unauthorized, and server-error states should remain explicit.
- Do not claim a test or deployment succeeded unless it was actually run and its result observed.

## Always-Online Development Environment

- Avoid routine commands that stop the complete environment, such as `docker compose down`.
- Apply backward-compatible migrations before deploying code that requires them.
- Use health checks and smoke tests after deployment.
- Roll back the application image independently when possible; do not roll back database state casually.
- Coordinate destructive operations, demo resets, and shared-data changes so another active user is not surprised.

## Completion Checklist

Before handing off a change:

1. Review `git diff` and ensure only intended files changed.
2. Run relevant formatters, tests, and static checks.
3. For schema work, validate and lint migrations and inspect migration status.
4. Update documentation and sample configuration when needed.
5. Summarize changed files, verification performed, and any remaining risks or follow-up work.
