#!/bin/sh

SEPARATOR="-------------------------------------------------------------------------------"

download_icon() {
    local APPID=$1
    local ICON_URL=$(sed -rn 's/.*<icon type="remote">(.*)<\/icon>/\1/p' packages/usr/share/metainfo/$APPID.metainfo.xml)

    echo "Downloading icon for $APPID..."
    wget -O packages/usr/share/icons/hicolor/scalable/apps/$APPID.svg $ICON_URL 2> /dev/null
}

get_app_ids() {
    ls -1 packages/usr/share/metainfo/ | rev | cut -d '.' -f 3- | rev
}

escape_string() {
    echo -n $1 | sed -r -n 's/([\.\/\"])/\\\1/gp'
}

replace_icon_ids() {
    local APPID=$1
    local LINE=$(cat packages/usr/share/metainfo/$APPID.metainfo.xml | grep "<icon type=\"remote\".*")
    local ESC_LINE=$(escape_string "$LINE")
    local ESC_APPID=$(escape_string "$APPID")
    sed -r -z "s/([ \t]*<icon[^\n]*>$ESC_APPID[a-z\.]*<\/icon>\n){1,}/    $ESC_LINE\n/" -i output/vanilla_meta.xml
}

add_container_to_bundle() {
    local APPID=$1
    local LINE=$(cat packages/usr/share/metainfo/$APPID.metainfo.xml | grep "<bundle")
    local ESC_LINE=$(escape_string "$LINE")
    local BUNDLE_TEXT=$(echo -n $LINE | sed -r -n 's/.*>(.*)<\/bundle>/\1/p')
    sed -r -i "s/<bundle.*>$BUNDLE_TEXT<\/bundle>/$ESC_LINE/" output/vanilla_meta.xml
}


# Download icons required by appstreamcli compose
echo "Downloading remote icons...\n"
echo $(get_app_ids) | tr ' ' '\n' | while read entry; do
    download_icon $entry
done

# Generate Appstream
echo $SEPARATOR
echo "Generating Appstream...\n"
appstreamcli compose --origin="vanilla_meta" packages --data-dir=output
echo "Appstream generated at output/vanilla_meta.xml.gz"

# Validate
if [ "$1" != "--novalidate" ]; then
    echo $SEPARATOR
    echo "Validating Appstream...\n"
    appstreamcli validate --no-net --explain --pedantic output/vanilla_meta.xml.gz
fi

# Fix some problems with the generated output
echo $SEPARATOR
echo "Running fixups..."
gzip -d output/vanilla_meta.xml.gz
echo $(get_app_ids) | tr ' ' '\n' | while read entry; do
    # Replace fixed icons with remote, as gnome-software caches icons for us
    replace_icon_ids $entry
    # Add container to bundle tag
    add_container_to_bundle $entry
done
# Add origin name to components tag
sed -r -i 's/(<components.*)>/\1 origin="vanilla_meta">/' output/vanilla_meta.xml
gzip output/vanilla_meta.xml

# Cleanup
echo $SEPARATOR
echo "Running cleanup..."
rm -rf packages/usr/share/swcatalog
rm -rf packages/usr/share/icons/hicolor/scalable/apps/*

echo $SEPARATOR
echo "Complete!"
