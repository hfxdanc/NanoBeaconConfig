#!/bin/sh
rm -rf ./.flatpak-builder/ ./build-dir/

DATE=$(date +%Y-%m-%d)
DROPBOX_DL=$(curl --silent https://inplay-tech.com/nanobeacon-config-tool | awk '/https:\/\/www.dropbox.com.*nano_beacon_tools_linux/ {split($0,a,/".*"/,s); gsub(/"/, "", s[1]); printf("%s", gensub(/amp;/, "", "g", s[1]))}')
COPYRIGHT=$(curl --silent https://inplay-tech.com/nanobeacon-config-tool | LANG=C tr -d '\200-\377' | awk '/>Copyright / {split($0,a,/>.*</,s); printf("%s\n", gensub(/[<>]*/,"","g",s[1]))}')
SCREENSHOT=$(curl --silent https://inplay-tech.com/in100 | awk '/https:\/\/images.squarespace.*\/GUI.jpg/ {split($0,a,/ src=".*GUI.jpg"/,s); gsub(/"/,"",s[1]); printf("%s", gensub(/ src=/, "",1,s[1]))}')
ICON_DL=$(curl --silent https://inplay-tech.com/in100 | awk '/https:\/\/images.squarespace.*\/NanoBeacon\+Logo1.png/ {split($0,a,/ src=".*\/NanoBeacon\+Logo1.png"/,s); gsub(/"/,"",s[1]); printf("%s", gensub(/ src=/,"",1,s[1]))}')

if [ -z "${DROPBOX_DL}" ] || [ -z "${ICON_DL}" ]; then
    echo 2>&1 "Error locating NanoBeaconConfigTool download files"
    exit
fi

VERSION=$(echo "${DROPBOX_DL}" | sed 's/^.*nano_beacon_tools_linux_v\([0-9\.]*\).*$/\1/')
[ -z "${VERSION}" ] && VERSION="0.0"

cat <<- %E%O%T% >./io.github.hfxdanc.NanoBeaconConfigTool.appdata.xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- ${COPYRIGHT} -->
<component type="desktop-application">
  <id>io.github.hfxdanc.NanoBeaconConfigTool</id>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>LicenseRef-proprietary</project_license>
  <name>NanoBeaconConfigTool</name>
  <summary>NanoBeacon Config Tool</summary>
  <developer id="com.inplay-tech">
    <name>InPlay Inc.</name>
  </developer>
  <update_contact>hfxdanc_AT_gmail.com</update_contact>

  <description>
    <p>This is a build of the InPlay Inc. NanoBeaconConfigTool for Linux packaged as a Flatpak.</p>
    <p><em>NOTE: This wrapper is not verified by, affiliated with, sponsored or supported by InPlay Inc. in any way.</em></p>
  </description>

  <launchable type="desktop-id">io.github.hfxdanc.NanoBeaconConfigTool.desktop</launchable>
  <provides>
    <id>NanoBeaconConfigTool.desktop</id>
  </provides>

  <url type="homepage">https://inplay-tech.com/nanobeacon-config-tool</url>
  <url type="contact">https://inplay-tech.com/contact</url>
  <url type="vcs-browser">https://github.com/NanoBeacon/config-files</url>
  <url type="vcs-browser">https://github.com/hfxdanc/NanoBeaconConfig</url>

  <screenshots>
    <screenshot type="default">
      <caption xml:lang="en">NanoBeaconConfigTool opening screencap</caption>
      <image xml:lang="en">${SCREENSHOT}</image>
    </screenshot>
  </screenshots>

  <releases>
    <release version="$VERSION" date="$DATE" />
  </releases>

  <branding>
    <color type="primary" scheme_preference="light">#ff00ff</color>
    <color type="primary" scheme_preference="dark">#993d3d</color>
  </branding>

  <content_rating type="oars-1.1" />

  <recommends>
    <control>keyboard</control>
    <control>pointing</control>
    <display_length compare="ge">768</display_length>
  </recommends>

  <custom>
    <value key="flathub::manifest">https://github.com/hfxdanc/NanoBeaconConfig/blob/main/org.flatpak.NanoBeaconConfigTool.yml</value>
  </custom>
</component>
%E%O%T%

[ -d ".downloads" ] || mkdir .downloads
if [ ! -s .downloads/nano_beacon_tools_linux.tar.gz ]; then
    curl --silent --location --output .downloads/nano_beacon_tools_linux.tar.gz "${DROPBOX_DL}"
fi
SHA256=$(sha256sum .downloads/nano_beacon_tools_linux.tar.gz | awk '{printf("%s", $1)}')
SIZE=$(find .downloads -name nano_beacon_tools_linux.tar.gz -printf "%s")

if [ -z "${SHA256}" ] || [ -z "${SIZE}" ]; then
    echo 2>&1 "Error: Problem with the NanoBeacon Config Tool installer file"
    exit 1
fi

if [ ! -s NanoBeaconLogo256.png ]; then
    curl --silent --location --output .downloads/NanoBeacon+Logo1.png "${ICON_DL}"
    magick .downloads/NanoBeacon+Logo1.png -resize 256x256\< -gravity center -extent 256x256 NanoBeaconLogo256.png
fi

cat io.github.hfxdanc.NanoBeaconConfigTool.yml.in > io.github.hfxdanc.NanoBeaconConfigTool.yml
cat << %E%O%T% >> io.github.hfxdanc.NanoBeaconConfigTool.yml
      - type: extra-data
        filename: nano_beacon_tools_linux.tar.gz
        only-arches:
          - x86_64
        url: ${DROPBOX_DL}
        sha256: ${SHA256}
        size: ${SIZE}
%E%O%T%

flatpak-builder --default-branch=stable \
    --verbose \
    --force-clean \
    --install-deps-from=flathub \
    --install \
    --user \
    ./build-dir ./io.github.hfxdanc.NanoBeaconConfigTool.yml

# vi: set noexpandtab:wrap:
