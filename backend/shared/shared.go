package shared

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"time"

	"github.com/gofiber/fiber/v3"
)

type JsonMap = map[string]interface{}

var AppConfig *Config

type Config struct {
	Environment string // Dev or Prod
	AppVersion  string // 2.1.45 etc.
	Database    struct {
		Host        string
		User        string
		Password    string
		Name        string
		Port        string
		SSLMode     string // TODO REVIEW what is this in database? and then use it
		FullConnStr string
	}
	Server struct {
		Port int // Go server port
	}
	Auth struct {
		JwtSecret string
		RateLimit int // TODO what is this? Use it?
	}
}

func LoadConfig() *Config {
	// TODO use docker secrets?
	// TODO validate this data and error when not proper

	// Load variables from .env
	cfg := &Config{}

	cfg.Environment = os.Getenv("ENVIRONMENT")
	cfg.AppVersion = os.Getenv("APP_VERSION")

	cfg.Database.Host = os.Getenv("POSTGRES_HOST")
	cfg.Database.Name = os.Getenv("POSTGRES_DB")
	cfg.Database.Password = os.Getenv("POSTGRES_PASSWORD")
	cfg.Database.Port = os.Getenv("POSTGRES_PORT")
	cfg.Database.User = os.Getenv("POSTGRES_USER")
	// cfg.Database.SSLMode  string // TODO REVIEW what this is and then use it if needed
	cfg.Database.FullConnStr = fmt.Sprintf("postgres://%v:%v@%v:%v/%v?sslmode=disable",
		cfg.Database.User, cfg.Database.Password, cfg.Database.Host, cfg.Database.Port, cfg.Database.Name)

	cfg.Server.Port, _ = strconv.Atoi(os.Getenv("GO_PORT"))

	// Makes users have to re-login when the app version changes.
	cfg.Auth.JwtSecret = os.Getenv("JWT_SECRET") + cfg.AppVersion
	// cfg.Auth.RateLimit // TODO what is this? Use it?

	AppConfig = cfg
	return AppConfig
}

// Wraps a string in ANSI escape codes for the terminal.
func ColorizeANSI(text, color string) string {
	code, exists := map[string]string{
		"red":    "\033[31m",
		"green":  "\033[32m",
		"yellow": "\033[33m",
		"blue":   "\033[34m",
		"orange": "\033[38;5;208m",
	}[color]
	if !exists {
		return text
	}
	return code + text + "\033[0m"
}

// Shortcut to log an error and handle sending the message to the client.
// Return this directly from a handler
func SendAndLogCtxError(c fiber.Ctx, status int, args ...any) error {
	if status >= 500 { // Server error
		LogErrWithCaller(2, args)
	} else { // Probably user error. Still log it
		LogWarnWithCaller(2, args)
	}

	msgParts := []string{strconv.Itoa(status)}
	for _, arg := range args {
		msgParts = append(msgParts, fmt.Sprint(arg))
	}

	return fiber.NewError(status, strings.Join(msgParts, " "))
}

// Generic logger that accepts any number of arguments and returns the last error found if any
func LogErr(args ...any) error {
	var finalErr error
	var msgParts []string

	for _, arg := range args {
		if e, ok := arg.(error); ok {
			finalErr = e
		}
		msgParts = append(msgParts, fmt.Sprint(arg))
	}

	// Adjust Caller to 1 to see where LogErr was called
	_, file, line, _ := runtime.Caller(1)
	timestamp := time.Now().Format("2006/01/02 15:04:05")

	fmt.Printf("%s %s:%d %s\n",
		timestamp,
		filepath.Base(file), line,
		ColorizeANSI(strings.Join(msgParts, " "), "red"),
	)

	return finalErr
}

// Generic logger that accepts any number of arguments and returns the last error found if any
func LogErrWithCaller(caller int, args ...any) error {
	var finalErr error
	var msgParts []string

	for _, arg := range args {
		if e, ok := arg.(error); ok {
			finalErr = e
		}
		msgParts = append(msgParts, fmt.Sprint(arg))
	}

	// Adjust Caller to 1 to see where LogErr was called
	_, file, line, _ := runtime.Caller(caller)
	timestamp := time.Now().Format("2006/01/02 15:04:05")

	fmt.Printf("%s %s:%d %s\n",
		timestamp,
		filepath.Base(file), line,
		ColorizeANSI(strings.Join(msgParts, " "), "red"),
	)

	return finalErr
}

// Generic logger that accepts any number of arguments and returns the last error found if any
func LogWarnWithCaller(caller int, args ...any) error {
	var finalErr error
	var msgParts []string

	for _, arg := range args {
		if e, ok := arg.(error); ok {
			finalErr = e
		}
		msgParts = append(msgParts, fmt.Sprint(arg))
	}

	// Adjust Caller to 1 to see where LogErr was called
	_, file, line, _ := runtime.Caller(caller)
	timestamp := time.Now().Format("2006/01/02 15:04:05")

	fmt.Printf("%s %s:%d %s\n",
		timestamp,
		filepath.Base(file), line,
		ColorizeANSI(strings.Join(msgParts, " "), "yellow"),
	)

	return finalErr
}

// Generic logger that accepts any number of arguments and returns the last error found if any
func LogWarn(args ...any) error {
	var finalErr error
	var msgParts []string

	for _, arg := range args {
		if e, ok := arg.(error); ok {
			finalErr = e
		}
		msgParts = append(msgParts, fmt.Sprint(arg))
	}

	// Adjust Caller to 1 to see where LogErr was called
	_, file, line, _ := runtime.Caller(1)
	timestamp := time.Now().Format("2006/01/02 15:04:05")

	fmt.Printf("%s %s:%d %s\n",
		timestamp,
		filepath.Base(file), line,
		ColorizeANSI(strings.Join(msgParts, " "), "yellow"),
	)

	return finalErr
}

func LogInfo(args ...any) {
	var msgParts []string

	for _, arg := range args {
		msgParts = append(msgParts, fmt.Sprint(arg))
	}

	// Adjust Caller to 1 to see where LogErr was called
	_, file, line, _ := runtime.Caller(1)
	timestamp := time.Now().Format("2006/01/02 15:04:05")

	fmt.Printf("%s %s:%d %s\n",
		timestamp,
		filepath.Base(file), line,
		ColorizeANSI(strings.Join(msgParts, " "), "blue"),
	)
}

func LogGreen(args ...any) {
	var msgParts []string

	for _, arg := range args {
		msgParts = append(msgParts, fmt.Sprint(arg))
	}

	// Adjust Caller to 1 to see where LogErr was called
	_, file, line, _ := runtime.Caller(1)
	timestamp := time.Now().Format("2006/01/02 15:04:05")

	fmt.Printf("%s %s:%d %s\n",
		timestamp,
		filepath.Base(file), line,
		ColorizeANSI(strings.Join(msgParts, " "), "green"),
	)
}
