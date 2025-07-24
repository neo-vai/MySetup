#!/bin/bash

# Проверка прав суперпользователя
if [ "$(id -u)" != "0" ]; then
    echo "Этот скрипт должен запускаться с правами root." >&2
    exit 1
fi

# Проверка наличия AUR-хелпера
check_aur_helper() {
    if ! command -v paru &> /dev/null && ! command -v yay &> /dev/null; then
        echo "AUR-хелпер (paru/yay) не найден. Установите один из них."
        exit 1
    fi
}

# Определение групп пакетов с указанием источника
declare -A PACKAGE_GROUPS=(
    # Формат: ["Название группы"]="источник:пакет1 пакет2 ..."
    ["Терминальные утилиты"]="pacman:htop aur:tty-clock hollwood terminal-rain unimatrix-git"
    ["Разработка"]="pacman:neovim python filezilla aur:visual-studio-code-bin"
    ["uniporn"]="pacman:hyprlock aur:stacer-bin swww wlr-randr"
    ["Системные"]="pacman:grim slurp aur:"
    ["База"]="pacman:obsidian bitwarden aur:firefox-nightly vesktop ayugram-desktop proton-vpn-gtk-app"
)

# Функция для разделения пакетов по источникам
process_packages() {
    local pacman_pkgs=()
    local aur_pkgs=()
    
    for group in "${!PACKAGE_GROUPS[@]}"; do
        read -rp "Установить ${group}? [Y/n] " answer
        if [[ -z "$answer" || "$answer" =~ ^[YyДд] ]]; then
            echo "Добавлено: $group"
            
            # Разделение пакетов по источникам
            while read -r source_pkgs; do
                local source=${source_pkgs%%:*}
                local pkgs=${source_pkgs#*:}
                
                case $source in
                    pacman) pacman_pkgs+=($pkgs) ;;
                    aur) aur_pkgs+=($pkgs) ;;
                esac
            done < <(echo "${PACKAGE_GROUPS[$group]}" | tr ' ' '\n' | awk -F: '{print $1 ":" $2}')
        fi
    done

    # Объединение и удаление дубликатов
    PACMAN_PACKAGES=$(echo "${pacman_pkgs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
    AUR_PACKAGES=$(echo "${aur_pkgs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
}

# Функция установки AUR пакетов
install_aur() {
    local aur_helper=""
    if command -v paru &> /dev/null; then
        aur_helper="paru -S --needed --noconfirm"
    elif command -v yay &> /dev/null; then
        aur_helper="yay -S --needed --noconfirm"
    fi

    if [ -n "$aur_helper" ]; then
        echo "Установка AUR пакетов с помощью ${aur_helper%% *}..."
        sudo -u "$SUDO_USER" $aur_helper $AUR_PACKAGES
    else
        echo "Ошибка: Не найден AUR-хелпер (paru/yay)"
        exit 1
    fi
}

# Основной процесс установки
main() {
    check_aur_helper
    process_packages
    
    echo -e "\nБудут установлены пакеты:"
    echo "Официальные репозитории: $PACMAN_PACKAGES"
    echo "AUR: $AUR_PACKAGES"
    
    read -rp "Продолжить установку? [Y/n] " confirm
    if [[ ! -z "$confirm" && "$confirm" =~ ^[NnНн] ]]; then
        echo "Установка отменена."
        exit 0
    fi

    # Установка пакетов
    if [ -n "$PACMAN_PACKAGES" ]; then
        echo "Обновление базы данных pacman..."
        pacman -Sy --noconfirm
        
        echo "Установка официальных пакетов..."
        pacman -S --needed --noconfirm $PACMAN_PACKAGES
    fi

    if [ -n "$AUR_PACKAGES" ]; then
        install_aur
    fi
    
    echo -e "\nУстановка завершена!"
}

main
