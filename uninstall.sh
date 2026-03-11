#!/bin/bash
set -euo pipefail

MARKER="# >>> hypr-project >>>"
MARKER_END="# <<< hypr-project <<<"

info()  { echo -e "\033[1;34m::\033[0m $*"; }
ok()    { echo -e "\033[1;32m::\033[0m $*"; }
warn()  { echo -e "\033[1;33m::\033[0m $*"; }

# --- 1. Remove script ---
if [ -f ~/.local/bin/hypr-project ]; then
    rm ~/.local/bin/hypr-project
    ok "Removed ~/.local/bin/hypr-project"
else
    warn "Script not found, skipping"
fi

# --- 2. Remove patched sections from Hyprland bindings ---
BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"
if [ -f "$BINDINGS_FILE" ] && grep -q "$MARKER" "$BINDINGS_FILE"; then
    sed -i "/$MARKER/,/$MARKER_END/d" "$BINDINGS_FILE"
    ok "Removed hypr-project bindings from $BINDINGS_FILE"
fi

# --- 3. Remove patched sections from Waybar CSS ---
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
if [ -f "$WAYBAR_STYLE" ] && grep -q "$MARKER" "$WAYBAR_STYLE"; then
    sed -i "/$MARKER/,/$MARKER_END/d" "$WAYBAR_STYLE"
    ok "Removed hypr-project styles from $WAYBAR_STYLE"
fi

# --- 4. Waybar config (manual) ---
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
warn "Waybar config ($WAYBAR_CONFIG) needs manual cleanup:"
echo "  - Remove the \"custom/project\" module definition"
echo "  - Replace \"custom/project\" with \"hyprland/workspaces\" in modules-left"
echo "  - Or run: omarchy-refresh-waybar"

# --- 5. Optional: remove state ---
echo ""
read -rp "Remove project state (~/.cache/hypr-projects)? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm -rf ~/.cache/hypr-projects
    ok "Removed project state"
fi

echo ""
ok "hypr-project uninstalled!"
echo "Run omarchy-restart-waybar to apply changes."
