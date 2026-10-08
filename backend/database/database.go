package database

import (
	"context"

	"github.com/equipmentTest/backend/shared"
	"github.com/jackc/pgx/v5/pgxpool"
)

// For use in routes
var pool *pgxpool.Pool

func Pool() *pgxpool.Pool {
	return pool
}

func DBInit(dbPool *pgxpool.Pool, dbName string) error {
	pool = dbPool

	// Double check connection to database
	if err := dbPool.Ping(context.Background()); err != nil {
		return shared.LogErr("Database unreachable: ", err)
	}

	return nil
}
