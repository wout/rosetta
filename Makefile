CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN ?= $(shell which shards)
TARGET_FILE = rosetta
SOURCE_FILE = ./tasks/runner.cr

initializer:
	$(SHARDS_BIN) build
	$(CRYSTAL_BIN) build $(SOURCE_FILE) -o ../../bin/$(TARGET_FILE)
