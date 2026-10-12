package auth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"io"
	"strings"
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

const (
	SessionCookieName    = "equipment_session"
	defaultSessionLength = 12 * time.Hour
	tokenByteLength      = 32
)

var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrUnauthenticated    = errors.New("authentication required")
	ErrRecordNotFound     = errors.New("record not found")
)

type Role string

const (
	RoleCustomer    Role = "customer"
	RoleEmployee    Role = "employee"
	RoleStoreAdmin  Role = "store_admin"
	RoleSystemAdmin Role = "system_admin"
)

type User struct {
	ID          uuid.UUID `json:"id"`
	Username    string    `json:"username"`
	DisplayName string    `json:"display_name"`
	Role        Role      `json:"role"`
}

type Credential struct {
	User
	PasswordHash string
}

type Session struct {
	ID        uuid.UUID `json:"-"`
	User      User      `json:"user"`
	ExpiresAt time.Time `json:"expires_at"`
}

type NewSession struct {
	TokenHash []byte
	UserID    uuid.UUID
	ExpiresAt time.Time
}

type Store interface {
	FindActiveUserByUsername(context.Context, string) (Credential, error)
	CreateSession(context.Context, NewSession) (uuid.UUID, error)
	GetSessionByTokenHash(context.Context, []byte, time.Time) (Session, error)
	TouchSession(context.Context, []byte, time.Time) error
	RefreshSession(context.Context, []byte, time.Time, time.Time) (time.Time, error)
	DeleteSession(context.Context, []byte) error
}

type Service struct {
	store         Store
	now           func() time.Time
	random        io.Reader
	sessionLength time.Duration
}

// This valid bcrypt hash is used only to equalize failed-login work. It is not
// a credential and never grants access.
const dummyPasswordHash = "$2b$12$.kTahPobpOnX4RfHNUEOUOpqoLHGrX2d59jdzRLUt0Zm0eULNUS1C"

func NewService(store Store, sessionLength time.Duration) *Service {
	if sessionLength <= 0 {
		sessionLength = defaultSessionLength
	}
	return &Service{
		store:         store,
		now:           time.Now,
		random:        rand.Reader,
		sessionLength: sessionLength,
	}
}

func (service *Service) Login(ctx context.Context, username, password string) (Session, string, error) {
	username = strings.ToLower(strings.TrimSpace(username))
	credential, err := service.store.FindActiveUserByUsername(ctx, username)
	if errors.Is(err, ErrRecordNotFound) {
		// Perform the same expensive comparison for unknown and inactive users to
		// reduce the amount of account information exposed through response timing.
		_ = bcrypt.CompareHashAndPassword([]byte(dummyPasswordHash), []byte(password))
		return Session{}, "", ErrInvalidCredentials
	}
	if err != nil {
		return Session{}, "", err
	}
	if bcrypt.CompareHashAndPassword([]byte(credential.PasswordHash), []byte(password)) != nil {
		return Session{}, "", ErrInvalidCredentials
	}

	rawToken := make([]byte, tokenByteLength)
	if _, err := io.ReadFull(service.random, rawToken); err != nil {
		return Session{}, "", err
	}
	token := base64.RawURLEncoding.EncodeToString(rawToken)
	tokenHash := sha256.Sum256(rawToken)
	expiresAt := service.now().UTC().Add(service.sessionLength)
	sessionID, err := service.store.CreateSession(ctx, NewSession{
		TokenHash: tokenHash[:],
		UserID:    credential.ID,
		ExpiresAt: expiresAt,
	})
	if err != nil {
		return Session{}, "", err
	}

	return Session{ID: sessionID, User: credential.User, ExpiresAt: expiresAt}, token, nil
}

func (service *Service) Authenticate(ctx context.Context, token string) (Session, error) {
	tokenHash, err := hashToken(token)
	if err != nil {
		return Session{}, ErrUnauthenticated
	}
	now := service.now().UTC()
	session, err := service.store.GetSessionByTokenHash(ctx, tokenHash, now)
	if errors.Is(err, ErrRecordNotFound) {
		return Session{}, ErrUnauthenticated
	}
	if err != nil {
		return Session{}, err
	}
	if err := service.store.TouchSession(ctx, tokenHash, now); err != nil {
		return Session{}, err
	}
	return session, nil
}

func (service *Service) Refresh(ctx context.Context, token string) (Session, error) {
	session, err := service.Authenticate(ctx, token)
	if err != nil {
		return Session{}, err
	}
	tokenHash, _ := hashToken(token)
	now := service.now().UTC()
	expiresAt := now.Add(service.sessionLength)
	refreshedExpiry, err := service.store.RefreshSession(ctx, tokenHash, now, expiresAt)
	if errors.Is(err, ErrRecordNotFound) {
		return Session{}, ErrUnauthenticated
	}
	if err != nil {
		return Session{}, err
	}
	session.ExpiresAt = refreshedExpiry
	return session, nil
}

func (service *Service) Logout(ctx context.Context, token string) error {
	tokenHash, err := hashToken(token)
	if err != nil {
		return nil
	}
	return service.store.DeleteSession(ctx, tokenHash)
}

func hashToken(token string) ([]byte, error) {
	rawToken, err := base64.RawURLEncoding.DecodeString(token)
	if err != nil || len(rawToken) != tokenByteLength {
		return nil, ErrUnauthenticated
	}
	tokenHash := sha256.Sum256(rawToken)
	return tokenHash[:], nil
}
