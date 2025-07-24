#!/bin/bash

# Пути к папкам (рядом со скриптом)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
INPUT_DIR="$SCRIPT_DIR/input"
OUTPUT_DIR="$SCRIPT_DIR/output"

# Создаём папки, если их нет
mkdir -p "$INPUT_DIR" "$OUTPUT_DIR"

# Проверяем ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "Ошибка: ffmpeg не установлен. Установите:"
    echo "sudo pacman -S ffmpeg"
    exit 1
fi

# Счётчик файлов
converted=0
errors=0

echo "=== Начинаем конвертацию MP4 в DNxHR HQ ==="

# Обрабатываем все MP4 в input
for input_file in "$INPUT_DIR"/*.mp4; do
    if [ -f "$input_file" ]; then
        filename=$(basename -- "$input_file")
        output_file="$OUTPUT_DIR/${filename%.mp4}_converted.mov"
        
        echo -n "Конвертируем: $filename -> $(basename "$output_file")..."
        
        # Конвертация
        ffmpeg -i "$input_file" \
               -c:v dnxhd -profile:v dnxhr_hq \
               -pix_fmt yuv422p \
               -c:a pcm_s16le \
               -y "$output_file" &> /dev/null
        
        if [ $? -eq 0 ]; then
            echo "УСПЕХ"
            ((converted++))
        else
            echo "ОШИБКА"
            ((errors++))
            rm -f "$output_file" 2>/dev/null
        fi
    fi
done

echo "=== Готово ==="
echo "Успешно: $converted"
echo "Ошибки: $errors"

# Открываем папку output (если есть успешные файлы)
if [ $converted -gt 0 ]; then
    xdg-open "$OUTPUT_DIR" &> /dev/null || echo "Откройте папку output вручную: $OUTPUT_DIR"
fi
