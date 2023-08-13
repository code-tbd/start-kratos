//go:build wireinject
// +build wireinject

// The build tag makes sure the stub is not built in the final build.

package main

import (
	"start-kratos/app/cv/service/internal/biz"
	"start-kratos/app/cv/service/internal/conf"
	"start-kratos/app/cv/service/internal/data"
	"start-kratos/app/cv/service/internal/server"
	"start-kratos/app/cv/service/internal/service"

	"github.com/go-kratos/kratos/v2"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/google/wire"
)

// wireApp init kratos application.
func wireApp(*conf.Server, *conf.Data, log.Logger) (*kratos.App, func(), error) {
	panic(wire.Build(server.ProviderSet, data.ProviderSet, biz.ProviderSet, service.ProviderSet, newApp))
}
