.PHONY: build clean linux release test version windows

TARGET := $(notdir $(shell go list -m 2>/dev/null))
ifeq ($(TARGET),)
	TARGET := $(notdir $(CURDIR))
endif

export CGO_ENABLED=1

IS_NIXOS := $(shell test -f /etc/NIXOS && echo "yes" || echo "")
INTERPRETER := /lib64/ld-linux-x86-64.so.2

SEMVER := github.com/br-lemes/semver@latest

build: test
	@go build -ldflags "-s -w"

all: linux windows

clean:
	$(RM) $(TARGET) $(TARGET).exe

linux: test
	@GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o $(TARGET)
ifneq ($(IS_NIXOS),)
	@patchelf --remove-rpath --set-interpreter $(INTERPRETER) $(TARGET)
endif

release: version linux windows
	@go run $(SEMVER) release $(TARGET) $(TARGET).exe

test:
	@go test ./...

version: test
	@go run $(SEMVER)

windows: test
	@CC=x86_64-w64-mingw32-gcc \
	CGO_LDFLAGS="-Wl,--allow-multiple-definition" \
	GOOS=windows GOARCH=amd64 go build -ldflags "-H windowsgui -s -w"
