-- Create the enum types used by the application domain.
CREATE TYPE "user_role" AS ENUM ('customer', 'employee', 'store_admin', 'system_admin');
CREATE TYPE "unit_operational_state" AS ENUM ('available', 'maintenance', 'retired');
CREATE TYPE "basket_status" AS ENUM ('active', 'checked_out', 'abandoned');
CREATE TYPE "booking_status" AS ENUM ('confirmed', 'cancelled', 'completed');
CREATE TYPE "booking_item_status" AS ENUM ('reserved', 'collected', 'returned', 'cancelled');

-- Create application users and opaque server-side sessions. A NULL user_id
-- identifies a guest session that can own a basket before authentication.
CREATE TABLE "users" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "username" character varying(50) NOT NULL,
  "display_name" character varying(120) NOT NULL,
  "password_hash" text NOT NULL,
  "role" "user_role" NOT NULL DEFAULT 'customer',
  "is_active" boolean NOT NULL DEFAULT true,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "users_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "users_username_not_blank" CHECK (btrim(username) <> '')
);
CREATE UNIQUE INDEX "users_username_key" ON "users" ("username");

CREATE TABLE "sessions" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "token_hash" bytea NOT NULL,
  "user_id" uuid NULL,
  "expires_at" timestamptz NOT NULL,
  "last_seen_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "sessions_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE,
  CONSTRAINT "sessions_token_hash_length" CHECK (octet_length(token_hash) = 32),
  CONSTRAINT "sessions_expiry_after_creation" CHECK (expires_at > created_at)
);
CREATE UNIQUE INDEX "sessions_token_hash_key" ON "sessions" ("token_hash");
CREATE INDEX "sessions_user_id_idx" ON "sessions" ("user_id");
CREATE INDEX "sessions_expires_at_idx" ON "sessions" ("expires_at");

-- Create the equipment catalogue and individually tracked physical units.
CREATE TABLE "equipment_categories" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "slug" character varying(50) NOT NULL,
  "name" character varying(80) NOT NULL,
  "sort_order" integer NOT NULL DEFAULT 0,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "equipment_categories_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "equipment_categories_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  CONSTRAINT "equipment_categories_name_not_blank" CHECK (btrim(name) <> '')
);
CREATE UNIQUE INDEX "equipment_categories_slug_key" ON "equipment_categories" ("slug");
CREATE UNIQUE INDEX "equipment_categories_name_key" ON "equipment_categories" ("name");

CREATE TABLE "equipment_products" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "category_id" uuid NOT NULL,
  "name" character varying(160) NOT NULL,
  "description" text NOT NULL,
  "specifications" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "daily_rate_cents" integer NOT NULL,
  "hire_terms" text NULL,
  "is_visible" boolean NOT NULL DEFAULT true,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "equipment_products_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "equipment_products_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "equipment_categories" ("id") ON DELETE RESTRICT,
  CONSTRAINT "equipment_products_name_not_blank" CHECK (btrim(name) <> ''),
  CONSTRAINT "equipment_products_description_not_blank" CHECK (btrim(description) <> ''),
  CONSTRAINT "equipment_products_daily_rate_nonnegative" CHECK (daily_rate_cents >= 0),
  CONSTRAINT "equipment_products_specifications_object" CHECK (jsonb_typeof(specifications) = 'object')
);
CREATE INDEX "equipment_products_category_id_idx" ON "equipment_products" ("category_id");
CREATE INDEX "equipment_products_visible_idx" ON "equipment_products" ("is_visible");

CREATE TABLE "equipment_product_images" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "product_id" uuid NOT NULL,
  "path" text NOT NULL,
  "alt_text" character varying(240) NOT NULL,
  "sort_order" integer NOT NULL DEFAULT 0,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "equipment_product_images_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "equipment_product_images_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "equipment_products" ("id") ON DELETE CASCADE,
  CONSTRAINT "equipment_product_images_path_not_blank" CHECK (btrim(path) <> ''),
  CONSTRAINT "equipment_product_images_alt_text_not_blank" CHECK (btrim(alt_text) <> '')
);
CREATE UNIQUE INDEX "equipment_product_images_product_sort_key" ON "equipment_product_images" ("product_id", "sort_order");
CREATE UNIQUE INDEX "equipment_product_images_path_key" ON "equipment_product_images" ("path");

CREATE TABLE "equipment_units" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "product_id" uuid NOT NULL,
  "asset_number" character varying(60) NOT NULL,
  "serial_number" character varying(120) NULL,
  "operational_state" "unit_operational_state" NOT NULL DEFAULT 'available',
  "notes" text NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "equipment_units_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "equipment_units_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "equipment_products" ("id") ON DELETE RESTRICT,
  CONSTRAINT "equipment_units_asset_number_not_blank" CHECK (btrim(asset_number) <> '')
);
CREATE UNIQUE INDEX "equipment_units_asset_number_key" ON "equipment_units" ("asset_number");
CREATE INDEX "equipment_units_product_state_idx" ON "equipment_units" ("product_id", "operational_state");

