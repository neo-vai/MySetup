#!/bin/bash

# Пути
SCRIPT_DIR=$(dirname "$(realpath "$0")")
WALLPAPERS_DIR="$SCRIPT_DIR/../Wallpapers"
INDEX_FILE="$WALLPAPERS_DIR/.current_index"
CURRENT_WALL="$WALLPAPERS_DIR/.current_wallpaper.jpg"  # Скрытый файл в директории скрипта

# Параметры анимации
TRANSITION_TYPE="any"
TRANSITION_DURATION=0.4
TRANSITION_FPS=90

# Проверка директории
[ ! -d "$WALLPAPERS_DIR" ] && echo "Directory missing: $WALLPAPERS_DIR" >&2 && exit 1

# Получение списка обоев
mapfile -d '' wallpapers < <(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 | sort -z)
wallpapers_count=${#wallpapers[@]}
[ $wallpapers_count -eq 0 ] && echo "No wallpapers found" >&2 && exit 1

current_index=0
if [ -f "$INDEX_FILE" ]; then
    current_index=$(<"$INDEX_FILE")
    [[ $current_index -ge $wallpapers_count ]] && current_index=0
fi
selected_wallpaper="${wallpapers[$current_index]}"
echo $(( (current_index + 1) % wallpapers_count )) > "$INDEX_FILE"

# Проверка демона
if ! swww query >/dev/null 2>&1; then
    swww-daemon --format xrgb >/tmp/swww.log 2>&1 &
    sleep 0.3
fi

# Позиция курсора
cursor_pos=$(hyprctl cursorpos | awk '{print $4}')
[ -z "$cursor_pos" ] && cursor_pos="center"

# Применение обоев
swww img "$selected_wallpaper" \
    --transition-type "$TRANSITION_TYPE" \
    --transition-duration $TRANSITION_DURATION \
    --transition-fps $TRANSITION_FPS \
    --transition-pos "$cursor_pos"

# Сохранение копии для hyprlock
cp "$selected_wallpaper" "$CURRENT_WALL"

# Уведомление
# notify-send -i "$selected_wallpaper" "Обои изменены" "$(basename "$selected_wallpaper")"
