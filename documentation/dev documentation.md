# Development and Release Cycle

## Notes

-ltnp 'sport = :8090'


## AWS upate command

Run through Systems Manager → AWS-RunShellScript:

```bash
set -e
cd /opt/equipment-app

git pull --ff-only

# Use the same configuration for every command.
dc() {
  docker compose --env-file .env.aws \
    -f compose.yaml -f compose.https.yaml "$@"
}

# Build while the existing app is still available.
dc build app-backend

# Begin downtime.
dc stop app-backend

# Apply migrations. If this fails, the script stops here.
dc run --rm atlas

# Start the updated app.
dc up -d --no-deps --no-build app-backend

curl --fail --show-error \
  --retry 12 --retry-connrefused --retry-delay 5 \
  http://127.0.0.1:8080/health
```


## Working Assumptions

If the eventual project layout or variable names change, update this document and the Atlas commands together.

## Feature Development Cycle

1. Synchronize with `main` and confirm the development environment is healthy.
2. Define the feature's acceptance criteria and identify any schema, permission, API, WebSocket, or documentation impact.
3. Implement the smallest coherent change, including tests.
4. If the data model changes:
   - Update `backend/database/schema.hcl`.
   - Generate a named Atlas migration.
   - Review the generated SQL and `atlas.sum`.
   - Validate and lint the migration.
   - Back up the development database before a destructive or difficult-to-reverse change.
   - Preview and apply the migration to development.
5. Deploy the updated application to the always-online development environment.
6. Run automated tests and manually exercise the affected customer and administrator workflows.
7. Check health, logs, database migration status, and relevant WebSocket behaviour.
8. Update documentation, seed data, and the interviewer walkthrough where applicable.
9. Review the complete diff and commit the application code, migration, `atlas.sum`, tests, and documentation together.

Do not commit application code that depends on a schema migration without also committing that migration.

## Changes Without Development Downtime

Prefer backward-compatible changes. Deploy database migrations before application code when the old application can safely run against the new schema.

For a breaking schema change, use expand/migrate/contract:

1. **Expand:** add new nullable columns, tables, or indexes without removing old structures.
2. Deploy code that can work with both the old and new structures.
3. Backfill or transform existing data in a bounded, observable operation.
4. Switch reads and writes to the new structure and verify them.
5. **Contract:** remove obsolete structures in a later release after confirming nothing uses them.

Avoid long blocking transactions on live databases. Create large indexes using an appropriate PostgreSQL online strategy, and review table rewrites or lock-taking statements before applying them.

## Atlas Migration Workflow

Run commands from the repository root. Load the appropriate non-committed environment file only when needed, for example:

```bash
set -a
. ./.env
set +a
```

The examples use PostgreSQL 15 as the disposable Atlas dev database to match the planned project database. Update the image version in one coordinated change if the project upgrades PostgreSQL.

### Generate a Migration

First update `backend/database/schema.hcl`, then use a short snake-case description:

```bash
atlas migrate diff add_equipment_units \
  --dir "file://backend/database/migrations" \
  --to "file://backend/database/schema.hcl" \
  --dev-url "docker://postgres/15/dev?search_path=public"
```

Atlas creates a timestamped SQL migration and updates `backend/database/migrations/atlas.sum`. Read the SQL before applying it. Generated SQL is not automatically safe merely because generation succeeded.

### Validate Migration Integrity and SQL

```bash
atlas migrate validate \
  --dir "file://backend/database/migrations" \
  --dev-url "docker://postgres/15/dev?search_path=public"
```

Validation checks `atlas.sum` and executes the migration sequence against the disposable database.

### Lint the New Migration

For the most recently added migration:

```bash
atlas migrate lint \
  --dir "file://backend/database/migrations" \
  --dev-url "docker://postgres/15/dev?search_path=public" \
  --latest 1
```

In CI, lint all changes since the target branch:

```bash
atlas migrate lint \
  --dir "file://backend/database/migrations" \
  --dev-url "docker://postgres/15/dev?search_path=public" \
  --git-base origin/main
```

### Check Development Migration Status

```bash
atlas migrate status \
  --url "$DEV_DATABASE_URL" \
  --dir "file://backend/database/migrations"
```

### Preview Pending Development Migrations

```bash
atlas migrate apply \
  --url "$DEV_DATABASE_URL" \
  --dir "file://backend/database/migrations" \
  --dry-run
```

Review the exact pending migration list and SQL before applying it.

### Apply Development Migrations

```bash
atlas migrate apply \
  --url "$DEV_DATABASE_URL" \
  --dir "file://backend/database/migrations"
```

Run `atlas migrate status` again afterward. Do not use `--allow-dirty`, `--skip-lock`, or a non-linear execution order in the normal workflow.

### Check for Development Schema Drift

This compares the live development schema with the state represented by the migration directory:

```bash
atlas schema diff \
  --from "$DEV_DATABASE_URL" \
  --to "file://backend/database/migrations" \
  --dev-url "docker://postgres/15/dev?search_path=public"
```

No SQL output means the schemas agree. Investigate drift rather than silently incorporating manual database changes.

### Recalculate `atlas.sum` After an Intentional Manual Edit

Normally, never edit an applied migration. If an unapplied migration is deliberately edited during review, regenerate the integrity file and re-run validation and lint:

```bash
atlas migrate hash --dir "file://backend/database/migrations"
```

### Create the Initial Migration

After defining the first desired schema:

