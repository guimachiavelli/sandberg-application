.PHONY: build
GIFS = $(shell  find content/04-4eva/images -type f -iname "*.gif" | sed 's/gif/jpg/')

build:
	ruby generate-pdf.rb


CONVERT_CMD = convert '$<[0]' $@

convert_gifs: ${GIFS}

content/04-4eva/images/%.jpg: content/04-4eva/images/%.gif
	$(CONVERT_CMD)

