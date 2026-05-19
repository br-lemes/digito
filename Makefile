.PHONY: build clean linux release test version windows

TARGET := $(notdir $(shell go list -m 2>/dev/null))
ifeq ($(TARGET),)
	TARGET := $(notdir $(CURDIR))
endif

IS_NIXOS := $(shell test -f /etc/NIXOS && echo "yes" || echo "")
INTERPRETER := /lib64/ld-linux-x86-64.so.2

build: test
	@go build -ldflags "-s -w"

clean:
	$(RM) $(TARGET) $(TARGET).exe

linux: test
	@GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o $(TARGET)
ifneq ($(IS_NIXOS),)
	@patchelf --remove-rpath --set-interpreter $(INTERPRETER) $(TARGET)
endif

release: version linux windows
	@go run ./tools/release/main.go

test:
	@go test ./...

version: test
	@go run ./tools/version/main.go

windows: test
	@CC=x86_64-w64-mingw32-gcc \
	CGO_LDFLAGS="-Wl,--allow-multiple-definition" \
	GOOS=windows GOARCH=amd64 go build -ldflags "-H windowsgui -s -w"
