# Demo website

A portfolio-type project demo.

Website: https://testequipment.duckdns.org/

## Seeded demo accounts

The database migration seeds `customer1`, `customer2`, `employee`, `storeadmin`, and `admin` with
the deliberately fictional password `password`. The login endpoint is still a placeholder, so the
credentials cannot be used until demo authentication is implemented.

## Public catalogue API

- `GET /api/equipment`
- `GET /api/equipment/products/:id`

Both endpoints accept an optional `start` and `end` pair as RFC3339 timestamps. When supplied, the
API returns availability for the half-open interval `[start, end)`. See
`documentation/catalogue API.md` for the response contract and validation behavior.
