all: cli
cli: $(shell find . -name "*.cr")
	crystal build src/cli.cr -o crystal_lib 

clean:
	rm -rf .crystal crystal_lib
