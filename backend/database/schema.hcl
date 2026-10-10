schema "public" {
}

enum "user_role" {
  schema = schema.public
  values = ["customer", "employee", "store_admin", "system_admin"]
}

enum "unit_operational_state" {
  schema = schema.public
  values = ["available", "maintenance", "retired"]
}

enum "basket_status" {
  schema = schema.public
  values = ["active", "checked_out", "abandoned"]
}

enum "booking_status" {
  schema = schema.public
  values = ["confirmed", "cancelled", "completed"]
}

enum "booking_item_status" {
  schema = schema.public
  values = ["reserved", "collected", "returned", "cancelled"]
}

table "users" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "username" {
    type = varchar(50)
  }
  column "display_name" {
    type = varchar(120)
  }
  column "password_hash" {
    type = text
  }
  column "role" {
    type    = enum.user_role
    default = "customer"
  }
  column "is_active" {
    type    = boolean
    default = true
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }
  column "updated_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  index "users_username_key" {
    unique  = true
    columns = [column.username]
  }
  check "users_username_not_blank" {
    expr = "btrim(username) <> ''"
  }
}

table "sessions" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "token_hash" {
    type = bytea
  }
  column "user_id" {
    type = uuid
    null = true
  }
  column "expires_at" {
    type = timestamptz
  }
  column "last_seen_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  foreign_key "sessions_user_id_fkey" {
    columns     = [column.user_id]
    ref_columns = [table.users.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "sessions_token_hash_key" {
    unique  = true
    columns = [column.token_hash]
  }
  index "sessions_user_id_idx" {
    columns = [column.user_id]
  }
  index "sessions_expires_at_idx" {
    columns = [column.expires_at]
  }
  check "sessions_token_hash_length" {
    expr = "octet_length(token_hash) = 32"
  }
  check "sessions_expiry_after_creation" {
    expr = "expires_at > created_at"
  }
}

table "equipment_categories" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "slug" {
    type = varchar(50)
  }
  column "name" {
    type = varchar(80)
  }
  column "sort_order" {
    type    = integer
    default = 0
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  index "equipment_categories_slug_key" {
    unique  = true
    columns = [column.slug]
  }
  index "equipment_categories_name_key" {
    unique  = true
    columns = [column.name]
  }
  check "equipment_categories_slug_format" {
    expr = "slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'"
  }
  check "equipment_categories_name_not_blank" {
    expr = "btrim(name) <> ''"
  }
}

table "equipment_products" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "category_id" {
    type = uuid
  }
  column "catalogue_code" {
    type = varchar(50)
  }
  column "name" {
    type = varchar(160)
  }
  column "description" {
    type = text
  }
  column "specifications" {
    type    = jsonb
    default = sql("'{}'::jsonb")
  }
  column "daily_rate_cents" {
    type = integer
  }
  column "hire_terms" {
    type = text
    null = true
  }
  column "is_visible" {
    type    = boolean
    default = true
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }
  column "updated_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  foreign_key "equipment_products_category_id_fkey" {
    columns     = [column.category_id]
    ref_columns = [table.equipment_categories.column.id]
    on_update   = NO_ACTION
    on_delete   = RESTRICT
  }
  index "equipment_products_category_id_idx" {
    columns = [column.category_id]
  }
  index "equipment_products_catalogue_code_key" {
    unique  = true
    columns = [column.catalogue_code]
  }
  index "equipment_products_visible_idx" {
    columns = [column.is_visible]
  }
  check "equipment_products_name_not_blank" {
    expr = "btrim(name) <> ''"
  }
  check "equipment_products_catalogue_code_format" {
    expr = "catalogue_code ~ '^[A-Z0-9]+(?:-[A-Z0-9]+)*$'"
  }
  check "equipment_products_description_not_blank" {
    expr = "btrim(description) <> ''"
  }
  check "equipment_products_daily_rate_nonnegative" {
    expr = "daily_rate_cents >= 0"
  }
  check "equipment_products_specifications_object" {
    expr = "jsonb_typeof(specifications) = 'object'"
  }
}

