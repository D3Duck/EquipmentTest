-- name: FindActiveAuthUserByUsername :one
SELECT id, username, display_name, password_hash, role
FROM users
WHERE username = sqlc.arg(username)
  AND is_active = true;

-- name: CreateAuthSession :one
INSERT INTO sessions (token_hash, user_id, expires_at)
VALUES (sqlc.arg(token_hash), sqlc.arg(user_id), sqlc.arg(expires_at))
RETURNING id, expires_at;

-- name: GetAuthSessionByTokenHash :one
SELECT
  session.id AS session_id,
  session.expires_at,
  user_account.id AS user_id,
  user_account.username,
  user_account.display_name,
  user_account.role
FROM sessions session
JOIN users user_account ON user_account.id = session.user_id
WHERE session.token_hash = sqlc.arg(token_hash)
  AND session.expires_at > sqlc.arg(now_at)
  AND user_account.is_active = true;

-- name: TouchAuthSession :exec
UPDATE sessions
SET last_seen_at = sqlc.arg(last_seen_at)
WHERE token_hash = sqlc.arg(token_hash);

-- name: RefreshAuthSession :one
UPDATE sessions
SET expires_at = sqlc.arg(expires_at),
    last_seen_at = sqlc.arg(last_seen_at)
WHERE token_hash = sqlc.arg(token_hash)
RETURNING expires_at;

-- name: DeleteAuthSession :exec
DELETE FROM sessions
WHERE token_hash = sqlc.arg(token_hash);