CREATE TABLE "maintenance_records" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "equipment_unit_id" uuid NOT NULL,
  "start_at" timestamptz NOT NULL,
  "end_at" timestamptz NOT NULL,
  "reason" character varying(240) NOT NULL,
  "notes" text NULL,
  "created_by_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "maintenance_records_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "maintenance_records_equipment_unit_id_fkey" FOREIGN KEY ("equipment_unit_id") REFERENCES "equipment_units" ("id") ON DELETE CASCADE,
  CONSTRAINT "maintenance_records_created_by_user_id_fkey" FOREIGN KEY ("created_by_user_id") REFERENCES "users" ("id") ON DELETE SET NULL,
  CONSTRAINT "maintenance_records_valid_period" CHECK (end_at > start_at),
  CONSTRAINT "maintenance_records_reason_not_blank" CHECK (btrim(reason) <> '')
);
CREATE INDEX "maintenance_records_unit_period_idx" ON "maintenance_records" ("equipment_unit_id", "start_at", "end_at");

-- Create server-side baskets. Exactly one of user_id or guest_session_id owns
-- each basket; partial unique indexes allow one active basket per owner.
CREATE TABLE "baskets" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NULL,
  "guest_session_id" uuid NULL,
  "status" "basket_status" NOT NULL DEFAULT 'active',
  "version" bigint NOT NULL DEFAULT 0,
  "expires_at" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "baskets_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "baskets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE,
  CONSTRAINT "baskets_guest_session_id_fkey" FOREIGN KEY ("guest_session_id") REFERENCES "sessions" ("id") ON DELETE CASCADE,
  CONSTRAINT "baskets_exactly_one_owner" CHECK ((user_id IS NOT NULL) <> (guest_session_id IS NOT NULL)),
  CONSTRAINT "baskets_version_nonnegative" CHECK (version >= 0)
);
CREATE UNIQUE INDEX "baskets_active_user_key" ON "baskets" ("user_id") WHERE status = 'active' AND user_id IS NOT NULL;
CREATE UNIQUE INDEX "baskets_active_guest_session_key" ON "baskets" ("guest_session_id") WHERE status = 'active' AND guest_session_id IS NOT NULL;
CREATE INDEX "baskets_expires_at_idx" ON "baskets" ("expires_at");

CREATE TABLE "basket_items" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "basket_id" uuid NOT NULL,
  "product_id" uuid NOT NULL,
  "quantity" integer NOT NULL,
  "hire_start_at" timestamptz NULL,
  "hire_end_at" timestamptz NULL,
  "quoted_unit_price_cents" integer NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "basket_items_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "basket_items_basket_id_fkey" FOREIGN KEY ("basket_id") REFERENCES "baskets" ("id") ON DELETE CASCADE,
  CONSTRAINT "basket_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "equipment_products" ("id") ON DELETE RESTRICT,
  CONSTRAINT "basket_items_quantity_positive" CHECK (quantity > 0),
  CONSTRAINT "basket_items_period_pair" CHECK ((hire_start_at IS NULL AND hire_end_at IS NULL) OR (hire_start_at IS NOT NULL AND hire_end_at IS NOT NULL AND hire_end_at > hire_start_at)),
  CONSTRAINT "basket_items_quoted_price_nonnegative" CHECK (quoted_unit_price_cents >= 0)
);
CREATE UNIQUE INDEX "basket_items_basket_product_key" ON "basket_items" ("basket_id", "product_id");
CREATE INDEX "basket_items_product_id_idx" ON "basket_items" ("product_id");

-- Create bookings, immutable price/name snapshots, and physical allocations.
CREATE TABLE "bookings" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "reference" character varying(32) NOT NULL,
  "customer_id" uuid NOT NULL,
  "status" "booking_status" NOT NULL DEFAULT 'confirmed',
  "total_cents" bigint NOT NULL,
  "cancelled_at" timestamptz NULL,
  "cancelled_by_user_id" uuid NULL,
  "cancellation_reason" text NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "bookings_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "bookings_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "users" ("id") ON DELETE RESTRICT,
  CONSTRAINT "bookings_cancelled_by_user_id_fkey" FOREIGN KEY ("cancelled_by_user_id") REFERENCES "users" ("id") ON DELETE SET NULL,
  CONSTRAINT "bookings_reference_not_blank" CHECK (btrim(reference) <> ''),
  CONSTRAINT "bookings_total_nonnegative" CHECK (total_cents >= 0),
  CONSTRAINT "bookings_cancellation_fields" CHECK ((status = 'cancelled' AND cancelled_at IS NOT NULL) OR status <> 'cancelled')
);
CREATE UNIQUE INDEX "bookings_reference_key" ON "bookings" ("reference");
CREATE INDEX "bookings_customer_created_idx" ON "bookings" ("customer_id", "created_at");

