package catalogue

import (
	"errors"
	"log"
	"strings"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/google/uuid"
)

type Handler struct {
	reader Reader
}

func NewHandler(reader Reader) *Handler {
	return &Handler{reader: reader}
}

func (handler *Handler) ListProducts(c fiber.Ctx) error {
	period, err := hirePeriodFromQuery(c)
	if err != nil {
		return sendAPIError(c, fiber.StatusBadRequest, err.Error())
	}

	products, err := handler.reader.ListProducts(c.Context(), period)
	if err != nil {
		log.Printf("catalogue list failed")
		return sendAPIError(c, fiber.StatusInternalServerError, "unable to load the equipment catalogue")
	}

	return c.JSON(fiber.Map{"products": products})
}

func (handler *Handler) GetProduct(c fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return sendAPIError(c, fiber.StatusBadRequest, "product id must be a valid UUID")
	}

	period, err := hirePeriodFromQuery(c)
	if err != nil {
		return sendAPIError(c, fiber.StatusBadRequest, err.Error())
	}

	product, err := handler.reader.GetProduct(c.Context(), id, period)
	if errors.Is(err, ErrNotFound) {
		return sendAPIError(c, fiber.StatusNotFound, "equipment product not found")
	}
	if err != nil {
		log.Printf("catalogue product load failed")
		return sendAPIError(c, fiber.StatusInternalServerError, "unable to load the equipment product")
	}

	return c.JSON(fiber.Map{"product": product})
}

func hirePeriodFromQuery(c fiber.Ctx) (*HirePeriod, error) {
	startValue := strings.TrimSpace(c.Query("start"))
	endValue := strings.TrimSpace(c.Query("end"))
	if startValue == "" && endValue == "" {
		return nil, nil
	}
	if startValue == "" || endValue == "" {
		return nil, errors.New("start and end must be supplied together")
	}

	start, err := time.Parse(time.RFC3339, startValue)
	if err != nil {
		return nil, errors.New("start must be an RFC3339 timestamp with a timezone")
	}
	end, err := time.Parse(time.RFC3339, endValue)
	if err != nil {
		return nil, errors.New("end must be an RFC3339 timestamp with a timezone")
	}
	if !start.Before(end) {
		return nil, errors.New("end must be later than start")
	}

	return &HirePeriod{Start: start.UTC(), End: end.UTC()}, nil
}

func sendAPIError(c fiber.Ctx, status int, message string) error {
	return c.Status(status).JSON(fiber.Map{"error": message})
}
