#!/bin/bash

release_path="build/linux/x64/release"

# download appimage-builder
if [ ! -f appimage-builder ]; then
    wget -O appimage-builder https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.1.0/appimage-builder-1.1.0-x86_64.AppImage
    chmod +x appimage-builder
fi

# build AppImage
if [[ ! -d "$release_path/bundle" ]]; then
    echo "Release directory not found. Please build the project first."
    exit 1
fi

mkdir -p AppDir
rm -rf AppDir/*
cp -r $release_path/bundle/* AppDir/

# 复制SVG图标
mkdir -p AppDir/usr/share/icons/hicolor/scalable/apps/
cp assets/sk-chos-tool.svg AppDir/usr/share/icons/hicolor/scalable/apps/com.honjow.sk-chos-tool.svg

# 复制各种尺寸的PNG图标
for size in 16 32 64 128 256; do
    mkdir -p AppDir/usr/share/icons/hicolor/${size}x${size}/apps/
    cp assets/sk-chos-tool-${size}.png AppDir/usr/share/icons/hicolor/${size}x${size}/apps/com.honjow.sk-chos-tool.png
done

# AppImage自身的图标
cp assets/sk-chos-tool.svg AppDir/com.honjow.sk-chos-tool.svg
cp assets/sk-chos-tool-256.png AppDir/.DirIcon

mkdir -p AppDir/usr/share/applications/
cp linux/assets/com.honjow.sk-chos-tool.desktop AppDir/usr/share/applications/

./appimage-builder --skip-tests --recipe linux/assets/AppImageBuilder.yml