APP=$(shell basename $(shell git remote get-url origin))
REGISTRY := quay.io/ruslanlap
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
# VERSION=$(dpkg --print-architecture)
TARGETOS= darwin #linux darwin windows
#TARGETARCH=$(shell dpkg --print-architecture)
TARGETARCH=arm64 #amd64 arm64
BINARY_NAME := ${GOOS}
LASTIMAGES := $(shell docker images | grep ${REGISTRY}/${APP} | awk '{print $$1":"$$2}')


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

mkdir:
	mkdir -p output/${APP}/${TARGETARCH}

cp:
	cp ${BINARY_NAME} output/${APP}/${TARGETARCH}

build: format get cp
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/matvrus/kbot/cmd.appVersion=${VERSION}

image: mkdir
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}


linux:
	make image APP=linux

windows:
	make image APP=windows

mac:
	make image APP=mac

arm:
	make image APP=arm


push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

#clean docker rmi
clean:
	docker rmi ${LASTIMAGES}