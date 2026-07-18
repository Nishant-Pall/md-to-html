BINARY := parser
SRC := .

.PHONY: build run clean

build:
	odin build $(SRC) -out:$(BINARY)

run: build
	./$(BINARY) $(ARGS)

clean:
	rm -f $(BINARY)
