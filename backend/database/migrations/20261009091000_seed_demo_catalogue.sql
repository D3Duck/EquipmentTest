-- Deterministic demo identities. Authentication is implemented separately;
-- every account uses the explicitly fictional demo password "password".
INSERT INTO "users" (
  "id", "username", "display_name", "password_hash", "role", "is_active", "created_at", "updated_at"
)
VALUES
  ('00000000-0000-4000-8000-000000000001', 'customer1', 'Casey Customer', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'customer', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('00000000-0000-4000-8000-000000000002', 'customer2', 'Morgan Customer', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'customer', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('00000000-0000-4000-8000-000000000003', 'employee', 'Emery Employee', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'employee', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('00000000-0000-4000-8000-000000000004', 'storeadmin', 'Alex Store Admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'store_admin', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('00000000-0000-4000-8000-000000000005', 'admin', 'Sam System Admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'system_admin', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z')
ON CONFLICT ("id") DO UPDATE SET
  "username" = EXCLUDED."username",
  "display_name" = EXCLUDED."display_name",
  "password_hash" = EXCLUDED."password_hash",
  "role" = EXCLUDED."role",
  "is_active" = EXCLUDED."is_active",
  "updated_at" = EXCLUDED."updated_at";

INSERT INTO "equipment_categories" ("id", "slug", "name", "sort_order", "created_at")
VALUES
  ('10000000-0000-4000-8000-000000000001', 'tools', 'Tools', 10, '2026-10-09T00:00:00Z'),
  ('10000000-0000-4000-8000-000000000002', 'cleaning', 'Cleaning', 20, '2026-10-09T00:00:00Z'),
  ('10000000-0000-4000-8000-000000000003', 'garden', 'Garden', 30, '2026-10-09T00:00:00Z'),
  ('10000000-0000-4000-8000-000000000004', 'site-equipment', 'Site equipment', 40, '2026-10-09T00:00:00Z'),
  ('10000000-0000-4000-8000-000000000005', 'av', 'AV', 50, '2026-10-09T00:00:00Z'),
  ('10000000-0000-4000-8000-000000000006', 'outdoor', 'Outdoor', 60, '2026-10-09T00:00:00Z')
ON CONFLICT ("id") DO UPDATE SET
  "slug" = EXCLUDED."slug",
  "name" = EXCLUDED."name",
  "sort_order" = EXCLUDED."sort_order";

INSERT INTO "equipment_products" (
  "id", "category_id", "catalogue_code", "name", "description", "specifications",
  "daily_rate_cents", "hire_terms", "is_visible", "created_at", "updated_at"
)
VALUES
  ('5fa1f462-6810-4d06-88bd-057ad459991d', '10000000-0000-4000-8000-000000000001', 'TL-014', '18V Cordless Drill Kit', 'General-purpose drill and driver with two batteries, charger, and a 25-piece bit set.', '{"power":"18V","included":"2 batteries, charger, 25-piece bit set"}', 2800, 'Depot collection only. Return clean and complete.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('ec8f22d3-7ad2-4d10-8302-582e6172fd94', '10000000-0000-4000-8000-000000000001', 'CT-022', '185mm Circular Saw', 'Corded circular saw for framing and sheet timber, supplied with a general-purpose blade and guide.', '{"blade_diameter":"185mm","power":"corded"}', 3500, 'Depot collection only. Consumable blades are charged separately.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('3c725698-5f68-437a-94ee-9aa8c43ece17', '10000000-0000-4000-8000-000000000001', 'MT-031', '125mm Angle Grinder', 'Compact grinder for cutting, grinding, and surface preparation. Guard and side handle included.', '{"disc_diameter":"125mm","power":"corded"}', 2600, 'Depot collection only. Cutting discs are not included.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('f21178e3-9b99-4510-9538-4aebf3e9ca36', '10000000-0000-4000-8000-000000000001', 'DM-006', 'SDS+ Rotary Hammer', 'Heavy-duty rotary hammer for drilling concrete and masonry up to 26mm. Case and masonry bit included.', '{"maximum_masonry_capacity":"26mm","chuck":"SDS+"}', 4200, 'Depot collection only. Excessive bit wear may incur a replacement charge.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('cb37fcc0-37b8-4fad-bd0b-89a5fd928df7', '10000000-0000-4000-8000-000000000002', 'CL-008', '3000 PSI Pressure Washer', 'Petrol pressure washer with hose, spray wand, and interchangeable nozzles for heavy outdoor cleaning.', '{"maximum_pressure":"3000 PSI","fuel":"unleaded petrol"}', 6800, 'Depot collection only. Return with the fuel tank empty.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('8ad0d35f-485e-48fa-9ce5-9de631e27eb4', '10000000-0000-4000-8000-000000000002', 'CL-012', '35L Wet & Dry Vacuum', 'Commercial vacuum for workshop dust, renovation debris, and liquid spills, with floor and crevice tools.', '{"capacity":"35L","mode":"wet and dry"}', 3800, 'Depot collection only. Dust bags are sold separately.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('5d43773f-c516-40e5-88fb-682b7ed76af8', '10000000-0000-4000-8000-000000000002', 'CL-019', 'Commercial Carpet Cleaner', 'Upright extraction cleaner for carpets and rugs, supplied with an upholstery hand tool.', '{"cleaning_width":"300mm","included":"upholstery hand tool"}', 5200, 'Depot collection only. Cleaning solution is sold separately.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('98a8b8bb-d63d-43b2-8cee-77758d093c74', '10000000-0000-4000-8000-000000000002', 'FL-004', 'Orbital Floor Sander', 'Professional floor sander for timber restoration and finishing, with dust bag and extension lead.', '{"pad_size":"450mm x 300mm","power":"240V"}', 8600, 'Depot collection only. Sanding sheets are sold separately.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('39990bed-d17b-46c0-ae31-ce110ee7d2c4', '10000000-0000-4000-8000-000000000003', 'GD-005', '460mm Electric Lawn Mower', 'Quiet electric mower for small and medium lawns, with adjustable cutting height and grass catcher.', '{"cutting_width":"460mm","power":"electric"}', 4600, 'Depot collection only. Do not use in wet conditions.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('7a372508-c79a-48c9-ad98-dd49bbfa00af', '10000000-0000-4000-8000-000000000003', 'GD-011', '600mm Cordless Hedge Trimmer', 'Battery hedge trimmer with rotating rear handle, blade guard, charger, and one spare battery.', '{"blade_length":"600mm","power":"cordless"}', 3400, 'Depot collection only. Return both batteries and the charger.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('62c75d28-4419-4350-b7eb-f84fc125905c', '10000000-0000-4000-8000-000000000004', 'PW-003', '3.5kVA Portable Generator', 'Framed petrol generator for tools and temporary site power, with overload protection and two outlets.', '{"rated_output":"3.5kVA","fuel":"unleaded petrol"}', 9800, 'Depot collection only. Outdoor use only; return with the fuel tank empty.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('c96d2ab3-aa7b-4e78-8a04-a320c95726bc', '10000000-0000-4000-8000-000000000004', 'CN-004', '120L Concrete Mixer', 'Portable electric mixer for concrete, mortar, and render, mounted on wheels for site movement.', '{"drum_capacity":"120L","power":"240V"}', 7400, 'Depot collection only. Cleaning charges apply if material is returned in the drum.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('2d8dbfb3-fb20-43d7-a689-44590fb04a54', '10000000-0000-4000-8000-000000000004', 'AC-016', '6m Extension Ladder', 'Industrial aluminium extension ladder with stabilising feet and rope-operated upper section.', '{"extended_length":"6m","rating":"industrial"}', 3900, 'Depot collection only. Transport restraints are the hirer''s responsibility.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('88eb1e0c-e245-4483-86eb-b1bd38b15567', '10000000-0000-4000-8000-000000000004', 'AC-021', '1.8m Platform Ladder', 'Trade-rated aluminium platform ladder with safety rail, tool tray, and non-slip feet.', '{"platform_height":"1.8m","rating":"industrial"}', 3200, 'Depot collection only. Inspect feet and rails before use.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('a5d583f9-227f-49be-87a3-0a518857ae66', '10000000-0000-4000-8000-000000000005', 'AV-008', 'Mirrorless Camera Kit', 'Hybrid photo and video kit with camera body, two lenses, batteries, charger, and padded carry bag.', '{"video":"4K","included":"2 lenses, 3 batteries, charger, bag"}', 12500, 'Depot collection only. Photo identification is required at collection.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('095741ed-0860-40bd-ae70-01d00b0439b5', '10000000-0000-4000-8000-000000000005', 'AV-014', 'Fluid-Head Video Tripod', 'Stable aluminium video tripod with fluid pan-and-tilt head, quick-release plate, and carry case.', '{"maximum_height":"1.7m","maximum_load":"8kg"}', 3600, 'Depot collection only. Return the quick-release plate with the tripod.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('2bcbb527-cdfa-4050-b1d7-334bd52faf0a', '10000000-0000-4000-8000-000000000005', 'AV-019', '4000-Lumen HD Projector', 'Portable digital projector for presentations and events, supplied with remote, HDMI cable, and case.', '{"brightness":"4000 lumens","native_resolution":"1080p"}', 8900, 'Depot collection only. Replacement charges apply to missing cables or remotes.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('ad3db23c-ab43-405e-8d43-a9e2428307cc', '10000000-0000-4000-8000-000000000005', 'AV-025', '12-inch Powered PA Speaker', 'Portable powered speaker with stand and wireless microphone for speeches, classes, and small events.', '{"speaker_size":"12 inch","included":"stand and wireless microphone"}', 7200, 'Depot collection only. Indoor or sheltered use only.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('80314739-5cf1-4ab7-98d7-ab689e40efbc', '10000000-0000-4000-8000-000000000006', 'OD-021', 'Four-Person Dome Tent', 'Weatherproof dome tent with full fly, sewn-in floor, pegs, poles, and compact carry bag.', '{"capacity":"4 people","packed_weight":"7.2kg"}', 4400, 'Depot collection only. Return dry and free of dirt.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'),
  ('4658ac23-ae85-4df2-9fc3-8906904303ba', '10000000-0000-4000-8000-000000000006', 'OD-028', 'Two-Burner Camping Stove', 'Compact two-burner stove with wind guards and carry case. Gas bottle supplied separately.', '{"burners":"2","fuel":"LPG bottle not included"}', 2200, 'Depot collection only. Gas bottles are not included.', true, '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z')
ON CONFLICT ("id") DO UPDATE SET
  "category_id" = EXCLUDED."category_id",
  "catalogue_code" = EXCLUDED."catalogue_code",
  "name" = EXCLUDED."name",
  "description" = EXCLUDED."description",
  "specifications" = EXCLUDED."specifications",
  "daily_rate_cents" = EXCLUDED."daily_rate_cents",
  "hire_terms" = EXCLUDED."hire_terms",
  "is_visible" = EXCLUDED."is_visible",
  "updated_at" = EXCLUDED."updated_at";

INSERT INTO "equipment_product_images" (
  "id", "product_id", "path", "alt_text", "sort_order", "created_at"
)
VALUES
  ('ec39c30c-5b42-48f1-bcc9-90464f42dc2c', '5fa1f462-6810-4d06-88bd-057ad459991d', '/images/products/Cordless_drill_with_drill-bit_case_20261007221651.jpg', 'Cordless drill kit with batteries and bit case', 0, '2026-10-09T00:00:00Z'),
  ('8bd4b52f-8826-4f8f-88b9-ab6921a45fc3', 'ec8f22d3-7ad2-4d10-8302-582e6172fd94', '/images/products/Portable_electric_circular_saw_20261007221651.jpg', 'Portable electric circular saw', 0, '2026-10-09T00:00:00Z'),
  ('3785fc92-a2fc-43ea-a782-c9db24647415', '3c725698-5f68-437a-94ee-9aa8c43ece17', '/images/products/Electric_angle_grinder_on_display_20261007221651.jpg', 'Electric angle grinder', 0, '2026-10-09T00:00:00Z'),
  ('4322b774-29a0-4cf5-9db6-9aa1d6f02e21', 'f21178e3-9b99-4510-9538-4aebf3e9ca36', '/images/products/Rotary_hammer_drill_with_bit_20261007221651.jpg', 'Rotary hammer drill with masonry bit', 0, '2026-10-09T00:00:00Z'),
  ('6eca381e-9096-46c6-836b-57234573493e', 'cb37fcc0-37b8-4fad-bd0b-89a5fd928df7', '/images/products/Upright_pressure_washer_with_hose_20261007221651.jpg', 'Upright pressure washer with hose', 0, '2026-10-09T00:00:00Z'),
  ('904e3028-fbd0-4fad-8686-da43c4ed0db1', '8ad0d35f-485e-48fa-9ce5-9de631e27eb4', '/images/products/Wet-and-dry_vacuum_cleaner_with_…_20261007221651.jpg', 'Wet and dry vacuum cleaner', 0, '2026-10-09T00:00:00Z'),
  ('7a65436e-6d0b-46eb-9ab9-ee2d1ceadcd8', '5d43773f-c516-40e5-88fb-682b7ed76af8', '/images/products/Carpet_cleaning_machine_product_…_20261007221651.jpg', 'Commercial carpet cleaning machine', 0, '2026-10-09T00:00:00Z'),
  ('f41ac7ad-8fe4-49af-8224-86066577fd53', '98a8b8bb-d63d-43b2-8cee-77758d093c74', '/images/products/Floor_sander_on_grey_background_20261007221651.jpg', 'Orbital floor sander', 0, '2026-10-09T00:00:00Z'),
  ('eb5db9e5-55f9-49a6-92cb-b493280db6d1', '39990bed-d17b-46c0-ae31-ce110ee7d2c4', '/images/products/Electric_lawn_mower_product_phot…_20261007221651.jpg', 'Electric lawn mower', 0, '2026-10-09T00:00:00Z'),
  ('8de070e7-038f-4519-b4dc-70cb923b6979', '7a372508-c79a-48c9-ad98-dd49bbfa00af', '/images/products/Cordless_hedge_trimmer_resting_b…_20261007221651.jpg', 'Cordless hedge trimmer', 0, '2026-10-09T00:00:00Z'),
  ('98be93df-cd92-42b9-a89d-8d607a87d5da', '62c75d28-4419-4350-b7eb-f84fc125905c', '/images/products/Portable_generator_with_control_…_20261007221651.jpg', 'Portable generator', 0, '2026-10-09T00:00:00Z'),
  ('9f71f4ed-8ec2-40cf-8b92-ad510ce40e17', 'c96d2ab3-aa7b-4e78-8a04-a320c95726bc', '/images/products/Portable_concrete_mixer_on_wheels_20261007221651.jpg', 'Portable concrete mixer', 0, '2026-10-09T00:00:00Z'),
  ('86d4e459-cfab-4a42-a786-d0ed2dc65ad9', '2d8dbfb3-fb20-43d7-a689-44590fb04a54', '/images/products/Aluminium_extension_ladder_standing_20261007221651.jpg', 'Aluminium extension ladder', 0, '2026-10-09T00:00:00Z'),
  ('b3a8ad93-f2f1-4709-bf62-d18407b6c6e9', '88eb1e0c-e245-4483-86eb-b1bd38b15567', '/images/products/Aluminium_platform_ladder_produc…_20261007221651.jpg', 'Aluminium platform ladder', 0, '2026-10-09T00:00:00Z'),
  ('da272112-d1ca-45a9-a819-a555365c822e', 'a5d583f9-227f-49be-87a3-0a518857ae66', '/images/products/Rental_camera_kit_on_background_20261007221651.jpg', 'Mirrorless camera rental kit', 0, '2026-10-09T00:00:00Z'),
  ('77089bd5-38e7-46ed-b6c7-85203004649f', '095741ed-0860-40bd-ae70-01d00b0439b5', '/images/products/Video_tripod_standing_in_studio_20261007221651.jpg', 'Video tripod with fluid head', 0, '2026-10-09T00:00:00Z'),
  ('30d6168c-0ac6-4408-bd36-055642708d17', '2bcbb527-cdfa-4050-b1d7-334bd52faf0a', '/images/products/Compact_digital_projector_with_r…_20261007221651.jpg', 'Compact digital projector with remote', 0, '2026-10-09T00:00:00Z'),
  ('fb8b2cd0-ecb2-4678-83c4-74cc4dbf1a57', 'ad3db23c-ab43-405e-8d43-a9e2428307cc', '/images/products/PA_speaker_on_stand_20261007221651.jpg', 'Powered PA speaker on stand', 0, '2026-10-09T00:00:00Z'),
  ('fc6f7804-cc89-46f4-9c8f-1212b01ad3d4', '80314739-5cf1-4ab7-98d7-ab689e40efbc', '/images/products/Modern_camping_dome_tent_pitched_20261007221651.jpg', 'Four-person dome tent', 0, '2026-10-09T00:00:00Z'),
  ('97223708-81ab-489b-84d2-bef5aca2cb2c', '4658ac23-ae85-4df2-9fc3-8906904303ba', '/images/products/Camping_stove_opened_for_use_20261007221651.jpg', 'Two-burner camping stove', 0, '2026-10-09T00:00:00Z')
ON CONFLICT ("id") DO UPDATE SET
  "product_id" = EXCLUDED."product_id",
  "path" = EXCLUDED."path",
  "alt_text" = EXCLUDED."alt_text",
  "sort_order" = EXCLUDED."sort_order";

-- Generate fixed physical-unit IDs from their stable asset numbers. Units above
-- each product's available count alternate between maintenance and retired so
-- all operational states are represented in the demo.
WITH inventory (product_id, catalogue_code, total_units, available_units) AS (
  VALUES
    ('5fa1f462-6810-4d06-88bd-057ad459991d'::uuid, 'TL-014', 4, 3),
    ('ec8f22d3-7ad2-4d10-8302-582e6172fd94'::uuid, 'CT-022', 3, 2),
    ('3c725698-5f68-437a-94ee-9aa8c43ece17'::uuid, 'MT-031', 5, 4),
    ('f21178e3-9b99-4510-9538-4aebf3e9ca36'::uuid, 'DM-006', 2, 1),
    ('cb37fcc0-37b8-4fad-bd0b-89a5fd928df7'::uuid, 'CL-008', 4, 3),
    ('8ad0d35f-485e-48fa-9ce5-9de631e27eb4'::uuid, 'CL-012', 5, 4),
    ('5d43773f-c516-40e5-88fb-682b7ed76af8'::uuid, 'CL-019', 3, 2),
    ('98a8b8bb-d63d-43b2-8cee-77758d093c74'::uuid, 'FL-004', 2, 1),
    ('39990bed-d17b-46c0-ae31-ce110ee7d2c4'::uuid, 'GD-005', 4, 3),
    ('7a372508-c79a-48c9-ad98-dd49bbfa00af'::uuid, 'GD-011', 4, 2),
    ('62c75d28-4419-4350-b7eb-f84fc125905c'::uuid, 'PW-003', 3, 2),
    ('c96d2ab3-aa7b-4e78-8a04-a320c95726bc'::uuid, 'CN-004', 2, 1),
    ('2d8dbfb3-fb20-43d7-a689-44590fb04a54'::uuid, 'AC-016', 5, 4),
    ('88eb1e0c-e245-4483-86eb-b1bd38b15567'::uuid, 'AC-021', 4, 3),
    ('a5d583f9-227f-49be-87a3-0a518857ae66'::uuid, 'AV-008', 3, 2),
    ('095741ed-0860-40bd-ae70-01d00b0439b5'::uuid, 'AV-014', 4, 4),
    ('2bcbb527-cdfa-4050-b1d7-334bd52faf0a'::uuid, 'AV-019', 3, 2),
    ('ad3db23c-ab43-405e-8d43-a9e2428307cc'::uuid, 'AV-025', 4, 3),
    ('80314739-5cf1-4ab7-98d7-ab689e40efbc'::uuid, 'OD-021', 5, 4),
    ('4658ac23-ae85-4df2-9fc3-8906904303ba'::uuid, 'OD-028', 6, 5)
), units AS (
  SELECT
    md5(i.catalogue_code || ':' || n)::uuid AS id,
    i.product_id,
    i.catalogue_code || '-' || lpad(n::text, 2, '0') AS asset_number,
    'DEMO-' || replace(i.catalogue_code, '-', '') || '-' || lpad(n::text, 3, '0') AS serial_number,
    CASE
      WHEN n <= i.available_units THEN 'available'::unit_operational_state
      WHEN (n - i.available_units) % 2 = 1 THEN 'maintenance'::unit_operational_state
      ELSE 'retired'::unit_operational_state
    END AS operational_state
  FROM inventory i
  CROSS JOIN LATERAL generate_series(1, i.total_units) AS n
)
INSERT INTO "equipment_units" (
  "id", "product_id", "asset_number", "serial_number", "operational_state", "notes", "created_at", "updated_at"
)
SELECT
  id, product_id, asset_number, serial_number, operational_state,
  CASE
    WHEN operational_state = 'maintenance' THEN 'Seeded maintenance example'
    WHEN operational_state = 'retired' THEN 'Seeded retired example'
    ELSE NULL
  END,
  '2026-10-09T00:00:00Z', '2026-10-09T00:00:00Z'
FROM units
ON CONFLICT ("id") DO UPDATE SET
  "product_id" = EXCLUDED."product_id",
  "asset_number" = EXCLUDED."asset_number",
  "serial_number" = EXCLUDED."serial_number",
  "operational_state" = EXCLUDED."operational_state",
  "notes" = EXCLUDED."notes",
  "updated_at" = EXCLUDED."updated_at";

INSERT INTO "maintenance_records" (
  "id", "equipment_unit_id", "start_at", "end_at", "reason", "notes", "created_by_user_id", "created_at"
)
VALUES
  ('30000000-0000-4000-8000-000000000001', md5('MT-031:5')::uuid, '2025-01-01T00:00:00Z', '2030-01-01T00:00:00Z', 'Awaiting replacement guard', 'Long-running record for the maintenance-state example.', '00000000-0000-4000-8000-000000000004', '2026-10-09T00:00:00Z'),
  ('30000000-0000-4000-8000-000000000002', md5('TL-014:1')::uuid, '2027-01-10T00:00:00Z', '2027-01-12T00:00:00Z', 'Scheduled electrical inspection', 'Planned maintenance used to demonstrate period-aware availability.', '00000000-0000-4000-8000-000000000004', '2026-10-09T00:00:00Z'),
  ('30000000-0000-4000-8000-000000000003', md5('CL-012:1')::uuid, '2026-06-01T00:00:00Z', '2026-06-03T00:00:00Z', 'Filter and hose service', 'Completed maintenance history example.', '00000000-0000-4000-8000-000000000003', '2026-06-03T00:00:00Z')
ON CONFLICT ("id") DO UPDATE SET
  "equipment_unit_id" = EXCLUDED."equipment_unit_id",
  "start_at" = EXCLUDED."start_at",
  "end_at" = EXCLUDED."end_at",
  "reason" = EXCLUDED."reason",
  "notes" = EXCLUDED."notes",
  "created_by_user_id" = EXCLUDED."created_by_user_id";
