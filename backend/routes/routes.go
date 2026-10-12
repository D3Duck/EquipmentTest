package routes

import (
	"strings"
	"time"

	"github.com/equipmentTest/backend/auth"
	"github.com/equipmentTest/backend/catalogue"
	generated "github.com/equipmentTest/backend/database/generated"
	"github.com/equipmentTest/backend/services"
	"github.com/equipmentTest/backend/shared"
	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/limiter"
	"github.com/jackc/pgx/v5/pgxpool"
)

func SetupRoutes(app *fiber.App, pool *pgxpool.Pool) {
	// Public health and authentication
	app.Get("/health", func(c fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok"})
	})

	queries := generated.New(pool)
	authService := auth.NewService(auth.NewPostgresStore(queries), 12*time.Hour)
	secureCookies := strings.EqualFold(shared.AppConfig.Environment, "production") ||
		strings.EqualFold(shared.AppConfig.Environment, "prod")
	authHandler := auth.NewHandler(authService, secureCookies)
	loginLimiter := limiter.New(limiter.Config{
		Max:        10,
		Expiration: time.Minute,
		LimitReached: func(c fiber.Ctx) error {
			c.Set(fiber.HeaderCacheControl, "no-store")
			return c.Status(fiber.StatusTooManyRequests).JSON(fiber.Map{
				"error": "too many sign-in attempts; please try again shortly",
			})
		},
	})
	app.Post("/api/login", loginLimiter, authHandler.Login)
	app.Get("/api/session", authHandler.Authenticate, authHandler.CurrentSession)
	app.Post("/api/session/refresh", authHandler.RefreshSession)
	app.Post("/api/logout", authHandler.Logout)
	app.Get("/api/appversion", services.GetAppVersion)

	catalogueService := catalogue.NewService(queries)
	catalogueHandler := catalogue.NewHandler(catalogueService)
	app.Get("/api/equipment", catalogueHandler.ListProducts)
	app.Get("/api/equipment/products/:id", catalogueHandler.GetProduct)
}
