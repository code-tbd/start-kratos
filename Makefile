# GOPATH
GOPATH:=$(shell go env GOPATH)

# 项目名称
PROJECT_NAME=$(shell cd ../../.. && echo `basename $$PWD`)
# 项目版本号
PROJECT_VERSION=$(shell git describe --tags --always)

# 微服务路径
APP_RELATIVE_PATH=$(shell a=`basename $$PWD` && cd .. && b=`basename $$PWD` && echo $$b/$$a)
# 微服务名称
APP_NAME=$(shell echo $(APP_RELATIVE_PATH) | sed -En "s/\//-/p")
# 微服务镜像
APP_DOCKER_IMAGE=$(shell echo $(APP_NAME) |awk -F '@' '{print "$(PROJECT_NAME)/" $$0 ":0.0.1"}')
# 微服务 proto 文件
INTERNAL_PROTO_FILES=$(shell find internal -name *.proto)
# 微服务 proto 文件
API_PROTO_FILES=$(shell cd ../../../api/$(APP_RELATIVE_PATH)/proto && find . -name '*.proto')

.PHONY: debug
# debug
debug:
	@echo "GOPATH ==> " $(GOPATH)
	@echo "PROJECT_NAME ==> " $(PROJECT_NAME)
	@echo "PROJECT_VERSION ==> " $(PROJECT_VERSION)
	@echo "APP_RELATIVE_PATH ==> " $(APP_RELATIVE_PATH)
	@echo "APP_NAME ==> " $(APP_NAME)
	@echo "APP_DOCKER_IMAGE ==> " $(APP_DOCKER_IMAGE)
	@echo "INTERNAL_PROTO_FILES ==> " $(INTERNAL_PROTO_FILES)
	@echo "API_PROTO_FILES ==> " $(API_PROTO_FILES)

.PHONY: init
init:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	go install github.com/go-kratos/kratos/cmd/kratos/v2@latest
	go install github.com/go-kratos/kratos/cmd/protoc-gen-go-http/v2@latest
	go install github.com/google/gnostic/cmd/protoc-gen-openapi@latest
	go install github.com/google/wire/cmd/wire@latest

.PHONY: config
config:
	protoc --proto_path=./internal/conf \
	       --proto_path=../../../third_party \
 	       --go_out=paths=source_relative:./internal/conf \
	       $(INTERNAL_PROTO_FILES)

.PHONY: api
api:
	cd ../../../api/$(APP_RELATIVE_PATH)/proto && \
	protoc --proto_path=. \
	       --proto_path=../../../../third_party \
 	       --go_out=paths=source_relative:.. \
 	       --go-http_out=paths=source_relative:.. \
 	       --go-grpc_out=paths=source_relative:.. \
	       --openapi_out=fq_schema_naming=true,default_response=false:../../../.. \
	       $(API_PROTO_FILES)

.PHONY: errors
errors:
	cd ../../../api/$(APP_RELATIVE_PATH)/proto && \
	protoc --proto_path=. \
           --proto_path=../../../../third_party \
           --go_out=paths=source_relative:.. \
           --go-errors_out=paths=source_relative:.. \
           $(API_PROTO_FILES)

.PHONY: wire
wire:
	go mod tidy
	go get github.com/google/wire/cmd/wire@latest
	go generate cmd/*/wire_gen.go

.PHONY: gorm
gorm:
	go generate ../../../database/gorm/generate.go && \
	go generate internal/data/generate/generate.go

help:
	@echo ''
	@echo 'Usage:'
	@echo ' make [target]'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
	helpMessage = match(lastLine, /^# (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 2, RLENGTH); \
			printf "\033[36m%-22s\033[0m %s\n", helpCommand,helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
