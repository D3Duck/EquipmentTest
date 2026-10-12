-- Correct the five documented demo accounts with a bcrypt hash for the
-- deliberately fictional password "password". This is a forward migration
-- because the original seed migration may already be applied.
INSERT INTO "users" (
  "id", "username", "display_name", "password_hash", "role", "is_active", "created_at", "updated_at"
)
VALUES
  ('00000000-0000-4000-8000-000000000001', 'customer1', 'Casey Customer', '$2b$12$fGJ2.wHNTnB4397YPRSdYOq/g3IagDfqAZ89pLu9MwGIPabIxLmXS', 'customer', true, '2026-10-09T00:00:00Z', CURRENT_TIMESTAMP),
  ('00000000-0000-4000-8000-000000000002', 'customer2', 'Morgan Customer', '$2b$12$fGJ2.wHNTnB4397YPRSdYOq/g3IagDfqAZ89pLu9MwGIPabIxLmXS', 'customer', true, '2026-10-09T00:00:00Z', CURRENT_TIMESTAMP),
  ('00000000-0000-4000-8000-000000000003', 'employee', 'Emery Employee', '$2b$12$fGJ2.wHNTnB4397YPRSdYOq/g3IagDfqAZ89pLu9MwGIPabIxLmXS', 'employee', true, '2026-10-09T00:00:00Z', CURRENT_TIMESTAMP),
  ('00000000-0000-4000-8000-000000000004', 'storeadmin', 'Alex Store Admin', '$2b$12$fGJ2.wHNTnB4397YPRSdYOq/g3IagDfqAZ89pLu9MwGIPabIxLmXS', 'store_admin', true, '2026-10-09T00:00:00Z', CURRENT_TIMESTAMP),
  ('00000000-0000-4000-8000-000000000005', 'admin', 'Sam System Admin', '$2b$12$fGJ2.wHNTnB4397YPRSdYOq/g3IagDfqAZ89pLu9MwGIPabIxLmXS', 'system_admin', true, '2026-10-09T00:00:00Z', CURRENT_TIMESTAMP)
ON CONFLICT ("id") DO UPDATE SET
  "username" = EXCLUDED."username",
  "display_name" = EXCLUDED."display_name",
  "password_hash" = EXCLUDED."password_hash",
  "role" = EXCLUDED."role",
  "is_active" = EXCLUDED."is_active",
  "updated_at" = EXCLUDED."updated_at";
