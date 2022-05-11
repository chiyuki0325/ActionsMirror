#!/bin/bash

if [[ ! -d bilibili-bin ]];then
echo "Cloning AUR git repository"
git clone ssh://aur@aur.archlinux.org/bilibili-bin.git
fi

. ./bilibili-bin/PKGBUILD # include PKGBUILD file

echo "Current version is ${pkgver}"
echo "Current SHA-256 checksum is ${sha256sums[0]}"
echo "Checking for updates"

VERSION=`curl -s 'https://api.bilibili.com/x/elec-frontend/update/latest.yml' | grep 'version:' | head -1 | sed '$s/.$//' | sed 's/version: //'`

echo "Latest version is ${VERSION}"

if [[ "${VERSION}" = "${pkgver}" ]];then
echo "AUR's is latest version, exiting"
exit
else
echo "Updating PKGBUILD to ${VERSION}"

echo "Downloading Bilibili desktop ${VERSION}"
wget -q "https://dl.hdslb.com/mobile/fixed/bili_win/bili_win-install.exe"

echo "Replacing \$pkgver"
sed -i "s/pkgver=${pkgver}/pkgver=${VERSION}/" ./bilibili-bin/PKGBUILD

echo "Replacing \${sha256sums[0]}"
sed -i "s/sha256sums=('${sha256sums[0]}'/sha256sums=('`sha256sum bili_win-install.exe | awk -F" " '{print $1}'`'/" ./bilibili-bin/PKGBUILD

pushd bilibili-bin
git add .
git commit -m "Updated by GitHub Actions on `date '+%Y/%m/%d %s'`"
git push
popd

echo "Removing files"
rm bili_win-install.exe

echo "Completed!"
fi
