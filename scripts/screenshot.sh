hyprctl keyword animations:enabled false
coords=$(slurp)
grim -g "$coords" - | wl-copy
hyprctl keyword animations:enabled true
