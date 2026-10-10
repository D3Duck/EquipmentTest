# Public Catalogue API

The public catalogue endpoints expose visible equipment products and quantity availability. They do
not expose physical-unit identifiers, customer data, or booking details.

The PostgreSQL queries are defined in `backend/database/queries/catalogue.sql`; sqlc generates the
pgx/v5 query methods and row types consumed by the catalogue service.

## Endpoints

### `GET /api/equipment`

Returns `{ "products": [...] }`, ordered by category and product name.

### `GET /api/equipment/products/:id`

Returns `{ "product": {...} }` for one visible product. The identifier must be a UUID. A hidden or
unknown product returns `404`.

## Hire-period query

Both endpoints accept the optional query parameters `start` and `end`.

- Supply both parameters or neither.
- Values must be RFC3339 timestamps with an explicit timezone.
- `end` must be later than `start`.
- The API normalizes accepted timestamps to UTC.
- Availability uses the half-open interval `[start, end)`: a period ending at a boundary does not
  overlap a period beginning at that boundary.

Example:

```text
GET /api/equipment?start=2027-01-10T09:00:00%2B11:00&end=2027-01-12T17:00:00%2B11:00
```

Without a period, `available_units` equals the number of physical units whose operational state is
`available`. With a period, the API also excludes units with overlapping maintenance and subtracts
quantities from overlapping confirmed booking items in `reserved` or `collected` state.

## Product fields

- `id` and `catalogue_code`
- `name`, `description`, `specifications`, and `hire_terms`
- `daily_rate_cents`
- embedded `category` and ordered `images`
- `total_units`, including retired and maintenance units
- `operational_units`, containing units currently marked `available`
- `available_units`, optionally qualified by `availability_period`
- `availability_period`, present on each product when a period was requested

Validation errors return `400` with `{ "error": "..." }`. Unexpected storage failures return a
generic `500` response without database details.
