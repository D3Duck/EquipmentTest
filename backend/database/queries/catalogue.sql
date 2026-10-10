-- name: ListCatalogueProducts :many
SELECT
  p.id,
  p.catalogue_code,
  p.name,
  p.description,
  p.specifications,
  p.daily_rate_cents,
  p.hire_terms,
  c.id AS category_id,
  c.slug AS category_slug,
  c.name AS category_name,
  (SELECT count(*)::integer FROM equipment_units unit WHERE unit.product_id = p.id) AS total_units,
  (SELECT count(*)::integer
   FROM equipment_units unit
   WHERE unit.product_id = p.id
     AND unit.operational_state = 'available') AS operational_units,
  GREATEST(
    (SELECT count(*)::integer
     FROM equipment_units unit
     WHERE unit.product_id = p.id
       AND unit.operational_state = 'available'
       AND (
         sqlc.narg(hire_start_at)::timestamptz IS NULL
         OR NOT EXISTS (
           SELECT 1
           FROM maintenance_records maintenance
           WHERE maintenance.equipment_unit_id = unit.id
             AND maintenance.start_at < sqlc.narg(hire_end_at)::timestamptz
             AND maintenance.end_at > sqlc.narg(hire_start_at)::timestamptz
         )
       ))
    - CASE
        WHEN sqlc.narg(hire_start_at)::timestamptz IS NULL THEN 0
        ELSE COALESCE((
          SELECT sum(item.quantity)::integer
          FROM booking_items item
          JOIN bookings booking ON booking.id = item.booking_id
          WHERE item.product_id = p.id
            AND booking.status = 'confirmed'
            AND item.status IN ('reserved', 'collected')
            AND item.hire_start_at < sqlc.narg(hire_end_at)::timestamptz
            AND item.hire_end_at > sqlc.narg(hire_start_at)::timestamptz
        ), 0)
      END,
    0
  )::integer AS available_units
FROM equipment_products p
JOIN equipment_categories c ON c.id = p.category_id
WHERE p.is_visible = true
ORDER BY c.sort_order, p.name, p.id;

-- name: GetCatalogueProduct :one
SELECT
  p.id,
  p.catalogue_code,
  p.name,
  p.description,
  p.specifications,
  p.daily_rate_cents,
  p.hire_terms,
  c.id AS category_id,
  c.slug AS category_slug,
  c.name AS category_name,
  (SELECT count(*)::integer FROM equipment_units unit WHERE unit.product_id = p.id) AS total_units,
  (SELECT count(*)::integer
   FROM equipment_units unit
   WHERE unit.product_id = p.id
     AND unit.operational_state = 'available') AS operational_units,
  GREATEST(
    (SELECT count(*)::integer
     FROM equipment_units unit
     WHERE unit.product_id = p.id
       AND unit.operational_state = 'available'
       AND (
         sqlc.narg(hire_start_at)::timestamptz IS NULL
         OR NOT EXISTS (
           SELECT 1
           FROM maintenance_records maintenance
           WHERE maintenance.equipment_unit_id = unit.id
             AND maintenance.start_at < sqlc.narg(hire_end_at)::timestamptz
             AND maintenance.end_at > sqlc.narg(hire_start_at)::timestamptz
         )
       ))
    - CASE
        WHEN sqlc.narg(hire_start_at)::timestamptz IS NULL THEN 0
        ELSE COALESCE((
          SELECT sum(item.quantity)::integer
          FROM booking_items item
          JOIN bookings booking ON booking.id = item.booking_id
          WHERE item.product_id = p.id
            AND booking.status = 'confirmed'
            AND item.status IN ('reserved', 'collected')
            AND item.hire_start_at < sqlc.narg(hire_end_at)::timestamptz
            AND item.hire_end_at > sqlc.narg(hire_start_at)::timestamptz
        ), 0)
      END,
    0
  )::integer AS available_units
FROM equipment_products p
JOIN equipment_categories c ON c.id = p.category_id
WHERE p.is_visible = true
  AND p.id = sqlc.arg(product_id)::uuid;

-- name: ListProductImages :many
SELECT id, product_id, path, alt_text, sort_order
FROM equipment_product_images
WHERE product_id = ANY(sqlc.arg(product_ids)::uuid[])
ORDER BY product_id, sort_order, id;
