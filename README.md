# VSCode ARM Builder

This contains bash script and docker files that automatically build Visual Studio Code on ARM.
I'm not happy with the `arm` builds from headmelted and vscodium because they don't fix bug related to `vscode-sqlite3` module. Everytime you open vscode, the annoying welcome pages from vscode and its extension such as: `gitlens` always appear (you can check it yourself). So I decided to make my own build.

## Download
1. Download the [latest release](https://github.com/tuanpham-dev/vscode-arm-builder/releases/latest).
2. Double-click the downloaded `.deb` file, or run `sudo dpkg -i {downloaded .deb}`.

## Build from source
Clone this repo and change directory to repo folder.

### Build locally
1. Run `./build.sh`
2. Wait for complete (1 hour on my Raspberry Pi 4) and the `.deb` file is in `build` directory.

### Build using Docker
1. Run `docker-compose up --build` or `docker-compose run vscode-arm` or `docker-compose run vscode-arm64`
2. Wait for complete (few hours on my i7-9750h laptop) and the `.deb` files are in `build` directory.
