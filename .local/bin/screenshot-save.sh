#!/bin/bash
# screenshot-save.sh

# Ask for filename via fuzzel
FILENAME=$(fuzzel --dmenu --prompt="Screenshot name: " --placeholder="my-screenshot" < /dev/null)

# If user cancelled (empty or dismissed), just copy to clipboard instead
if [ -z "$FILENAME" ]; then
    ~/.local/bin/grimshot/grimshot copy area
    exit 0
fi

# Add .png if no extension given
[[ "$FILENAME" != *.* ]] && FILENAME="${FILENAME}.png"

# Save to ~/Pictures/Screenshots/ (adjust path as needed)
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

~/.local/bin/grimshot/grimshot save area "$SAVE_DIR/$FILENAME"
