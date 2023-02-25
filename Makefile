all:
	sh -c util/appstream_builder.sh
	mv output/vanilla_meta.xml.gz output/vanillaos-kinetic-main.xml.gz