```bash
atlas migrate diff initial_schema \
  --dir "file://backend/database/migrations" \
  --to "file://backend/database/schema.hcl" \
  --dev-url "docker://postgres/15/dev?search_path=public"
```

Validate it, lint it, review it, and apply it normally. A new empty database does not need to be marked as already migrated.

### Baseline or Repair Migration History — Exceptional Use Only

`atlas migrate set` changes Atlas's revision history without executing the migration SQL. It is not part of the normal development cycle. Use it only when deliberately adopting an existing schema or repairing migration metadata after the database state has been independently verified and backed up:

```bash
atlas migrate set <verified-version> \
  --url "$DEV_DATABASE_URL" \
  --dir "file://backend/database/migrations"
```

Never run this against production merely to clear an Atlas error. Diagnose the mismatch first and record why the history repair is correct.

### Rollback Strategy

Treat committed and applied migrations as immutable. Prefer a new forward-fix migration. For a failed destructive production migration, stop the rollout and restore the verified backup according to the deployment runbook. Do not improvise a reverse migration against live data.

## Database Backups

Back up before production migration and before destructive development migration. Use a timestamped filename supplied explicitly by the operator:

```bash
pg_dump --format=custom \
  --file="backups/equipment-dev-YYYYMMDD-HHMM.dump" \
  "$DEV_DATABASE_URL"
```

Production uses the same form with `$PROD_DATABASE_URL` and a production-labelled filename. Store backups outside the source repository, protect them as sensitive data, and periodically test restoration into a separate database:

```bash
pg_restore \
  --clean \
  --if-exists \
  --no-owner \
  --dbname="$RESTORE_DATABASE_URL" \
  "backups/equipment-prod-YYYYMMDD-HHMM.dump"
```

Never test restoration against development or production.

## Always-Online Development Deployment

1. Confirm CI passes and the migration has been reviewed.
2. Back up development if the migration is destructive or performs a significant data transformation.
3. Run `atlas migrate status` and `atlas migrate apply --dry-run`.
4. Apply backward-compatible migrations.
5. Build a versioned application image from the reviewed commit.
6. Update the development service with Docker Compose without stopping unrelated services.
7. Wait for the health check before considering the deployment successful.
8. Run smoke tests for sign-in, catalogue browsing, checkout, cancellation, store management, and WebSocket updates as applicable.
9. Inspect logs and Atlas status. If the application fails, roll back the application image; only restore the database when the migration itself damaged data or cannot be forward-fixed.

Do not use `docker compose down` for a routine application deployment because it unnecessarily interrupts the persistent environment.

## Production Release

1. Create an immutable release from a tested commit and record its image digest.
2. Confirm all automated tests, migration validation, and migration lint checks pass.
3. Review pending migrations, lock risk, data transformations, deployment order, and rollback plan.
4. Back up production and verify the backup completed successfully.
5. Check production migration status:

   ```bash
   atlas migrate status \
     --url "$PROD_DATABASE_URL" \
     --dir "file://backend/database/migrations"
   ```

6. Preview production migrations:

   ```bash
   atlas migrate apply \
     --url "$PROD_DATABASE_URL" \
     --dir "file://backend/database/migrations" \
     --dry-run
   ```

7. Apply the reviewed migrations:

   ```bash
   atlas migrate apply \
     --url "$PROD_DATABASE_URL" \
     --dir "file://backend/database/migrations"
   ```

8. Deploy the exact tested image digest.
9. Wait for health checks and run production smoke tests against the configured public application URL.
10. Verify migration status, logs, permissions, WebSocket connectivity, and core customer and administrator workflows.
11. Monitor errors and latency after release. Record the release result and any follow-up work.

User access levels should be changed through reviewed application or data-migration logic, not as an undocumented manual post-deployment step.

## Verification Checklist

- Automated backend and frontend tests pass.
- Atlas validation and lint pass.
- Atlas reports no unexpected pending migrations or history mismatch.
- Booking concurrency and back-to-back interval tests pass.
- Cancellation releases availability.
- Maintenance excludes physical units from availability.
- Role restrictions are enforced by the API.
- The simulated checkout never records payment-card fields.
- WebSocket invalidation refreshes affected clients.
- Health checks pass and logs contain no credentials or tokens.
- Data survives an application restart.
- Documentation matches the deployed behaviour.

## Operational Commands

### Inspect Listening Ports

```bash
ss -tulpn
```

### Run a Standalone Persistent Development PostgreSQL Container

Docker Compose is the preferred local workflow. Build and start the database, migrations, and application without stopping unrelated services:

```bash
docker compose up --build --detach
docker compose ps
```

The application is exposed on `$GO_PORT` and PostgreSQL on `$POSTGRES_PORT`; both respect their bind-address settings in `.env`. The named PostgreSQL volume is created automatically and survives container replacement.

For database-only recovery or troubleshooting, this standalone command preserves the original setup without embedding credentials:

```bash
docker run \
  --name equipment-postgres \
  --env POSTGRES_USER="$POSTGRES_USER" \
  --env POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  --env POSTGRES_DB="$POSTGRES_DB" \
  --env TZ="Australia/Sydney" \
  --publish 5439:5432 \
  --volume equipment-postgres-data:/var/lib/postgresql/data \
  --restart unless-stopped \
  --detach \
  postgres:15.14
```

Use a named volume so the always-online development data survives container replacement. Do not reuse the persistent application database as Atlas's disposable `--dev-url` database.