table "equipment_product_images" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "product_id" {
    type = uuid
  }
  column "path" {
    type = text
  }
  column "alt_text" {
    type = varchar(240)
  }
  column "sort_order" {
    type    = integer
    default = 0
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  foreign_key "equipment_product_images_product_id_fkey" {
    columns     = [column.product_id]
    ref_columns = [table.equipment_products.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "equipment_product_images_product_sort_key" {
    unique  = true
    columns = [column.product_id, column.sort_order]
  }
  index "equipment_product_images_path_key" {
    unique  = true
    columns = [column.path]
  }
  check "equipment_product_images_path_not_blank" {
    expr = "btrim(path) <> ''"
  }
  check "equipment_product_images_alt_text_not_blank" {
    expr = "btrim(alt_text) <> ''"
  }
}

table "equipment_units" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "product_id" {
    type = uuid
  }
  column "asset_number" {
    type = varchar(60)
  }
  column "serial_number" {
    type = varchar(120)
    null = true
  }
  column "operational_state" {
    type    = enum.unit_operational_state
    default = "available"
  }
  column "notes" {
    type = text
    null = true
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }
  column "updated_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  foreign_key "equipment_units_product_id_fkey" {
    columns     = [column.product_id]
    ref_columns = [table.equipment_products.column.id]
    on_update   = NO_ACTION
    on_delete   = RESTRICT
  }
  index "equipment_units_asset_number_key" {
    unique  = true
    columns = [column.asset_number]
  }
  index "equipment_units_product_state_idx" {
    columns = [column.product_id, column.operational_state]
  }
  check "equipment_units_asset_number_not_blank" {
    expr = "btrim(asset_number) <> ''"
  }
}

