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
BILI_HASH=`sha256sum bili_win-install.exe | awk -F" " '{print $1}'`
echo "Latest version is ${VERSION}"

if [[ "${VERSION}" = "${pkgver}" ]];then
  if [[ "${sha256sums[0]}" = "${BILI_HASH}" ]];then
  echo "AUR's is latest version, exiting"
  exit
  fi
fi
echo "Updating PKGBUILD to ${VERSION} $BILI_HASH"

echo "Downloading Bilibili desktop ${VERSION}"
wget -q "https://dl.hdslb.com/mobile/fixed/bili_win/bili_win-install.exe"

echo "Replacing \$pkgver"
sed -i "s/pkgver=${pkgver}/pkgver=${VERSION}/" ./bilibili-bin/PKGBUILD

echo "Replacing \${sha256sums[0]}"
sed -i "s/sha256sums=('${sha256sums[0]}'/sha256sums=('$BILI_HASH'/" ./bilibili-bin/PKGBUILD

cd bilibili-bin
ls
git config --global user.email "yidaozhan_ya@outlook.com"
git config --global user.name "YidaozhanYa via GitHub Actions"
git add .
git commit -m "Updated by GitHub Actions on `date '+%Y/%m/%d %s'`"
git push

echo "Removing files"
rm ../bili_win-install.exe

echo "Completed!"
fi
