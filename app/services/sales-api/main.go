package main

import (
	"fmt"
	"os"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var build = "develop"

func main() {
	// Construct the application logger.
	config := zap.NewProductionConfig()
	config.OutputPaths = []string{"stdout"}
	config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	config.DisableStacktrace = true
	config.InitialFields = map[string]any{
		"service": "SALES-API",
	}

	log, err := config.Build()
	if err != nil {
		fmt.Println("Error constructing logger:", err)
		os.Exit(1)
	}

	defer log.Sync()

	// Perform the startup and shutdown sequence.
	if err := run(log.Sugar()); err != nil {
		log.Sugar().Errorw("startup", "ERROR", err)
		log.Sync()
		os.Exit(1)
	}
}

func run(log *zap.SugaredLogger) error {
	return nil
}
