package routes

import (
	"github.com/equipmentTest/backend/auth"
	"github.com/equipmentTest/backend/catalogue"
	generated "github.com/equipmentTest/backend/database/generated"
	"github.com/equipmentTest/backend/services"
	"github.com/gofiber/fiber/v3"
	"github.com/jackc/pgx/v5/pgxpool"
)

func SetupRoutes(app *fiber.App, pool *pgxpool.Pool) {
	// Public health and authentication
	app.Get("/health", func(c fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok"})
	})

	app.Post("/api/login", auth.HandleLogin)
	app.Post("/api/refreshLogin", auth.HandleRefreshLogin)
	app.Post("/api/logout", auth.HandleLogout)
	app.Get("/api/appversion", services.GetAppVersion)

	catalogueQueries := generated.New(pool)
	catalogueService := catalogue.NewService(catalogueQueries)
	catalogueHandler := catalogue.NewHandler(catalogueService)
	app.Get("/api/equipment", catalogueHandler.ListProducts)
	app.Get("/api/equipment/products/:id", catalogueHandler.GetProduct)
}
