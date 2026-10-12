# Demo website

A portfolio-type project demo.

Website: https://testequipment.duckdns.org/

## Seeded demo accounts

The database migration seeds `customer1`, `customer2`, `employee`, `storeadmin`, and `admin` with
the deliberately fictional password `password`. Use `/login` to choose an account or enter its
credentials. Successful sign-in creates a 12-hour, database-backed session in an HTTP-only cookie;
sign-out revokes that session immediately.

The navigation reflects the signed-in role. Customer, store, and system pages are also guarded in
the frontend for usability, while API authorization remains the authoritative security boundary.

## Authentication API

- `POST /api/login` — validate a seeded account and create a session.
- `GET /api/session` — return the current user and session expiry.
- `POST /api/session/refresh` — extend a valid session by 12 hours.
- `POST /api/logout` — revoke the current session and clear its cookie.

Authentication responses use `Cache-Control: no-store`. Session cookies are HTTP-only and
SameSite=Lax, and are marked Secure for HTTPS requests or when `ENVIRONMENT` is `production` or
`prod`. See `documentation/authentication API.md` for request and response details.

## Public catalogue API

- `GET /api/equipment`
- `GET /api/equipment/products/:id`

Both endpoints accept an optional `start` and `end` pair as RFC3339 timestamps. When supplied, the
API returns availability for the half-open interval `[start, end)`. See
`documentation/catalogue API.md` for the response contract and validation behavior.
