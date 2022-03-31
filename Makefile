SHARD_BIN ?= ../../bin

shim:
	mkdir -p $(SHARD_BIN)
	mv ./tasks/rosetta $(SHARD_BIN)
