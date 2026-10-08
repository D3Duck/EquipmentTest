package auth

import "github.com/gofiber/fiber/v3"

// Authentication will be implemented for the seeded demo accounts.
func HandleLogin(c fiber.Ctx) error {
	return notImplemented(c)
}

// Session refresh will be implemented with the demo authentication flow.
func HandleRefreshLogin(c fiber.Ctx) error {
	return notImplemented(c)
}

// Logout will be implemented with the demo authentication flow.
func HandleLogout(c fiber.Ctx) error {
	return notImplemented(c)
}

func notImplemented(c fiber.Ctx) error {
	return c.Status(fiber.StatusNotImplemented).JSON(fiber.Map{
		"error": "demo authentication is not implemented yet",
	})
}
