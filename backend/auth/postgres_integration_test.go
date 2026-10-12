package auth

import (
	"context"
	"os"
	"testing"
	"time"

	generated "github.com/equipmentTest/backend/database/generated"
	"github.com/jackc/pgx/v5/pgxpool"
)

func TestPostgresDemoUsersCanAuthenticate(t *testing.T) {
	databaseURL := os.Getenv("TEST_DATABASE_URL")
	if databaseURL == "" {
		t.Skip("TEST_DATABASE_URL is not set")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatalf("create database pool: %v", err)
	}
	defer pool.Close()

	tx, err := pool.Begin(ctx)
	if err != nil {
		t.Fatalf("begin transaction: %v", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	service := NewService(NewPostgresStore(generated.New(tx)), time.Hour)
	for _, username := range []string{"customer1", "customer2", "employee", "storeadmin", "admin"} {
		session, token, err := service.Login(ctx, username, "password")
		if err != nil {
			t.Fatalf("login %s: %v", username, err)
		}
		if session.User.Username != username || token == "" {
			t.Fatalf("unexpected session for %s: %+v", username, session)
		}
	}

	_, token, err := service.Login(ctx, "customer1", "password")
	if err != nil {
		t.Fatalf("create session before disabling user: %v", err)
	}
	if _, err := tx.Exec(ctx, "UPDATE users SET is_active = false WHERE username = 'customer1'"); err != nil {
		t.Fatalf("disable user in test transaction: %v", err)
	}
	if _, err := service.Authenticate(ctx, token); err != ErrUnauthenticated {
		t.Fatalf("expected disabled user's session to be rejected, got %v", err)
	}
	if _, _, err := service.Login(ctx, "customer1", "password"); err != ErrInvalidCredentials {
		t.Fatalf("expected disabled user's login to be rejected, got %v", err)
	}
}
