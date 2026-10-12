package auth

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type memoryStore struct {
	credentials map[string]Credential
	sessions    map[string]Session
	created     NewSession
	deletedHash []byte
}

func newMemoryStore(t *testing.T) *memoryStore {
	t.Helper()
	passwordHash, err := bcrypt.GenerateFromPassword([]byte("password"), bcrypt.MinCost)
	if err != nil {
		t.Fatalf("hash test password: %v", err)
	}
	return &memoryStore{
		credentials: map[string]Credential{
			"customer1": {
				User: User{
					ID:          uuid.MustParse("00000000-0000-4000-8000-000000000001"),
					Username:    "customer1",
					DisplayName: "Casey Customer",
					Role:        RoleCustomer,
				},
				PasswordHash: string(passwordHash),
			},
			"employee": {
				User: User{
					ID:          uuid.MustParse("00000000-0000-4000-8000-000000000003"),
					Username:    "employee",
					DisplayName: "Emery Employee",
					Role:        RoleEmployee,
				},
				PasswordHash: string(passwordHash),
			},
			"storeadmin": {
				User: User{
					ID:          uuid.MustParse("00000000-0000-4000-8000-000000000004"),
					Username:    "storeadmin",
					DisplayName: "Alex Store Admin",
					Role:        RoleStoreAdmin,
				},
				PasswordHash: string(passwordHash),
			},
			"admin": {
				User: User{
					ID:          uuid.MustParse("00000000-0000-4000-8000-000000000005"),
					Username:    "admin",
					DisplayName: "Sam System Admin",
					Role:        RoleSystemAdmin,
				},
				PasswordHash: string(passwordHash),
			},
		},
		sessions: make(map[string]Session),
	}
}

func (store *memoryStore) FindActiveUserByUsername(_ context.Context, username string) (Credential, error) {
	credential, ok := store.credentials[username]
	if !ok {
		return Credential{}, ErrRecordNotFound
	}
	return credential, nil
}

func (store *memoryStore) CreateSession(_ context.Context, session NewSession) (uuid.UUID, error) {
	store.created = session
	id := uuid.MustParse("10000000-0000-4000-8000-000000000001")
	credential := store.credentialByID(session.UserID)
	store.sessions[string(session.TokenHash)] = Session{ID: id, User: credential.User, ExpiresAt: session.ExpiresAt}
	return id, nil
}

func (store *memoryStore) GetSessionByTokenHash(_ context.Context, tokenHash []byte, now time.Time) (Session, error) {
	session, ok := store.sessions[string(tokenHash)]
	if !ok || !session.ExpiresAt.After(now) {
		return Session{}, ErrRecordNotFound
	}
	return session, nil
}

func (store *memoryStore) TouchSession(context.Context, []byte, time.Time) error { return nil }

func (store *memoryStore) RefreshSession(_ context.Context, tokenHash []byte, _ time.Time, expiresAt time.Time) (time.Time, error) {
	session, ok := store.sessions[string(tokenHash)]
	if !ok {
		return time.Time{}, ErrRecordNotFound
	}
	session.ExpiresAt = expiresAt
	store.sessions[string(tokenHash)] = session
	return expiresAt, nil
}

func (store *memoryStore) DeleteSession(_ context.Context, tokenHash []byte) error {
	store.deletedHash = bytes.Clone(tokenHash)
	delete(store.sessions, string(tokenHash))
	return nil
}

func (store *memoryStore) credentialByID(id uuid.UUID) Credential {
	for _, credential := range store.credentials {
		if credential.ID == id {
			return credential
		}
	}
	return Credential{}
}

func newTestService(store Store) *Service {
	service := NewService(store, time.Hour)
	service.now = func() time.Time {
		return time.Date(2026, time.October, 11, 1, 2, 3, 0, time.UTC)
	}
	randomBytes := make([]byte, tokenByteLength*16)
	for index := range randomBytes {
		randomBytes[index] = byte(index)
	}
	service.random = bytes.NewReader(randomBytes)
	return service
}

func TestLoginNormalizesUsernameAndStoresOnlyTokenHash(t *testing.T) {
	store := newMemoryStore(t)
	service := newTestService(store)

	session, token, err := service.Login(context.Background(), "  CUSTOMER1 ", "password")
	if err != nil {
		t.Fatalf("login failed: %v", err)
	}
	if session.User.Username != "customer1" || session.User.Role != RoleCustomer {
		t.Fatalf("unexpected user: %+v", session.User)
	}
	if token == "" || bytes.Contains(store.created.TokenHash, []byte(token)) {
		t.Fatal("expected an opaque token with only its hash stored")
	}
	if len(store.created.TokenHash) != sha256Size {
		t.Fatalf("expected a %d-byte token hash, got %d", sha256Size, len(store.created.TokenHash))
	}
	wantExpiry := time.Date(2026, time.October, 11, 2, 2, 3, 0, time.UTC)
	if !session.ExpiresAt.Equal(wantExpiry) {
		t.Fatalf("expected expiry %s, got %s", wantExpiry, session.ExpiresAt)
	}
}

