crystal_lib: $(shell find . -name "*.cr")
	crystal build src/crystal_lib.cr

clean:
	rm -rf .crystal crystal_lib
