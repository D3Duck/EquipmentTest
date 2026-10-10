package catalogue

import (
	"context"
	"encoding/json"
	"errors"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/google/uuid"
)

type fakeReader struct {
	listProducts func(context.Context, *HirePeriod) ([]Product, error)
	getProduct   func(context.Context, uuid.UUID, *HirePeriod) (Product, error)
}

func (fake fakeReader) ListProducts(ctx context.Context, period *HirePeriod) ([]Product, error) {
	return fake.listProducts(ctx, period)
}

func (fake fakeReader) GetProduct(ctx context.Context, id uuid.UUID, period *HirePeriod) (Product, error) {
	return fake.getProduct(ctx, id, period)
}

func newTestApp(reader Reader) *fiber.App {
	app := fiber.New()
	handler := NewHandler(reader)
	app.Get("/api/equipment", handler.ListProducts)
	app.Get("/api/equipment/products/:id", handler.GetProduct)
	return app
}

func TestListProductsWithoutPeriod(t *testing.T) {
	reader := fakeReader{
		listProducts: func(_ context.Context, period *HirePeriod) ([]Product, error) {
			if period != nil {
				t.Fatalf("expected no hire period, got %+v", period)
			}
			return []Product{{
				ID:             uuid.MustParse("5fa1f462-6810-4d06-88bd-057ad459991d"),
				CatalogueCode:  "TL-014",
				Name:           "18V Cordless Drill Kit",
				Specifications: json.RawMessage(`{}`),
				Images:         []Image{},
				AvailableUnits: 3,
			}}, nil
		},
	}

	response, err := newTestApp(reader).Test(httptest.NewRequest("GET", "/api/equipment", nil))
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	defer response.Body.Close()

	if response.StatusCode != fiber.StatusOK {
		t.Fatalf("expected status 200, got %d", response.StatusCode)
	}

	var body struct {
		Products []Product `json:"products"`
	}
	if err := json.NewDecoder(response.Body).Decode(&body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if len(body.Products) != 1 || body.Products[0].CatalogueCode != "TL-014" {
		t.Fatalf("unexpected response: %+v", body.Products)
	}
}

func TestListProductsNormalizesPeriodToUTC(t *testing.T) {
	reader := fakeReader{
		listProducts: func(_ context.Context, period *HirePeriod) ([]Product, error) {
			if period == nil {
				t.Fatal("expected a hire period")
			}
			wantStart := time.Date(2027, time.January, 9, 23, 0, 0, 0, time.UTC)
			wantEnd := time.Date(2027, time.January, 11, 23, 0, 0, 0, time.UTC)
			if !period.Start.Equal(wantStart) || !period.End.Equal(wantEnd) {
				t.Fatalf("unexpected normalized period: %+v", period)
			}
			return []Product{}, nil
		},
	}

	request := httptest.NewRequest(
		"GET",
		"/api/equipment?start=2027-01-10T10%3A00%3A00%2B11%3A00&end=2027-01-12T10%3A00%3A00%2B11%3A00",
		nil,
	)
	response, err := newTestApp(reader).Test(request)
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	defer response.Body.Close()

	if response.StatusCode != fiber.StatusOK {
		t.Fatalf("expected status 200, got %d", response.StatusCode)
	}
}

func TestListProductsRejectsInvalidPeriods(t *testing.T) {
	tests := []struct {
		name string
		url  string
		want string
	}{
		{name: "missing end", url: "/api/equipment?start=2027-01-10T00:00:00Z", want: "start and end must be supplied together"},
		{name: "date without timezone", url: "/api/equipment?start=2027-01-10&end=2027-01-11", want: "start must be an RFC3339 timestamp with a timezone"},
		{name: "equal boundary", url: "/api/equipment?start=2027-01-10T00:00:00Z&end=2027-01-10T00:00:00Z", want: "end must be later than start"},
		{name: "reversed boundary", url: "/api/equipment?start=2027-01-11T00:00:00Z&end=2027-01-10T00:00:00Z", want: "end must be later than start"},
	}

	reader := fakeReader{
		listProducts: func(context.Context, *HirePeriod) ([]Product, error) {
			t.Fatal("reader must not be called for an invalid period")
			return nil, nil
		},
	}
	app := newTestApp(reader)

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			response, err := app.Test(httptest.NewRequest("GET", test.url, nil))
			if err != nil {
				t.Fatalf("request failed: %v", err)
			}
			defer response.Body.Close()

			if response.StatusCode != fiber.StatusBadRequest {
				t.Fatalf("expected status 400, got %d", response.StatusCode)
			}
			var body map[string]string
			if err := json.NewDecoder(response.Body).Decode(&body); err != nil {
				t.Fatalf("decode response: %v", err)
			}
			if body["error"] != test.want {
				t.Fatalf("expected %q, got %q", test.want, body["error"])
			}
		})
	}
}

func TestGetProductValidationAndNotFound(t *testing.T) {
	productID := uuid.MustParse("5fa1f462-6810-4d06-88bd-057ad459991d")
	reader := fakeReader{
		getProduct: func(_ context.Context, id uuid.UUID, _ *HirePeriod) (Product, error) {
			if id != productID {
				t.Fatalf("unexpected product id: %s", id)
			}
			return Product{}, ErrNotFound
		},
	}
	app := newTestApp(reader)

	invalidResponse, err := app.Test(httptest.NewRequest("GET", "/api/equipment/products/not-a-uuid", nil))
	if err != nil {
		t.Fatalf("invalid-id request failed: %v", err)
	}
	invalidResponse.Body.Close()
	if invalidResponse.StatusCode != fiber.StatusBadRequest {
		t.Fatalf("expected invalid id status 400, got %d", invalidResponse.StatusCode)
	}

	notFoundResponse, err := app.Test(httptest.NewRequest("GET", "/api/equipment/products/"+productID.String(), nil))
	if err != nil {
		t.Fatalf("not-found request failed: %v", err)
	}
	defer notFoundResponse.Body.Close()
	if notFoundResponse.StatusCode != fiber.StatusNotFound {
		t.Fatalf("expected missing product status 404, got %d", notFoundResponse.StatusCode)
	}
}

func TestCatalogueErrorsDoNotLeakDatabaseDetails(t *testing.T) {
	reader := fakeReader{
		listProducts: func(context.Context, *HirePeriod) ([]Product, error) {
			return nil, errors.New("postgres connection contains private details")
		},
	}
	response, err := newTestApp(reader).Test(httptest.NewRequest("GET", "/api/equipment", nil))
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	defer response.Body.Close()

	var body map[string]string
	if err := json.NewDecoder(response.Body).Decode(&body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if response.StatusCode != fiber.StatusInternalServerError {
		t.Fatalf("expected status 500, got %d", response.StatusCode)
	}
	if body["error"] != "unable to load the equipment catalogue" {
		t.Fatalf("unexpected public error: %q", body["error"])
	}
}
