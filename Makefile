all:
	sh -c util/appstream_builder.sh
	output/vanilla_meta.xml.gz output/vanillaos-kinetic-main.xml.gz
