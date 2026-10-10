package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"time"

	"github.com/equipmentTest/backend/database"
	"github.com/equipmentTest/backend/routes"
	"github.com/equipmentTest/backend/shared"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/logger"
	"github.com/gofiber/fiber/v3/middleware/recover"
	"github.com/gofiber/fiber/v3/middleware/static"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	shared.LogInfo("Starting App")

	AppConfig := shared.LoadConfig()
	app := fiber.New()
	// TODO clear up the use of these two properly
	app.Use(logger.New())
	app.Use(recover.New())

	// - - - WEBSOCKET - - -
	// TODO

	// - - - DATABASE - - -
	Pool, err := pgxpool.New(context.Background(), shared.AppConfig.Database.FullConnStr)
	if err != nil {
		panic(shared.LogErr("Unable to create new database pool:", err))
	}

	err = database.DBInit(Pool, AppConfig.Database.Name)
	if err != nil {
		panic(shared.LogErr("Could not connect to database: ", err))
	}
	defer Pool.Close()

	// - - - SERVER SETUP - - -
	routes.SetupRoutes(app, Pool)

	// - - - FRONTEND - - -
	shared.LogInfo("Loading frontend")
	// TODO IMPORTANT do we log with println or some logging middleware? Get this straight in the whole app.
	frontendPath := "../frontend/build"
	if _, err := os.Stat(frontendPath); os.IsNotExist(err) {
		// Different path inside Docker image
		// TODO this can just be the same path - /frontend/build
		frontendPath = "./frontend/build"
		if _, err := os.Stat(frontendPath); os.IsNotExist(err) {
			log.Fatal("No frontend build found. Not starting server.")
			return
		}
	}

	absImgPath, _ := filepath.Abs("../images")
	app.Use("/images", static.New(absImgPath))

	app.Use("/", static.New(frontendPath))
	app.All("*", func(c fiber.Ctx) error {
		path := c.Path()

		// If it's an API call or a specific file request that reached here, it's a 404
		if strings.HasPrefix(path, "/api/") || strings.Contains(path, ".") {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"error": "Not Found",
			})
		}

		// Otherwise, serve the SPA frontend
		return c.SendFile(filepath.Join(frontendPath, "index.html"))
	})

	portStr := fmt.Sprintf(":%d", AppConfig.Server.Port)
	shared.LogGreen("Starting server at http://localhost", portStr, "\n")

	shutdownContext, stopSignals := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stopSignals()
	shutdownComplete := make(chan struct{})
	go func() {
		<-shutdownContext.Done()
		shared.LogInfo("Shutdown signal received; draining connections")
		if err := app.ShutdownWithTimeout(10 * time.Second); err != nil {
			shared.LogErr("Graceful shutdown did not complete: ", err)
		}
		close(shutdownComplete)
	}()

	listenErr := app.Listen(portStr)
	if shutdownContext.Err() != nil {
		<-shutdownComplete
	}
	if listenErr != nil {
		log.Printf("Server stopped unexpectedly: %v", listenErr)
	}
}
