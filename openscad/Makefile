OPENSCAD := openscad
MONTAGE := montage
targets := $(shell ls smp7c_*.scad)
stl_dir := stl
stls := $(targets:%.scad=${stl_dir}/%.stl)
image_dir := images
thumbnails := $(targets:%.scad=${image_dir}/%.png)
img_models := ${image_dir}/models.png

.PHONY: all clean clean_images images
all: stls images
	@echo done

stls: ${stls}
	echo stls succesfully generated

${stls}: ${stl_dir}/%.stl: %.scad
	@echo Building $@ from $<
	${OPENSCAD} -o $@ $<

images: $(thumbnails) ${img_models}
	@echo images succesfully generated

$(thumbnails): ${image_dir}/%.png: %.scad
	@echo Generating $@ from $<
	${OPENSCAD} -o $@ \
		--imgsize=480,320 --colorscheme=Tomorrow \
		--projection o --viewall --view axes $<

${img_models}: ${thumbnails}
	@echo Generating $@ from $^
	${MONTAGE} -label '%t' -pointsize 16 -geometry 480x320 $(sort $^) $@

clean:
	rm ${thumbnails}
	rm ${stls}

clean_images:
	rm ${thumbnails} ${img_models}

clean_stls:
	rm ${stls}