table "maintenance_records" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "equipment_unit_id" {
    type = uuid
  }
  column "start_at" {
    type = timestamptz
  }
  column "end_at" {
    type = timestamptz
  }
  column "reason" {
    type = varchar(240)
  }
  column "notes" {
    type = text
    null = true
  }
  column "created_by_user_id" {
    type = uuid
    null = true
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  foreign_key "maintenance_records_equipment_unit_id_fkey" {
    columns     = [column.equipment_unit_id]
    ref_columns = [table.equipment_units.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "maintenance_records_created_by_user_id_fkey" {
    columns     = [column.created_by_user_id]
    ref_columns = [table.users.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  index "maintenance_records_unit_period_idx" {
    columns = [column.equipment_unit_id, column.start_at, column.end_at]
  }
  check "maintenance_records_valid_period" {
    expr = "end_at > start_at"
  }
  check "maintenance_records_reason_not_blank" {
    expr = "btrim(reason) <> ''"
  }
}

table "baskets" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "user_id" {
    type = uuid
    null = true
  }
  column "guest_session_id" {
    type = uuid
    null = true
  }
  column "status" {
    type    = enum.basket_status
    default = "active"
  }
  column "version" {
    type    = bigint
    default = 0
  }
  column "expires_at" {
    type = timestamptz
    null = true
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }
  column "updated_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  foreign_key "baskets_user_id_fkey" {
    columns     = [column.user_id]
    ref_columns = [table.users.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "baskets_guest_session_id_fkey" {
    columns     = [column.guest_session_id]
    ref_columns = [table.sessions.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  index "baskets_active_user_key" {
    unique  = true
    columns = [column.user_id]
    where   = "status = 'active' AND user_id IS NOT NULL"
  }
  index "baskets_active_guest_session_key" {
    unique  = true
    columns = [column.guest_session_id]
    where   = "status = 'active' AND guest_session_id IS NOT NULL"
  }
  index "baskets_expires_at_idx" {
    columns = [column.expires_at]
  }
  check "baskets_exactly_one_owner" {
    expr = "(user_id IS NOT NULL) <> (guest_session_id IS NOT NULL)"
  }
  check "baskets_version_nonnegative" {
    expr = "version >= 0"
  }
}

table "basket_items" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "basket_id" {
    type = uuid
  }
  column "product_id" {
    type = uuid
  }
  column "quantity" {
    type = integer
  }
  column "hire_start_at" {
    type = timestamptz
    null = true
  }
  column "hire_end_at" {
    type = timestamptz
    null = true
  }
  column "quoted_unit_price_cents" {
    type = integer
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }
  column "updated_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  foreign_key "basket_items_basket_id_fkey" {
    columns     = [column.basket_id]
    ref_columns = [table.baskets.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "basket_items_product_id_fkey" {
    columns     = [column.product_id]
    ref_columns = [table.equipment_products.column.id]
    on_update   = NO_ACTION
    on_delete   = RESTRICT
  }
  index "basket_items_basket_product_key" {
    unique  = true
    columns = [column.basket_id, column.product_id]
  }
  index "basket_items_product_id_idx" {
    columns = [column.product_id]
  }
  check "basket_items_quantity_positive" {
    expr = "quantity > 0"
  }
  check "basket_items_period_pair" {
    expr = "(hire_start_at IS NULL AND hire_end_at IS NULL) OR (hire_start_at IS NOT NULL AND hire_end_at IS NOT NULL AND hire_end_at > hire_start_at)"
  }
  check "basket_items_quoted_price_nonnegative" {
    expr = "quoted_unit_price_cents >= 0"
  }
}

table "bookings" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "reference" {
    type = varchar(32)
  }
  column "customer_id" {
    type = uuid
  }
  column "status" {
    type    = enum.booking_status
    default = "confirmed"
  }
  column "total_cents" {
    type = bigint
  }
  column "cancelled_at" {
    type = timestamptz
    null = true
  }
  column "cancelled_by_user_id" {
    type = uuid
    null = true
  }
  column "cancellation_reason" {
    type = text
    null = true
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }
  column "updated_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  foreign_key "bookings_customer_id_fkey" {
    columns     = [column.customer_id]
    ref_columns = [table.users.column.id]
    on_update   = NO_ACTION
    on_delete   = RESTRICT
  }
  foreign_key "bookings_cancelled_by_user_id_fkey" {
    columns     = [column.cancelled_by_user_id]
    ref_columns = [table.users.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  index "bookings_reference_key" {
    unique  = true
    columns = [column.reference]
  }
  index "bookings_customer_created_idx" {
    columns = [column.customer_id, column.created_at]
  }
  check "bookings_reference_not_blank" {
    expr = "btrim(reference) <> ''"
  }
  check "bookings_total_nonnegative" {
    expr = "total_cents >= 0"
  }
  check "bookings_cancellation_fields" {
    expr = "(status = 'cancelled' AND cancelled_at IS NOT NULL) OR status <> 'cancelled'"
  }
}

table "booking_items" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "booking_id" {
    type = uuid
  }
  column "product_id" {
    type = uuid
  }
  column "product_name" {
    type = varchar(160)
  }
  column "quantity" {
    type = integer
  }
  column "hire_start_at" {
    type = timestamptz
  }
  column "hire_end_at" {
    type = timestamptz
  }
  column "unit_price_cents" {
    type = integer
  }
  column "line_total_cents" {
    type = bigint
  }
  column "status" {
    type    = enum.booking_item_status
    default = "reserved"
  }
  column "cancelled_at" {
    type = timestamptz
    null = true
  }
  column "cancellation_reason" {
    type = text
    null = true
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }
  column "updated_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  foreign_key "booking_items_booking_id_fkey" {
    columns     = [column.booking_id]
    ref_columns = [table.bookings.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "booking_items_product_id_fkey" {
    columns     = [column.product_id]
    ref_columns = [table.equipment_products.column.id]
    on_update   = NO_ACTION
    on_delete   = RESTRICT
  }
  index "booking_items_booking_product_key" {
    unique  = true
    columns = [column.booking_id, column.product_id]
  }
  index "booking_items_product_status_period_idx" {
    columns = [column.product_id, column.status, column.hire_start_at, column.hire_end_at]
  }
  check "booking_items_product_name_not_blank" {
    expr = "btrim(product_name) <> ''"
  }
  check "booking_items_quantity_positive" {
    expr = "quantity > 0"
  }
  check "booking_items_valid_period" {
    expr = "hire_end_at > hire_start_at"
  }
  check "booking_items_unit_price_nonnegative" {
    expr = "unit_price_cents >= 0"
  }
  check "booking_items_line_total" {
    expr = "line_total_cents = quantity::bigint * unit_price_cents::bigint"
  }
  check "booking_items_cancellation_fields" {
    expr = "(status = 'cancelled' AND cancelled_at IS NOT NULL) OR status <> 'cancelled'"
  }
}

table "booking_item_units" {
  schema = schema.public

  column "booking_item_id" {
    type = uuid
  }
  column "equipment_unit_id" {
    type = uuid
  }
  column "allocated_by_user_id" {
    type = uuid
    null = true
  }
  column "allocated_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }
  column "released_at" {
    type = timestamptz
    null = true
  }

  primary_key {
    columns = [column.booking_item_id, column.equipment_unit_id]
  }
  foreign_key "booking_item_units_booking_item_id_fkey" {
    columns     = [column.booking_item_id]
    ref_columns = [table.booking_items.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
  foreign_key "booking_item_units_equipment_unit_id_fkey" {
    columns     = [column.equipment_unit_id]
    ref_columns = [table.equipment_units.column.id]
    on_update   = NO_ACTION
    on_delete   = RESTRICT
  }
  foreign_key "booking_item_units_allocated_by_user_id_fkey" {
    columns     = [column.allocated_by_user_id]
    ref_columns = [table.users.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  index "booking_item_units_equipment_unit_id_idx" {
    columns = [column.equipment_unit_id]
  }
  check "booking_item_units_release_after_allocation" {
    expr = "released_at IS NULL OR released_at >= allocated_at"
  }
}

table "audit_events" {
  schema = schema.public

  column "id" {
    type    = uuid
    default = sql("gen_random_uuid()")
  }
  column "actor_user_id" {
    type = uuid
    null = true
  }
  column "actor_session_id" {
    type = uuid
    null = true
  }
  column "action" {
    type = varchar(120)
  }
  column "entity_type" {
    type = varchar(80)
  }
  column "entity_id" {
    type = uuid
    null = true
  }
  column "before_data" {
    type = jsonb
    null = true
  }
  column "after_data" {
    type = jsonb
    null = true
  }
  column "metadata" {
    type    = jsonb
    default = sql("'{}'::jsonb")
  }
  column "request_id" {
    type = uuid
    null = true
  }
  column "created_at" {
    type    = timestamptz
    default = sql("CURRENT_TIMESTAMP")
  }

  primary_key {
    columns = [column.id]
  }
  foreign_key "audit_events_actor_user_id_fkey" {
    columns     = [column.actor_user_id]
    ref_columns = [table.users.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  foreign_key "audit_events_actor_session_id_fkey" {
    columns     = [column.actor_session_id]
    ref_columns = [table.sessions.column.id]
    on_update   = NO_ACTION
    on_delete   = SET_NULL
  }
  index "audit_events_created_at_idx" {
    columns = [column.created_at]
  }
  index "audit_events_actor_user_id_idx" {
    columns = [column.actor_user_id]
  }
  index "audit_events_entity_idx" {
    columns = [column.entity_type, column.entity_id]
  }
  check "audit_events_action_not_blank" {
    expr = "btrim(action) <> ''"
  }
  check "audit_events_entity_type_not_blank" {
    expr = "btrim(entity_type) <> ''"
  }
  check "audit_events_metadata_object" {
    expr = "jsonb_typeof(metadata) = 'object'"
  }
}
