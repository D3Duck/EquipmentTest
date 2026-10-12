package auth

import (
	"context"
	"errors"
	"time"

	generated "github.com/equipmentTest/backend/database/generated"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

type queryStore interface {
	CreateAuthSession(context.Context, generated.CreateAuthSessionParams) (generated.CreateAuthSessionRow, error)
	DeleteAuthSession(context.Context, []byte) error
	FindActiveAuthUserByUsername(context.Context, string) (generated.FindActiveAuthUserByUsernameRow, error)
	GetAuthSessionByTokenHash(context.Context, generated.GetAuthSessionByTokenHashParams) (generated.GetAuthSessionByTokenHashRow, error)
	RefreshAuthSession(context.Context, generated.RefreshAuthSessionParams) (pgtype.Timestamptz, error)
	TouchAuthSession(context.Context, generated.TouchAuthSessionParams) error
}

type PostgresStore struct {
	queries queryStore
}

func NewPostgresStore(queries queryStore) *PostgresStore {
	return &PostgresStore{queries: queries}
}

func (store *PostgresStore) FindActiveUserByUsername(ctx context.Context, username string) (Credential, error) {
	row, err := store.queries.FindActiveAuthUserByUsername(ctx, username)
	if errors.Is(err, pgx.ErrNoRows) {
		return Credential{}, ErrRecordNotFound
	}
	if err != nil {
		return Credential{}, err
	}
	return Credential{
		User: User{
			ID:          row.ID,
			Username:    row.Username,
			DisplayName: row.DisplayName,
			Role:        Role(row.Role),
		},
		PasswordHash: row.PasswordHash,
	}, nil
}

func (store *PostgresStore) CreateSession(ctx context.Context, session NewSession) (uuid.UUID, error) {
	row, err := store.queries.CreateAuthSession(ctx, generated.CreateAuthSessionParams{
		TokenHash: session.TokenHash,
		UserID:    pgtype.UUID{Bytes: session.UserID, Valid: true},
		ExpiresAt: pgtype.Timestamptz{Time: session.ExpiresAt, Valid: true},
	})
	if err != nil {
		return uuid.Nil, err
	}
	return row.ID, nil
}

func (store *PostgresStore) GetSessionByTokenHash(ctx context.Context, tokenHash []byte, now time.Time) (Session, error) {
	row, err := store.queries.GetAuthSessionByTokenHash(ctx, generated.GetAuthSessionByTokenHashParams{
		TokenHash: tokenHash,
		NowAt:     pgtype.Timestamptz{Time: now, Valid: true},
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return Session{}, ErrRecordNotFound
	}
	if err != nil {
		return Session{}, err
	}
	return Session{
		ID: row.SessionID,
		User: User{
			ID:          row.UserID,
			Username:    row.Username,
			DisplayName: row.DisplayName,
			Role:        Role(row.Role),
		},
		ExpiresAt: row.ExpiresAt.Time,
	}, nil
}

func (store *PostgresStore) TouchSession(ctx context.Context, tokenHash []byte, now time.Time) error {
	return store.queries.TouchAuthSession(ctx, generated.TouchAuthSessionParams{
		LastSeenAt: pgtype.Timestamptz{Time: now, Valid: true},
		TokenHash:  tokenHash,
	})
}

func (store *PostgresStore) RefreshSession(ctx context.Context, tokenHash []byte, now, expiresAt time.Time) (time.Time, error) {
	value, err := store.queries.RefreshAuthSession(ctx, generated.RefreshAuthSessionParams{
		ExpiresAt:  pgtype.Timestamptz{Time: expiresAt, Valid: true},
		LastSeenAt: pgtype.Timestamptz{Time: now, Valid: true},
		TokenHash:  tokenHash,
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return time.Time{}, ErrRecordNotFound
	}
	if err != nil {
		return time.Time{}, err
	}
	return value.Time, nil
}

func (store *PostgresStore) DeleteSession(ctx context.Context, tokenHash []byte) error {
	return store.queries.DeleteAuthSession(ctx, tokenHash)
}
