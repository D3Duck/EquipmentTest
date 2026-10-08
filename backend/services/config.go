package services

import (
	"github.com/equipmentTest/backend/shared"
	"github.com/gofiber/fiber/v3"
)

type AppInfo struct {
	AppVersion string `json:"app_version"`
}

func GetAppVersion(c fiber.Ctx) error {
	return c.JSON(AppInfo{AppVersion: shared.AppConfig.AppVersion})
}
