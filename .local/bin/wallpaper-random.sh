#!/usr/bin/env fish
set WALLPAPER_DIR (test -n "$WALLPAPER_DIR"; and echo $WALLPAPER_DIR; or echo "$HOME/wallpapers")
set pic (find $WALLPAPER_DIR -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.webp' \) | shuf -n1)
test -z "$pic"; and exit 1
exec awww img $pic --transition-type fade --transition-duration 1
