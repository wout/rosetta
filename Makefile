SHARD_BIN ?= ../../bin

shim:
	mkdir -p $(SHARD_BIN)
	rm -f $(SHARD_BIN)/rosetta_bin
	mv ./tasks/rosetta $(SHARD_BIN)
