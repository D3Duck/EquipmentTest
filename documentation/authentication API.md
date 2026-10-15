# Authentication API

The application uses opaque server-side sessions. A successful login returns a random token in the
`equipment_session` cookie; only its SHA-256 hash is stored in PostgreSQL. Sessions last 12 hours,
can be refreshed explicitly, and are deleted on sign-out. Disabling a user also prevents an
existing session from authenticating.

The cookie is HTTP-only, uses `SameSite=Lax`, is scoped to `/`, and is marked `Secure` for HTTPS
requests or when the application environment is `production` or `prod`. Authentication responses
use `Cache-Control: no-store`.

## Seeded accounts

All accounts use the deliberately fictional password `password`.

| Username     | Display name     | Role         |
| ------------ | ---------------- | ------------ |
| `customer1`  | Casey Customer   | customer     |
| `customer2`  | Morgan Customer  | customer     |
| `employee`   | Emery Employee   | employee     |
| `storeadmin` | Alex Store Admin | store_admin  |
| `admin`      | Sam System Admin | system_admin |

## Endpoints

### `POST /api/login`

Request:

```json
{
  "username": "customer1",
  "password": "password"
}
```

Success returns `200 OK`, sets the session cookie, and returns:

```json
{
  "user": {
    "id": "00000000-0000-4000-8000-000000000001",
    "username": "customer1",
    "display_name": "Casey Customer",
    "role": "customer"
  },
  "expires_at": "2026-10-11T12:00:00Z"
}
```

Malformed input returns `400 Bad Request`. Unknown, inactive, and incorrect credentials all return
the same `401 Unauthorized` response so the endpoint does not reveal whether an account exists.
Requests must use `Content-Type: application/json`; other media types return
`415 Unsupported Media Type`.
The application limits each client address to ten sign-in attempts per minute and returns
`429 Too Many Requests` when that limit is reached.

### `GET /api/session`

Returns the same user and expiry representation for a valid session. A missing, malformed,
expired, revoked, or disabled-user session returns `401 Unauthorized` and expires the browser
cookie.

### `POST /api/session/refresh`

Extends a valid session by 12 hours and returns the updated session representation. It returns
`401 Unauthorized` if the session is no longer valid.

### `POST /api/logout`

Deletes the server-side session, expires the browser cookie, and returns `204 No Content`.
Calling it without a valid cookie is safe and still returns `204 No Content`.

## Authorization

Backend handlers can compose session authentication with an explicit role allowlist. Role checks
do not treat all roles as a simple hierarchy: each endpoint declares its accepted roles according
to the product permission matrix. The client-side route guard and role-specific navigation are
only user-interface conveniences and do not replace API authorization.

Current guarded frontend workspaces are:

- `/bookings`: `customer` and `system_admin`
- `/store`: `employee`, `store_admin`, and `system_admin`
- `/system`: `system_admin`