CREATE TABLE "booking_items" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "booking_id" uuid NOT NULL,
  "product_id" uuid NOT NULL,
  "product_name" character varying(160) NOT NULL,
  "quantity" integer NOT NULL,
  "hire_start_at" timestamptz NOT NULL,
  "hire_end_at" timestamptz NOT NULL,
  "unit_price_cents" integer NOT NULL,
  "line_total_cents" bigint NOT NULL,
  "status" "booking_item_status" NOT NULL DEFAULT 'reserved',
  "cancelled_at" timestamptz NULL,
  "cancellation_reason" text NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "booking_items_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "booking_items_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "bookings" ("id") ON DELETE CASCADE,
  CONSTRAINT "booking_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "equipment_products" ("id") ON DELETE RESTRICT,
  CONSTRAINT "booking_items_product_name_not_blank" CHECK (btrim(product_name) <> ''),
  CONSTRAINT "booking_items_quantity_positive" CHECK (quantity > 0),
  CONSTRAINT "booking_items_valid_period" CHECK (hire_end_at > hire_start_at),
  CONSTRAINT "booking_items_unit_price_nonnegative" CHECK (unit_price_cents >= 0),
  CONSTRAINT "booking_items_line_total" CHECK (line_total_cents = quantity::bigint * unit_price_cents::bigint),
  CONSTRAINT "booking_items_cancellation_fields" CHECK ((status = 'cancelled' AND cancelled_at IS NOT NULL) OR status <> 'cancelled')
);
CREATE UNIQUE INDEX "booking_items_booking_product_key" ON "booking_items" ("booking_id", "product_id");
CREATE INDEX "booking_items_product_status_period_idx" ON "booking_items" ("product_id", "status", "hire_start_at", "hire_end_at");

CREATE TABLE "booking_item_units" (
  "booking_item_id" uuid NOT NULL,
  "equipment_unit_id" uuid NOT NULL,
  "allocated_by_user_id" uuid NULL,
  "allocated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "released_at" timestamptz NULL,
  CONSTRAINT "booking_item_units_pkey" PRIMARY KEY ("booking_item_id", "equipment_unit_id"),
  CONSTRAINT "booking_item_units_booking_item_id_fkey" FOREIGN KEY ("booking_item_id") REFERENCES "booking_items" ("id") ON DELETE CASCADE,
  CONSTRAINT "booking_item_units_equipment_unit_id_fkey" FOREIGN KEY ("equipment_unit_id") REFERENCES "equipment_units" ("id") ON DELETE RESTRICT,
  CONSTRAINT "booking_item_units_allocated_by_user_id_fkey" FOREIGN KEY ("allocated_by_user_id") REFERENCES "users" ("id") ON DELETE SET NULL,
  CONSTRAINT "booking_item_units_release_after_allocation" CHECK (released_at IS NULL OR released_at >= allocated_at)
);
CREATE INDEX "booking_item_units_equipment_unit_id_idx" ON "booking_item_units" ("equipment_unit_id");

-- Record security- and workflow-relevant changes without coupling an event to
-- the lifetime of its actor account or session.
CREATE TABLE "audit_events" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "actor_user_id" uuid NULL,
  "actor_session_id" uuid NULL,
  "action" character varying(120) NOT NULL,
  "entity_type" character varying(80) NOT NULL,
  "entity_id" uuid NULL,
  "before_data" jsonb NULL,
  "after_data" jsonb NULL,
  "metadata" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "request_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "audit_events_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "audit_events_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users" ("id") ON DELETE SET NULL,
  CONSTRAINT "audit_events_actor_session_id_fkey" FOREIGN KEY ("actor_session_id") REFERENCES "sessions" ("id") ON DELETE SET NULL,
  CONSTRAINT "audit_events_action_not_blank" CHECK (btrim(action) <> ''),
  CONSTRAINT "audit_events_entity_type_not_blank" CHECK (btrim(entity_type) <> ''),
  CONSTRAINT "audit_events_metadata_object" CHECK (jsonb_typeof(metadata) = 'object')
);
CREATE INDEX "audit_events_created_at_idx" ON "audit_events" ("created_at");
CREATE INDEX "audit_events_actor_user_id_idx" ON "audit_events" ("actor_user_id");
CREATE INDEX "audit_events_entity_idx" ON "audit_events" ("entity_type", "entity_id");
