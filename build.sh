#!/bin/bash
set -e

ARCH=$(dpkg --print-architecture)
if [[ "$ARCH" != *"arm"* ]]; then
  echo "CPU architecture not supported. This script is for arm only"
  exit 1
fi

if [ "$ARCH" == "armhf" ]; then
  BUILD_ARCH="arm"
else
  BUILD_ARCH="$ARCH"
fi

NVM_DIR=~/.nvm
NODE_VERSION=12
CODE_DIR=code
BUILD_DIR=build

echo "Installing prerequisites"
sudo apt-get update && sudo apt-get -y install python git curl build-essential pkg-config libx11-dev libxkbfile-dev libsecret-1-dev rpm fakeroot

echo "Installing NVM"
mkdir -p $NVM_DIR
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
source $NVM_DIR/nvm.sh

echo "Installing Nodejs"
nvm install $NODE_VERSION
nvm alias default $NODE_VERSION
nvm use default

echo "Installing npm dependencies"
npm install -g yarn gulp gulp-watch

echo "Download official code linux and extracting resources"
curl -L https://go.microsoft.com/fwlink/?LinkID=620884 > vscode-official.tar.gz
tar --strip-components=1 -xf vscode-official.tar.gz VSCode-linux-x64/resources/app/resources/linux/code.png VSCode-linux-x64/resources/app/product.json

echo "Retrieving latest Visual Studio Code sources into [$CODE_DIR]"
if [[ ! -d "$CODE_DIR" ]]; then
  git clone "https://github.com/Microsoft/vscode.git" $CODE_DIR
fi

echo "Entering code directory"
cd $CODE_DIR

echo "Checking out latest code version (tag)"
git fetch --tags
git checkout $(git describe --tags `git rev-list --tags --max-count=1`)

echo "Applying patches
cp -rv ../resources/app/* .
sed -i 's/.*darwinCredits.*//' product.json
sed -i 's/.*electronRepository.*//' product.json
sed -i 's/max_old_space_size=[^\"]*/max_old_space_size=16000/g' package.json

echo "Installing node modules"
yarn --frozen-lockfile
yarn postinstall

echo "Patching vscode-sqlite3 module"
yarn add -D electron-rebuild
sed -i -z 's/,\n[^\n]*arm[^\n]*//' node_modules/vscode-sqlite3/binding.gyp
sed -i "s/Release\/sqlite'/Release\/sqlite.node'/" node_modules/vscode-sqlite3/lib/sqlite3.js
npx electron-rebuild -f -w vscode-sqlite3

echo "Compiling vscode"
yarn gulp compile-build

echo "Compiling extensions"
yarn gulp compile-extensions-build

echo "Minifying vscode"
yarn gulp minify-vscode
yarn gulp minify-vscode-web
yarn gulp vscode-linux-$BUILD_ARCH-min-ci

echo "Creating .deb package"
yarn gulp vscode-linux-$BUILD_ARCH-build-deb

cd ..
cp -v $CODE_DIR/.build/linux/deb/$ARCH/deb/*.deb $BUILD_DIR/

echo "Cleaning..."
rm -r VSCode-linux*
rm -r resources
rm vscode-official.tar.gz
# rm -r $CODE_DIR
