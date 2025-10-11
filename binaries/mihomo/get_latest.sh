#!/usr/bin/env bash

cd "$(dirname "$0")"

OWNER="MetaCubeX"
REPO="mihomo"
BIN_NAME="clash"
LATEST_URL="https://github.com/${OWNER}/${REPO}/releases/latest"
LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' "$LATEST_URL")
LATEST_VERSION=$(echo "$LATEST_RELEASE" | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/; s/ //g; s/app\///g')
echo "latest $BIN_NAME version is $LATEST_VERSION"

# curl -s 'https://api.github.com/repos/MetaCubeX/mihomo/releases/latest'  | grep -E 'digest|browser_download_url'

extract_archive() {
  tar -xvf "$1" "$2"
}

if [ -d "${LATEST_VERSION}" ];then
	echo "already have lateset!"
	exit
fi

mkdir -p "${LATEST_VERSION}"

for file in armv5 armv7 arm64;do
  echo "download $REPO $file"
  # wget --no-check-certificate "https://github.com/${OWNER}/${REPO}/releases/download/${LATEST_VERSION}/${REPO}-linux-${file}-${LATEST_VERSION}.gz" -O "${LATEST_VERSION}/clash-fancyss_$file.gz"
done