func TestLoginRejectsUnknownUserAndBadPasswordIdentically(t *testing.T) {
	store := newMemoryStore(t)
	service := newTestService(store)

	for _, test := range []struct {
		username string
		password string
	}{
		{username: "missing", password: "password"},
		{username: "customer1", password: "incorrect"},
	} {
		if _, _, err := service.Login(context.Background(), test.username, test.password); !errors.Is(err, ErrInvalidCredentials) {
			t.Fatalf("expected invalid credentials for %q, got %v", test.username, err)
		}
	}
}

func TestExpiredSessionIsRejected(t *testing.T) {
	store := newMemoryStore(t)
	service := newTestService(store)
	_, token, err := service.Login(context.Background(), "customer1", "password")
	if err != nil {
		t.Fatalf("login failed: %v", err)
	}
	service.now = func() time.Time {
		return time.Date(2026, time.October, 11, 2, 2, 4, 0, time.UTC)
	}
	if _, err := service.Authenticate(context.Background(), token); !errors.Is(err, ErrUnauthenticated) {
		t.Fatalf("expected expired session to be rejected, got %v", err)
	}
}

func TestAuthenticationHTTPFlowAndRoleBoundary(t *testing.T) {
	store := newMemoryStore(t)
	handler := NewHandler(newTestService(store), false)
	app := fiber.New()
	app.Post("/api/login", handler.Login)
	app.Get("/api/session", handler.Authenticate, handler.CurrentSession)
	app.Post("/api/session/refresh", handler.RefreshSession)
	app.Get(
		"/api/store/example",
		handler.Authenticate,
		RequireRoles(RoleEmployee, RoleStoreAdmin, RoleSystemAdmin),
		func(c fiber.Ctx) error { return c.SendStatus(fiber.StatusNoContent) },
	)
	app.Post("/api/logout", handler.Logout)

	customerCookie := loginForTest(t, app, "customer1", "password")
	currentResponse := requestWithCookie(t, app, "GET", "/api/session", customerCookie)
	if currentResponse.StatusCode != fiber.StatusOK {
		t.Fatalf("expected current session status 200, got %d", currentResponse.StatusCode)
	}
	defer currentResponse.Body.Close()
	var current sessionResponse
	if err := json.NewDecoder(currentResponse.Body).Decode(&current); err != nil {
		t.Fatalf("decode session response: %v", err)
	}
	if current.User.Username != "customer1" {
		t.Fatalf("unexpected current user: %+v", current.User)
	}
	refreshed := requestWithCookie(t, app, "POST", "/api/session/refresh", customerCookie)
	refreshed.Body.Close()
	if refreshed.StatusCode != fiber.StatusOK {
		t.Fatalf("expected refresh status 200, got %d", refreshed.StatusCode)
	}

	forbidden := requestWithCookie(t, app, "GET", "/api/store/example", customerCookie)
	forbidden.Body.Close()
	if forbidden.StatusCode != fiber.StatusForbidden {
		t.Fatalf("expected customer status 403, got %d", forbidden.StatusCode)
	}

	employeeCookie := loginForTest(t, app, "employee", "password")
	allowed := requestWithCookie(t, app, "GET", "/api/store/example", employeeCookie)
	allowed.Body.Close()
	if allowed.StatusCode != fiber.StatusNoContent {
		t.Fatalf("expected employee status 204, got %d", allowed.StatusCode)
	}

	logout := requestWithCookie(t, app, "POST", "/api/logout", customerCookie)
	logout.Body.Close()
	if logout.StatusCode != fiber.StatusNoContent {
		t.Fatalf("expected logout status 204, got %d", logout.StatusCode)
	}
	afterLogout := requestWithCookie(t, app, "GET", "/api/session", customerCookie)
	afterLogout.Body.Close()
	if afterLogout.StatusCode != fiber.StatusUnauthorized {
		t.Fatalf("expected logged-out status 401, got %d", afterLogout.StatusCode)
	}
}

