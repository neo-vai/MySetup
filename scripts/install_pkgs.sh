#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Root privileges required. Run with sudo."
    exit 1
fi

PACMAN_PKGS=(
    git
    vim
    discord
    rofi
    zsh
)

YAY_PKGS=(
	firefox-nightly
    visual-studio-code-bin
    hyprlock
    hyprpaper
    telegram-desktop
)

if [ ${#PACMAN_PKGS[@]} -gt 0 ]; then
    echo "Installing pacman packages: ${PACMAN_PKGS[*]}"
    pacman -S --noconfirm --needed "${PACMAN_PKGS[@]}"
fi

if [ ${#YAY_PKGS[@]} -gt 0 ]; then
    echo "Installing AUR packages: ${YAY_PKGS[*]}"
    sudo -u "$SUDO_USER" yay -S --noconfirm "${YAY_PKGS[@]}"
fi

echo "Installation complete!"
