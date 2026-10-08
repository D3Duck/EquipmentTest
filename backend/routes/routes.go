package routes

import (
	"github.com/equipmentTest/backend/auth"
	"github.com/equipmentTest/backend/services"
	"github.com/gofiber/fiber/v3"
)

func SetupRoutes(app *fiber.App) {
	// Public health and authentication
	app.Get("/health", func(c fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok"})
	})

	app.Post("/api/login", auth.HandleLogin)
	app.Post("/api/refreshLogin", auth.HandleRefreshLogin)
	app.Post("/api/logout", auth.HandleLogout)
	app.Get("/api/appversion", services.GetAppVersion)
}