func TestLoginValidationAndGenericCredentialError(t *testing.T) {
	store := newMemoryStore(t)
	handler := NewHandler(newTestService(store), true)
	app := fiber.New()
	app.Post("/api/login", handler.Login)

	unsupported, err := app.Test(httptest.NewRequest("POST", "/api/login", strings.NewReader(`{"username":"customer1","password":"password"}`)))
	if err != nil {
		t.Fatalf("unsupported-media login request failed: %v", err)
	}
	unsupported.Body.Close()
	if unsupported.StatusCode != fiber.StatusUnsupportedMediaType {
		t.Fatalf("expected unsupported media status 415, got %d", unsupported.StatusCode)
	}

	malformedRequest := httptest.NewRequest("POST", "/api/login", strings.NewReader(`{"username":`))
	malformedRequest.Header.Set("Content-Type", "application/json")
	malformed, err := app.Test(malformedRequest)
	if err != nil {
		t.Fatalf("malformed login request failed: %v", err)
	}
	malformed.Body.Close()
	if malformed.StatusCode != fiber.StatusBadRequest {
		t.Fatalf("expected malformed status 400, got %d", malformed.StatusCode)
	}

	response := loginResponseForTest(t, app, "customer1", "incorrect")
	defer response.Body.Close()
	if response.StatusCode != fiber.StatusUnauthorized {
		t.Fatalf("expected invalid login status 401, got %d", response.StatusCode)
	}
	var body map[string]string
	if err := json.NewDecoder(response.Body).Decode(&body); err != nil {
		t.Fatalf("decode invalid login response: %v", err)
	}
	if body["error"] != "username or password is incorrect" {
		t.Fatalf("unexpected credential error: %q", body["error"])
	}
}

func TestProductionSessionCookieIsSecure(t *testing.T) {
	store := newMemoryStore(t)
	handler := NewHandler(newTestService(store), true)
	app := fiber.New()
	app.Post("/api/login", handler.Login)

	cookie := loginForTest(t, app, "customer1", "password")
	if !cookie.Secure {
		t.Fatal("expected production session cookie to be secure")
	}
}

func TestRoleMiddlewareEnforcesPermissionMatrix(t *testing.T) {
	store := newMemoryStore(t)
	handler := NewHandler(newTestService(store), false)
	app := fiber.New()
	app.Post("/api/login", handler.Login)
	app.Get(
		"/customer",
		handler.Authenticate,
		RequireRoles(RoleCustomer, RoleSystemAdmin),
		func(c fiber.Ctx) error { return c.SendStatus(fiber.StatusNoContent) },
	)
	app.Get(
		"/store",
		handler.Authenticate,
		RequireRoles(RoleEmployee, RoleStoreAdmin, RoleSystemAdmin),
		func(c fiber.Ctx) error { return c.SendStatus(fiber.StatusNoContent) },
	)
	app.Get(
		"/system",
		handler.Authenticate,
		RequireRoles(RoleSystemAdmin),
		func(c fiber.Ctx) error { return c.SendStatus(fiber.StatusNoContent) },
	)

	tests := []struct {
		username string
		allowed  map[string]bool
	}{
		{username: "customer1", allowed: map[string]bool{"/customer": true}},
		{username: "employee", allowed: map[string]bool{"/store": true}},
		{username: "storeadmin", allowed: map[string]bool{"/store": true}},
		{username: "admin", allowed: map[string]bool{"/customer": true, "/store": true, "/system": true}},
	}
	for _, test := range tests {
		t.Run(test.username, func(t *testing.T) {
			cookie := loginForTest(t, app, test.username, "password")
			for _, path := range []string{"/customer", "/store", "/system"} {
				response := requestWithCookie(t, app, "GET", path, cookie)
				response.Body.Close()
				want := fiber.StatusForbidden
				if test.allowed[path] {
					want = fiber.StatusNoContent
				}
				if response.StatusCode != want {
					t.Fatalf("%s: expected status %d, got %d", path, want, response.StatusCode)
				}
			}
		})
	}
}

func loginForTest(t *testing.T, app *fiber.App, username, password string) *http.Cookie {
	t.Helper()
	response := loginResponseForTest(t, app, username, password)
	defer response.Body.Close()
	if response.StatusCode != fiber.StatusOK {
		t.Fatalf("expected login status 200, got %d", response.StatusCode)
	}
	cookies := response.Cookies()
	if len(cookies) != 1 {
		t.Fatalf("expected one session cookie, got %d", len(cookies))
	}
	if !cookies[0].HttpOnly || cookies[0].SameSite != http.SameSiteLaxMode {
		t.Fatalf("session cookie is missing security attributes: %+v", cookies[0])
	}
	return cookies[0]
}

func loginResponseForTest(t *testing.T, app *fiber.App, username, password string) *http.Response {
	t.Helper()
	body, err := json.Marshal(loginRequest{Username: username, Password: password})
	if err != nil {
		t.Fatalf("encode login body: %v", err)
	}
	request := httptest.NewRequest("POST", "/api/login", bytes.NewReader(body))
	request.Header.Set("Content-Type", "application/json")
	response, err := app.Test(request)
	if err != nil {
		t.Fatalf("login request failed: %v", err)
	}
	return response
}

func requestWithCookie(t *testing.T, app *fiber.App, method, path string, cookie *http.Cookie) *http.Response {
	t.Helper()
	request := httptest.NewRequest(method, path, nil)
	request.AddCookie(cookie)
	response, err := app.Test(request)
	if err != nil {
		t.Fatalf("%s %s failed: %v", method, path, err)
	}
	return response
}

const sha256Size = 32
