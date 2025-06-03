#!/bin/bash

# Пути
WALLPAPERS_DIR="$(dirname "$0")/../Wallpapers"
CURRENT_WALLPAPER="$WALLPAPERS_DIR/.current_wallpaper.jpg"

# Проверяем существование папки с обоями
if [ ! -d "$WALLPAPERS_DIR" ]; then
    echo "Wallpapers directory not found: $WALLPAPERS_DIR" >&2
    exit 1
fi

# Находим случайные обои (рекурсивно, включая подпапки)
random_wallpaper=$(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n1)

# Проверяем наличие обоев
if [ -z "$random_wallpaper" ]; then
    echo "No wallpapers found in $WALLPAPERS_DIR" >&2
    exit 1
fi

# Обновляем текущие обои (только если выбранный файл отличается)
if [ "$random_wallpaper" != "$CURRENT_WALLPAPER" ]; then
    cp -f "$random_wallpaper" "$CURRENT_WALLPAPER"
fi

# Применяем обои на все мониторы через hyprpaper IPC
hyprctl hyprpaper reload ",$CURRENT_WALLPAPER"
