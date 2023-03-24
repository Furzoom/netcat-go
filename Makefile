DIR 				= ./build
CLIENT 				= client
SERVER				= netcat-go

GOARCH				= amd64
GOARCH_ARM			= arm
GOARCH_ARM64		= arm64

GOOSX				= darwin
GOOSLINUX			= linux
GOOSANDROID 		= android

OSX_C_BIN 			= $(DIR)/$(CLIENT)-darwin-$(GOARCH)
OSX_S_BIN 			= $(DIR)/$(SERVER)-darwin-$(GOARCH)

LINUX_C_BIN 		= $(DIR)/$(CLIENT)-linux-$(GOARCH)
LINUX_S_BIN 		= $(DIR)/$(SERVER)-linux-$(GOARCH)

ANDROID_C_ARM_BIN	= $(DIR)/$(CLIENT)-android-$(GOARCH_ARM)
ANDROID_S_ARM_BIN 	= $(DIR)/$(SERVER)-android-$(GOARCH_ARM)
ANDROID_C_ARM64_BIN	= $(DIR)/$(CLIENT)-android-$(GOARCH_ARM64)
ANDROID_S_ARM64_BIN	= $(DIR)/$(SERVER)-android-$(GOARCH_ARM64)

NDK					?= ${NDK_R21}
API					?= 21
TOOLCHAIN			= $(NDK)/toolchains/llvm/prebuilt/$(shell uname -s | tr '[:upper:]' '[:lower:]')-$(shell uname -m)
TARGET_ARM			= armv7a-linux-androideabi
TARGET_ARM64		= aarch64-linux-android
ANDROID_ARM_CC		= $(TOOLCHAIN)/bin/${TARGET_ARM}${API}-clang
ANDROID_ARM64_CC	= $(TOOLCHAIN)/bin/${TARGET_ARM64}${API}-clang

CC 					= go build
CFLAGS				= -trimpath
LDFLAGS				= all=-w -s
GCFLAGS 			= all=
ASMFLAGS 			= all=

all: darwin linux android

darwin: $(OSX_C_BIN) $(OSX_S_BIN)
linux: $(LINUX_C_BIN) $(LINUX_S_BIN)
android: $(ANDROID_C_ARM_BIN) $(ANDROID_S_ARM_BIN) $(ANDROID_C_ARM64_BIN) $(ANDROID_S_ARM64_BIN)

$(OSX_C_BIN):
	GOARCH=$(GOARCH) GOOS=$(GOOSX) CGO_ENABLED=0 \
	$(CC) $(CFLAGS) -o $@ -ldflags="$(LDFLAGS)" -gcflags="$(GCFLAGS)" -asmflags="$(ASMFLAGS)" ./cmd/client

$(OSX_S_BIN):
	GOARCH=$(GOARCH) GOOS=$(GOOSX) CGO_ENABLED=0 \
	$(CC) $(CFLAGS) -o $@ -ldflags="$(LDFLAGS)" -gcflags="$(GCFLAGS)" -asmflags="$(ASMFLAGS)" ./cmd/netcat

$(LINUX_C_BIN):
	GOARCH=$(GOARCH) GOOS=$(GOOSLINUX) CGO_ENABLED=0 \
	$(CC) $(CFLAGS) -o $@ -ldflags="$(LDFLAGS)" -gcflags="$(GCFLAGS)" -asmflags="$(ASMFLAGS)" ./cmd/client

$(LINUX_S_BIN):
	GOARCH=$(GOARCH) GOOS=$(GOOSLINUX) CGO_ENABLED=0 \
	$(CC) $(CFLAGS) -o $@ -ldflags="$(LDFLAGS)" -gcflags="$(GCFLAGS)" -asmflags="$(ASMFLAGS)" ./cmd/netcat

$(ANDROID_C_ARM_BIN):
	GOARCH=$(GOARCH_ARM) GOOS=$(GOOSANDROID) CGO_ENABLED=1 CC=$(ANDROID_ARM_CC) \
	$(CC) $(CFLAGS) -o $@ -ldflags="$(LDFLAGS)" -gcflags="$(GCFLAGS)" -asmflags="$(ASMFLAGS)" ./cmd/client

$(ANDROID_S_ARM_BIN):
	GOARCH=$(GOARCH_ARM) GOOS=$(GOOSANDROID) CGO_ENABLED=1 CC=$(ANDROID_ARM_CC) \
	$(CC) $(CFLAGS) -o $@ -ldflags="$(LDFLAGS)" -gcflags="$(GCFLAGS)" -asmflags="$(ASMFLAGS)" ./cmd/netcat

$(ANDROID_C_ARM64_BIN):
	GOARCH=$(GOARCH_ARM64) GOOS=$(GOOSANDROID) CGO_ENABLED=1 CC=$(ANDROID_ARM64_CC) \
	$(CC) $(CFLAGS) -o $@ -ldflags="$(LDFLAGS)" -gcflags="$(GCFLAGS)" -asmflags="$(ASMFLAGS)" ./cmd/client

$(ANDROID_S_ARM64_BIN):
	GOARCH=$(GOARCH_ARM64) GOOS=$(GOOSANDROID) CGO_ENABLED=1 CC=$(ANDROID_ARM64_CC) \
	$(CC) $(CFLAGS) -o $@ -ldflags="$(LDFLAGS)" -gcflags="$(GCFLAGS)" -asmflags="$(ASMFLAGS)" ./cmd/netcat

clean:
	rm -rf $(DIR)/*

.PHONY: clean all darwin linux android
