package catalogue

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	generated "github.com/equipmentTest/backend/database/generated"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

var ErrNotFound = errors.New("catalogue product not found")

type HirePeriod struct {
	Start time.Time `json:"start"`
	End   time.Time `json:"end"`
}

type Category struct {
	ID   uuid.UUID `json:"id"`
	Slug string    `json:"slug"`
	Name string    `json:"name"`
}

type Image struct {
	ID        uuid.UUID `json:"id"`
	Path      string    `json:"path"`
	AltText   string    `json:"alt_text"`
	SortOrder int       `json:"sort_order"`
}

type Product struct {
	ID                 uuid.UUID       `json:"id"`
	CatalogueCode      string          `json:"catalogue_code"`
	Name               string          `json:"name"`
	Description        string          `json:"description"`
	Specifications     json.RawMessage `json:"specifications"`
	DailyRateCents     int             `json:"daily_rate_cents"`
	HireTerms          *string         `json:"hire_terms"`
	Category           Category        `json:"category"`
	Images             []Image         `json:"images"`
	TotalUnits         int             `json:"total_units"`
	OperationalUnits   int             `json:"operational_units"`
	AvailableUnits     int             `json:"available_units"`
	AvailabilityPeriod *HirePeriod     `json:"availability_period"`
}

type Reader interface {
	ListProducts(context.Context, *HirePeriod) ([]Product, error)
	GetProduct(context.Context, uuid.UUID, *HirePeriod) (Product, error)
}

type Service struct {
	queries generated.Querier
}

func NewService(queries generated.Querier) *Service {
	return &Service{queries: queries}
}

func (service *Service) ListProducts(ctx context.Context, period *HirePeriod) ([]Product, error) {
	start, end := periodArguments(period)
	rows, err := service.queries.ListCatalogueProducts(ctx, generated.ListCatalogueProductsParams{
		HireStartAt: start,
		HireEndAt:   end,
	})
	if err != nil {
		return nil, err
	}

	productIDs := make([]uuid.UUID, len(rows))
	products := make([]Product, len(rows))
	for index, row := range rows {
		productIDs[index] = row.ID
		products[index] = productFromData(productData{
			id:               row.ID,
			catalogueCode:    row.CatalogueCode,
			name:             row.Name,
			description:      row.Description,
			specifications:   row.Specifications,
			dailyRateCents:   row.DailyRateCents,
			hireTerms:        row.HireTerms,
			categoryID:       row.CategoryID,
			categorySlug:     row.CategorySlug,
			categoryName:     row.CategoryName,
			totalUnits:       row.TotalUnits,
			operationalUnits: row.OperationalUnits,
			availableUnits:   row.AvailableUnits,
		}, period)
	}
	if len(productIDs) == 0 {
		return products, nil
	}

	images, err := service.queries.ListProductImages(ctx, productIDs)
	if err != nil {
		return nil, err
	}
	productIndex := make(map[uuid.UUID]int, len(products))
	for index := range products {
		productIndex[products[index].ID] = index
	}
	for _, image := range images {
		index, exists := productIndex[image.ProductID]
		if !exists {
			continue
		}
		products[index].Images = append(products[index].Images, imageFromRow(image))
	}

	return products, nil
}

func (service *Service) GetProduct(ctx context.Context, id uuid.UUID, period *HirePeriod) (Product, error) {
	start, end := periodArguments(period)
	row, err := service.queries.GetCatalogueProduct(ctx, generated.GetCatalogueProductParams{
		HireStartAt: start,
		HireEndAt:   end,
		ProductID:   id,
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return Product{}, ErrNotFound
	}
	if err != nil {
		return Product{}, err
	}

	product := productFromData(productData{
		id:               row.ID,
		catalogueCode:    row.CatalogueCode,
		name:             row.Name,
		description:      row.Description,
		specifications:   row.Specifications,
		dailyRateCents:   row.DailyRateCents,
		hireTerms:        row.HireTerms,
		categoryID:       row.CategoryID,
		categorySlug:     row.CategorySlug,
		categoryName:     row.CategoryName,
		totalUnits:       row.TotalUnits,
		operationalUnits: row.OperationalUnits,
		availableUnits:   row.AvailableUnits,
	}, period)

	images, err := service.queries.ListProductImages(ctx, []uuid.UUID{id})
	if err != nil {
		return Product{}, err
	}
	for _, image := range images {
		product.Images = append(product.Images, imageFromRow(image))
	}

	return product, nil
}

type productData struct {
	id               uuid.UUID
	catalogueCode    string
	name             string
	description      string
	specifications   []byte
	dailyRateCents   int32
	hireTerms        pgtype.Text
	categoryID       uuid.UUID
	categorySlug     string
	categoryName     string
	totalUnits       int32
	operationalUnits int32
	availableUnits   int32
}

func productFromData(data productData, period *HirePeriod) Product {
	product := Product{
		ID:               data.id,
		CatalogueCode:    data.catalogueCode,
		Name:             data.name,
		Description:      data.description,
		Specifications:   json.RawMessage(data.specifications),
		DailyRateCents:   int(data.dailyRateCents),
		Category:         Category{ID: data.categoryID, Slug: data.categorySlug, Name: data.categoryName},
		Images:           make([]Image, 0),
		TotalUnits:       int(data.totalUnits),
		OperationalUnits: int(data.operationalUnits),
		AvailableUnits:   int(data.availableUnits),
	}
	if data.hireTerms.Valid {
		hireTerms := data.hireTerms.String
		product.HireTerms = &hireTerms
	}
	if period != nil {
		periodCopy := *period
		product.AvailabilityPeriod = &periodCopy
	}
	return product
}

func imageFromRow(row generated.ListProductImagesRow) Image {
	return Image{
		ID:        row.ID,
		Path:      row.Path,
		AltText:   row.AltText,
		SortOrder: int(row.SortOrder),
	}
}

func periodArguments(period *HirePeriod) (pgtype.Timestamptz, pgtype.Timestamptz) {
	if period == nil {
		return pgtype.Timestamptz{}, pgtype.Timestamptz{}
	}
	return pgtype.Timestamptz{Time: period.Start, Valid: true},
		pgtype.Timestamptz{Time: period.End, Valid: true}
}
