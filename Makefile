APP=$(shell basename $(shell git remote get-url origin))
REGISTRY := quay.io
NAME := ruslanlap
TAG=$(shell git describe --tags --abbrev=0)
VERSION=$(shell dpkg --print-architecture)
TARGETOS= windows #linux darwin windows
TARGETARCH=arm64 #amd64 arm64
BINARY_NAME := ${GOOS}

SRC := main.go
ifeq (${TARGETOS},darwin)
    ifeq (${TARGETARCH},arm64)
        BINARY_NAME := kbot_mac_arm
    else
        BINARY_NAME := kbot
    endif
else
    BINARY_NAME := kbot
endif

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v 

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/matvrus/kbot/cmd.appVersion=${VERSION}

image:
	docker build -t ${REGISTRY}/${NAME}:${VERSION} .

linux:
	make image APP=linux

windows:
	make image APP=windows

mac:
	make image APP=mac

arm:
	make image APP=arm

push:
	docker push ${REGISTRY}/${NAME}:${TAG}

#clean docker rmi
clean:
	docker rmi -f ${REGISTRY}/${NAME}:${TAG}
