crystal_lib: $(shell find . -name "*.cr")
	crystal build src/main.cr

clean:
	rm -rf .crystal main
