-- Add a stable customer-facing code without assuming that an existing database
-- is empty. Existing products receive a deterministic legacy code before the
-- column becomes required.
ALTER TABLE "equipment_products" ADD COLUMN "catalogue_code" character varying(50) NULL;

UPDATE "equipment_products"
SET "catalogue_code" = 'LEGACY-' || upper("id"::text)
WHERE "catalogue_code" IS NULL;

ALTER TABLE "equipment_products" ALTER COLUMN "catalogue_code" SET NOT NULL;

CREATE UNIQUE INDEX "equipment_products_catalogue_code_key"
ON "equipment_products" ("catalogue_code");

ALTER TABLE "equipment_products"
ADD CONSTRAINT "equipment_products_catalogue_code_format"
CHECK (catalogue_code ~ '^[A-Z0-9]+(?:-[A-Z0-9]+)*$');
