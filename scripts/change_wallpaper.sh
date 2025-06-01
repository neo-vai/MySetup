#!/bin/sh

WALLPAPERS_DIR="$(dirname "$0")/../Wallpapers"

# Находим все изображения (jpg, jpeg, png) в папке и подпапках
wallpapers=$(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \))

# Проверяем наличие обоев
if [ -z "$wallpapers" ]; then
    echo "No wallpapers found in $WALLPAPERS_DIR" >&2
    exit 1
fi

# Выбираем случайные обои
random_wallpaper=$(echo "$wallpapers" | shuf -n1)

# Убиваем предыдущий swaybg и устанавливаем новые обои
pkill swaybg
swaybg -i "$random_wallpaper" -m fill &
