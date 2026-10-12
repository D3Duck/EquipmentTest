package auth

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"log"
	"strings"
	"time"

	"github.com/gofiber/fiber/v3"
)

type Handler struct {
	service            *Service
	forceSecureCookies bool
}

type loginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type sessionResponse struct {
	User      User      `json:"user"`
	ExpiresAt time.Time `json:"expires_at"`
}

type requestContextKey string

const sessionContextKey requestContextKey = "authenticated-session"

func NewHandler(service *Service, secureCookies bool) *Handler {
	return &Handler{service: service, forceSecureCookies: secureCookies}
}

func (handler *Handler) Login(c fiber.Ctx) error {
	if !strings.HasPrefix(strings.ToLower(c.Get(fiber.HeaderContentType)), fiber.MIMEApplicationJSON) {
		return sendError(c, fiber.StatusUnsupportedMediaType, "content type must be application/json")
	}
	var request loginRequest
	if err := decodeJSON(c.Body(), &request); err != nil {
		return sendError(c, fiber.StatusBadRequest, "request body must contain a username and password")
	}
	request.Username = strings.TrimSpace(request.Username)
	if request.Username == "" || request.Password == "" || len(request.Username) > 50 || len(request.Password) > 128 {
		return sendError(c, fiber.StatusBadRequest, "request body must contain a valid username and password")
	}

	session, token, err := handler.service.Login(c.Context(), request.Username, request.Password)
	if errors.Is(err, ErrInvalidCredentials) {
		return sendError(c, fiber.StatusUnauthorized, "username or password is incorrect")
	}
	if err != nil {
		log.Printf("authentication login failed")
		return sendError(c, fiber.StatusInternalServerError, "unable to sign in")
	}

	handler.setSessionCookie(c, token, session.ExpiresAt)
	setNoStore(c)
	return c.JSON(sessionResponse{User: session.User, ExpiresAt: session.ExpiresAt})
}

func (handler *Handler) CurrentSession(c fiber.Ctx) error {
	session, ok := SessionFromContext(c)
	if !ok {
		return sendError(c, fiber.StatusUnauthorized, "authentication required")
	}
	setNoStore(c)
	return c.JSON(sessionResponse{User: session.User, ExpiresAt: session.ExpiresAt})
}

func (handler *Handler) RefreshSession(c fiber.Ctx) error {
	session, err := handler.service.Refresh(c.Context(), c.Cookies(SessionCookieName))
	if errors.Is(err, ErrUnauthenticated) {
		handler.clearSessionCookie(c)
		return sendError(c, fiber.StatusUnauthorized, "authentication required")
	}
	if err != nil {
		log.Printf("authentication refresh failed")
		return sendError(c, fiber.StatusInternalServerError, "unable to refresh the session")
	}
	handler.setSessionCookie(c, c.Cookies(SessionCookieName), session.ExpiresAt)
	setNoStore(c)
	return c.JSON(sessionResponse{User: session.User, ExpiresAt: session.ExpiresAt})
}

func (handler *Handler) Logout(c fiber.Ctx) error {
	token := c.Cookies(SessionCookieName)
	handler.clearSessionCookie(c)
	if err := handler.service.Logout(c.Context(), token); err != nil {
		log.Printf("authentication logout failed")
		return sendError(c, fiber.StatusInternalServerError, "unable to sign out")
	}
	setNoStore(c)
	return c.SendStatus(fiber.StatusNoContent)
}

func (handler *Handler) Authenticate(c fiber.Ctx) error {
	session, err := handler.service.Authenticate(c.Context(), c.Cookies(SessionCookieName))
	if errors.Is(err, ErrUnauthenticated) {
		handler.clearSessionCookie(c)
		return sendError(c, fiber.StatusUnauthorized, "authentication required")
	}
	if err != nil {
		log.Printf("session authentication failed")
		return sendError(c, fiber.StatusInternalServerError, "unable to verify the session")
	}
	c.Locals(sessionContextKey, session)
	return c.Next()
}

func RequireRoles(roles ...Role) fiber.Handler {
	allowed := make(map[Role]struct{}, len(roles))
	for _, role := range roles {
		allowed[role] = struct{}{}
	}
	return func(c fiber.Ctx) error {
		session, ok := SessionFromContext(c)
		if !ok {
			return sendError(c, fiber.StatusUnauthorized, "authentication required")
		}
		if _, ok := allowed[session.User.Role]; !ok {
			return sendError(c, fiber.StatusForbidden, "you do not have permission to perform this action")
		}
		return c.Next()
	}
}

func SessionFromContext(c fiber.Ctx) (Session, bool) {
	session, ok := c.Locals(sessionContextKey).(Session)
	return session, ok
}

func (handler *Handler) setSessionCookie(c fiber.Ctx, token string, expiresAt time.Time) {
	c.Cookie(&fiber.Cookie{
		Name:     SessionCookieName,
		Value:    token,
		Path:     "/",
		Expires:  expiresAt,
		MaxAge:   max(1, int(time.Until(expiresAt).Seconds())),
		Secure:   handler.secureCookie(c),
		HTTPOnly: true,
		SameSite: fiber.CookieSameSiteLaxMode,
	})
}

func (handler *Handler) clearSessionCookie(c fiber.Ctx) {
	c.Cookie(&fiber.Cookie{
		Name:     SessionCookieName,
		Value:    "",
		Path:     "/",
		Expires:  time.Unix(1, 0).UTC(),
		MaxAge:   -1,
		Secure:   handler.secureCookie(c),
		HTTPOnly: true,
		SameSite: fiber.CookieSameSiteLaxMode,
	})
}

func (handler *Handler) secureCookie(c fiber.Ctx) bool {
	return handler.forceSecureCookies ||
		strings.EqualFold(c.Protocol(), "https") ||
		strings.EqualFold(c.Get(fiber.HeaderXForwardedProto), "https")
}

func decodeJSON(body []byte, destination any) error {
	decoder := json.NewDecoder(bytes.NewReader(body))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(destination); err != nil {
		return err
	}
	if err := decoder.Decode(&struct{}{}); !errors.Is(err, io.EOF) {
		return errors.New("request body must contain one JSON value")
	}
	return nil
}

func sendError(c fiber.Ctx, status int, message string) error {
	setNoStore(c)
	return c.Status(status).JSON(fiber.Map{"error": message})
}

func setNoStore(c fiber.Ctx) {
	c.Set(fiber.HeaderCacheControl, "no-store")
}
