#!/bin/bash
set -euo pipefail

MARKER="# >>> hypr-spotlight >>>"
MARKER_END="# <<< hypr-spotlight <<<"

info()  { echo -e "\033[1;34m::\033[0m $*"; }
ok()    { echo -e "\033[1;32m::\033[0m $*"; }
warn()  { echo -e "\033[1;33m::\033[0m $*"; }

# --- 1. Remove scripts ---
if [ -f ~/.local/bin/hypr-spotlight ]; then
    rm ~/.local/bin/hypr-spotlight
    ok "Removed ~/.local/bin/hypr-spotlight"
else
    warn "Script not found, skipping"
fi

if [ -f ~/.local/bin/hypr-spotlight-menu-json ]; then
    rm ~/.local/bin/hypr-spotlight-menu-json
    ok "Removed ~/.local/bin/hypr-spotlight-menu-json"
else
    warn "Helper script not found, skipping"
fi

if [ -f ~/.config/elephant/menus/hypr-spotlight.lua ]; then
    rm ~/.config/elephant/menus/hypr-spotlight.lua
    ok "Removed ~/.config/elephant/menus/hypr-spotlight.lua"
else
    warn "Elephant menu not found, skipping"
fi

# --- 2. Remove patched sections from Hyprland bindings ---
BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"
if [ -f "$BINDINGS_FILE" ] && grep -q "$MARKER" "$BINDINGS_FILE"; then
    sed -i "/$MARKER/,/$MARKER_END/d" "$BINDINGS_FILE"
    ok "Removed hypr-spotlight bindings from $BINDINGS_FILE"
fi

# --- 3. Remove patched sections from Waybar CSS ---
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
if [ -f "$WAYBAR_STYLE" ] && grep -q "$MARKER" "$WAYBAR_STYLE"; then
    sed -i "/$MARKER/,/$MARKER_END/d" "$WAYBAR_STYLE"
    ok "Removed hypr-spotlight styles from $WAYBAR_STYLE"
fi

# --- 4. Waybar config (manual) ---
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
warn "Waybar config ($WAYBAR_CONFIG) needs manual cleanup:"
echo "  - Remove the \"custom/project\" module definition"
echo "  - Replace \"custom/project\" with \"hyprland/workspaces\" in modules-left"
echo "  - Or run: omarchy-refresh-waybar"

# --- 5. Optional: remove state ---
echo ""
read -rp "Remove spotlight state (~/.cache/hypr-spotlight)? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm -rf ~/.cache/hypr-spotlight
    ok "Removed spotlight state"
fi

echo ""
ok "hypr-spotlight uninstalled!"
echo "Run omarchy-restart-walker to unload the spotlight menu."
echo "Run omarchy-restart-waybar to apply changes."
