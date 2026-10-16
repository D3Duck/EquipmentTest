# Development and Release Cycle

## Azure and AWS VM deployments

Azure and AWS use the same application stack and deployment implementation. The cloud-specific scripts are intentionally thin entry points so the two environments cannot drift:

- `bootstrap-azure.sh` and `bootstrap-ec2.sh` call the shared first-deployment workflow.
- `deploy-azure.sh` and `deploy-ec2.sh` call the shared repeat-deployment workflow.

GitHub Actions builds the backend Dockerfile, including the Svelte frontend, on pushes to `main` and publishes `ghcr.io/d3duck/equipmenttest:<full-commit-id>`. Both clouds run the exact image associated with the checked-out commit.

### VM and network prerequisites

Use an Ubuntu LTS VM for the documented bootstrap path. Assign a stable public IP and point the public DNS name to it before bootstrapping. Configure the Azure network security group or AWS security group with:

- TCP 22 from trusted administrator addresses.
- TCP 443 from the internet.
- TCP 80 from the internet, recommended for ACME HTTP validation and HTTP-to-HTTPS redirects.
- UDP 443 optionally for HTTP/3.

Do not expose PostgreSQL port 5432 or the application's local health port 8080. The Compose stack binds both to `127.0.0.1`. Caddy is the only public application entry point and stores certificates in the persistent `caddy_data` volume. If UFW is active on the VM, allow TCP 22, 80, and 443 there as well before relying on the cloud firewall rules.

### First deployment on a new VM

Install Git, clone the repository, and run the provider entry point. The bootstrap installs Docker and Compose when they are missing on Ubuntu/Debian, creates `/etc/equipment-app.env` with mode `0600` and generated database/session secrets, pulls immutable application and pinned infrastructure images, starts PostgreSQL, applies Atlas migrations, and starts the application and Caddy.

Azure:

```bash
sudo apt-get update
sudo apt-get install -y git
sudo install -d -o "$USER" -g "$USER" /opt/equipment-app
git clone https://github.com/D3Duck/EquipmentTest.git /opt/equipment-app
cd /opt/equipment-app
sudo DOMAIN=testequipment.duckdns.org bash scripts/bootstrap-azure.sh
```

AWS EC2 uses the same steps with the AWS domain and entry point:

```bash
sudo apt-get update
sudo apt-get install -y git
sudo install -d -o "$USER" -g "$USER" /opt/equipment-app
git clone https://github.com/D3Duck/EquipmentTest.git /opt/equipment-app
cd /opt/equipment-app
sudo DOMAIN=equipment.example.com bash scripts/bootstrap-ec2.sh
```

The bootstrap refuses to replace credentials when it finds existing containers or a PostgreSQL volume without the protected environment file. If an image pull or early initialization step fails, rerun the same bootstrap command. Once an application container exists, use the deployment workflow.

### Repeat deployment

Wait for the GitHub Actions image-publishing workflow to succeed, then update the checkout and run the provider entry point.

Azure:

```bash
set -e
cd /opt/equipment-app
git pull --ff-only origin main
sudo bash scripts/deploy-azure.sh
```

AWS:

```bash
set -e
cd /opt/equipment-app
git pull --ff-only origin main
sudo bash scripts/deploy-ec2.sh
```

The shared deployment refuses a dirty checkout, pulls images before downtime, writes a protected pre-migration backup under `/var/backups/equipment`, applies Atlas migrations, reconciles the application and Caddy containers, and checks both local application health and the public-domain TLS certificate. A pull failure leaves the existing application running. A backup or migration failure deliberately leaves the backend stopped for investigation.

### Migrate an older AWS checkout

Older AWS installations used a repository-local `.env.aws`. Move its settings into the shared protected location before using the new deployment script:

```bash
cd /opt/equipment-app
sudo install -m 600 .env.aws /etc/equipment-app.env
sudo sed -i '/^DOMAIN=/d' /etc/equipment-app.env
printf '%s\n' 'DOMAIN=equipment.example.com' | sudo tee -a /etc/equipment-app.env >/dev/null
sudo bash scripts/deploy-ec2.sh
```

After verifying the deployment and backup, remove `.env.aws` from the checkout so secrets are not stored beside source code.

## AWS database backup to S3

```bash
set -e
umask 077
cd /opt/equipment-app

bucket="testequipment-backups"

mkdir -p /var/backups/equipment
backup="/var/backups/equipment/$(date -u +%Y%m%dT%H%M%SZ).dump"

docker compose --env-file /etc/equipment-app.env \
  -f compose.yaml -f compose.https.yaml \
  exec -T postgres sh -c \
  'exec pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --format=custom' \
  > "$backup"

test -s "$backup"

aws s3 cp "$backup" \
  "s3://$bucket/equipment/$(basename "$backup")" \
  --region ap-southeast-2
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

## SQLC Query Workflow

PostgreSQL application queries live in `backend/database/queries`. Generated pgx/v5 code lives in `backend/database/generated` and is committed so application builds do not need the sqlc tool.

After changing a query or a schema object used by a query, run from `backend/`:

```bash
go run github.com/sqlc-dev/sqlc/cmd/sqlc@v1.31.1 generate
```

Review the generated diff and run `go test ./...`. Do not edit files in `backend/database/generated` manually. The schema inputs are listed explicitly in `backend/sqlc.yaml`; add each new schema migration that changes objects used by sqlc queries.

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

Atlas CLI v0.38 and later requires Atlas Pro authentication for `migrate lint`. When Pro access is not configured, still run `migrate validate`, review the generated SQL and dry-run output manually, and record that lint was unavailable; do not report lint as successful. CI should authenticate Atlas Pro before treating lint as a required gate.

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
