#!/usr/bin/env bash

expand_home() {
    echo "${1//\$HOME/$HOME}"
}

BIN_PATH="$(expand_home $(jq -r '.awww.binPath' ./manifest.json))"
CACHE_PATH="$(expand_home $(jq -r '.awww.cachePath' ./manifest.json))"
DAEMON_BIN_PATH="$(expand_home $(jq -r '.awww.daemonBinPath' ./manifest.json))"
G_DRIVE_FILE_ID=$(jq -r '.awww.GDriveFileId' ./manifest.json)
WALLPAPER_PATH="$(expand_home $(jq -r '.awww.wallpaperPath' ./manifest.json))"

install() {
    echo "Cloning awww"
    git clone https://codeberg.org/LGFae/awww.git /tmp/awww

    pushd /tmp/awww
    echo "building..."
    cargo build --release
    echo "$BIN_PATH binpath"
    mv ./target/release/awww $BIN_PATH
    mv ./target/release/awww-daemon $DAEMON_BIN_PATH

    echo "generating man pages..."
    chmod u+x ./doc/gen.sh
    ./doc/gen.sh
    popd

}

run_daemon() {
    $DAEMON_BIN_PATH &
}

download_and_set_wallpaper() {
    if [ ! -e "$WALLPAPER_PATH" ]; then
        echo "$WALLPAPER_PATH doesn't exist"
        echo "Downloading wallpaper"
        curl "https://drive.usercontent.google.com/download?id=$G_DRIVE_FILE_ID&export=download&confirm" -o "$WALLPAPER_PATH"
        echo "Wallpaper downloaded"
    else
        echo "Wallpaper exists"
    fi

    if [ ! -d "$CACHE_PATH" ]; then
        mkdir $CACHE_PATH
    fi

    $BIN_PATH img $WALLPAPER_PATH
}

if command -v awww &>/dev/null && command -v awww-daemon &>/dev/null; then
    echo "awww is installed"
    download_and_set_wallpaper
else
    echo "awww not installed"
    install
    run_daemon
    download_and_set_wallpaper
fi
