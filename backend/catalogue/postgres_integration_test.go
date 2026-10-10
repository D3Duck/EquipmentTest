package catalogue

import (
	"context"
	"fmt"
	"os"
	"testing"
	"time"

	generated "github.com/equipmentTest/backend/database/generated"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

func TestPostgresAvailabilityUsesHalfOpenIntervals(t *testing.T) {
	databaseURL := os.Getenv("TEST_DATABASE_URL")
	if databaseURL == "" {
		t.Skip("TEST_DATABASE_URL is not set")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatalf("create database pool: %v", err)
	}
	defer pool.Close()

	tx, err := pool.Begin(ctx)
	if err != nil {
		t.Fatalf("begin transaction: %v", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	service := NewService(generated.New(tx))
	drillID := uuid.MustParse("5fa1f462-6810-4d06-88bd-057ad459991d")

	products, err := service.ListProducts(ctx, nil)
	if err != nil {
		t.Fatalf("list seeded products: %v", err)
	}
	if len(products) != 20 {
		t.Fatalf("expected 20 seeded products, got %d", len(products))
	}
	var seededDrill Product
	for _, product := range products {
		if product.ID == drillID {
			seededDrill = product
			break
		}
	}
	if seededDrill.ID != drillID {
		t.Fatal("seeded drill was not returned by the catalogue query")
	}
	if len(seededDrill.Images) != 1 || seededDrill.Images[0].Path == "" {
		t.Fatalf("expected the seeded drill image, got %+v", seededDrill.Images)
	}
	if seededDrill.AvailableUnits != 3 {
		t.Fatalf("expected 3 operational drill units, got %d", seededDrill.AvailableUnits)
	}

	beforeMaintenance := &HirePeriod{
		Start: time.Date(2027, time.January, 8, 0, 0, 0, 0, time.UTC),
		End:   time.Date(2027, time.January, 10, 0, 0, 0, 0, time.UTC),
	}
	product, err := service.GetProduct(ctx, drillID, beforeMaintenance)
	if err != nil {
		t.Fatalf("load product before maintenance: %v", err)
	}
	if product.AvailableUnits != 3 {
		t.Fatalf("expected back-to-back maintenance boundary to leave 3 units, got %d", product.AvailableUnits)
	}

	overlappingMaintenance := &HirePeriod{
		Start: time.Date(2027, time.January, 9, 23, 59, 0, 0, time.UTC),
		End:   time.Date(2027, time.January, 10, 1, 0, 0, 0, time.UTC),
	}
	product, err = service.GetProduct(ctx, drillID, overlappingMaintenance)
	if err != nil {
		t.Fatalf("load product during maintenance: %v", err)
	}
	if product.AvailableUnits != 2 {
		t.Fatalf("expected overlapping maintenance to leave 2 units, got %d", product.AvailableUnits)
	}

	_, err = tx.Exec(ctx, `
INSERT INTO bookings (id, reference, customer_id, status, total_cents)
VALUES ($1, $2, $3, 'confirmed', 5600)`,
		uuid.MustParse("40000000-0000-4000-8000-000000000001"),
		fmt.Sprintf("TEST-%d", time.Now().UnixNano()),
		uuid.MustParse("00000000-0000-4000-8000-000000000001"),
	)
	if err != nil {
		t.Fatalf("insert test booking: %v", err)
	}
	_, err = tx.Exec(ctx, `
INSERT INTO booking_items (
  id, booking_id, product_id, product_name, quantity, hire_start_at, hire_end_at,
  unit_price_cents, line_total_cents, status
)
VALUES ($1, $2, $3, '18V Cordless Drill Kit', 2, $4, $5, 2800, 5600, 'reserved')`,
		uuid.MustParse("40000000-0000-4000-8000-000000000002"),
		uuid.MustParse("40000000-0000-4000-8000-000000000001"),
		drillID,
		time.Date(2027, time.February, 1, 0, 0, 0, 0, time.UTC),
		time.Date(2027, time.February, 3, 0, 0, 0, 0, time.UTC),
	)
	if err != nil {
		t.Fatalf("insert test booking item: %v", err)
	}

	backToBackBooking := &HirePeriod{
		Start: time.Date(2027, time.February, 3, 0, 0, 0, 0, time.UTC),
		End:   time.Date(2027, time.February, 4, 0, 0, 0, 0, time.UTC),
	}
	product, err = service.GetProduct(ctx, drillID, backToBackBooking)
	if err != nil {
		t.Fatalf("load product after booking: %v", err)
	}
	if product.AvailableUnits != 3 {
		t.Fatalf("expected back-to-back booking boundary to leave 3 units, got %d", product.AvailableUnits)
	}

	overlappingBooking := &HirePeriod{
		Start: time.Date(2027, time.February, 2, 0, 0, 0, 0, time.UTC),
		End:   time.Date(2027, time.February, 4, 0, 0, 0, 0, time.UTC),
	}
	product, err = service.GetProduct(ctx, drillID, overlappingBooking)
	if err != nil {
		t.Fatalf("load product during booking: %v", err)
	}
	if product.AvailableUnits != 1 {
		t.Fatalf("expected overlapping booking to leave 1 unit, got %d", product.AvailableUnits)
	}
}
