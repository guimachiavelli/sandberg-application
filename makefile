.PHONY: build
GIFS = $(shell  find content/projects/04-4eva/images -type f -iname "*.gif" | sed 's/gif/jpg/')

build:
	@echo 'generating pdfs'
	@ruby generate-pdf.rb
	@echo 'done'

package:
	zip -9 -r dist.zip ./dist

CONVERT_CMD = convert '$<[0]' $@

convert_gifs: ${GIFS}

content/04-4eva/images/%.jpg: content/04-4eva/images/%.gif
	$(CONVERT_CMD)

