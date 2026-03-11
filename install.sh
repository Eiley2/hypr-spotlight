#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MARKER="# >>> hypr-spotlight >>>"
MARKER_END="# <<< hypr-spotlight <<<"
CSS_MARKER="/* >>> hypr-spotlight >>> */"
CSS_MARKER_END="/* <<< hypr-spotlight <<< */"

info()  { echo -e "\033[1;34m::\033[0m $*"; }
ok()    { echo -e "\033[1;32m::\033[0m $*"; }
warn()  { echo -e "\033[1;33m::\033[0m $*"; }
error() { echo -e "\033[1;31m::\033[0m $*"; exit 1; }

backup() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.bak.$(date +%s)"
        info "Backed up $file"
    fi
}

replace_marked_block() {
    local file="$1"
    local content_file="$2"
    local marker_start="${3:-$MARKER}"
    local marker_end="${4:-$MARKER_END}"

    mkdir -p "$(dirname "$file")"
    touch "$file"
    backup "$file"
    sed -i "/$marker_start/,/$marker_end/d" "$file"
    {
        echo ""
        echo "$marker_start"
        cat "$content_file"
        echo "$marker_end"
    } >> "$file"
}

cleanup_legacy_bindings() {
    local file="$1"

    python3 - "$file" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()
pattern = re.compile(
    r"\n# Project workspaces: override default SUPER\+1-9 workspace bindings\n"
    r"(?:.*\n)*?(?=\n# >>> hypr-spotlight >>>|\Z)"
)

def should_remove(block: str) -> bool:
    return "hypr-project" in block

new_text = pattern.sub(lambda match: "\n" if should_remove(match.group(0)) else match.group(0), text)
if new_text != text:
    path.write_text(new_text)
PY
}

sync_waybar_project_module() {
    local file="$1"
    local module_file="$2"

    python3 - "$file" "$module_file" <<'PY'
from pathlib import Path
import json
import sys

config_path = Path(sys.argv[1])
module_path = Path(sys.argv[2])

data = json.loads(config_path.read_text())
module_data = json.loads(module_path.read_text())

modules_left = data.setdefault("modules-left", [])
if "custom/project" not in modules_left:
    modules_left.insert(0, "custom/project")

data["custom/project"] = module_data["custom/project"]
config_path.write_text(json.dumps(data, indent=2) + "\n")
PY
}

# --- 1. Install scripts ---
info "Installing hypr-spotlight to ~/.local/bin/"
mkdir -p ~/.local/bin
rm -f ~/.local/bin/hypr-project ~/.local/bin/hypr-project-menu-json
cp "$SCRIPT_DIR/bin/hypr-spotlight" ~/.local/bin/hypr-spotlight
cp "$SCRIPT_DIR/bin/hypr-spotlight-menu-json" ~/.local/bin/hypr-spotlight-menu-json
chmod +x ~/.local/bin/hypr-spotlight
chmod +x ~/.local/bin/hypr-spotlight-menu-json
ok "Scripts installed"

# --- 2. Install Elephant menu ---
info "Installing Walker/Elephant spotlight menu"
mkdir -p ~/.config/elephant/menus
rm -f ~/.config/elephant/menus/hyprspotlight.lua
cp "$SCRIPT_DIR/config/elephant/menus/hypr-spotlight.lua" ~/.config/elephant/menus/hypr-spotlight.lua
ok "Elephant menu installed"

# --- 3. Create state directory ---
mkdir -p ~/.cache/hypr-spotlight
touch \
    ~/.cache/hypr-spotlight/projects \
    ~/.cache/hypr-spotlight/window-names \
    ~/.cache/hypr-spotlight/project-icons \
    ~/.cache/hypr-spotlight/usage.tsv

# --- 4. Patch Hyprland bindings ---
BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"
info "Installing bindings into $BINDINGS_FILE"
replace_marked_block "$BINDINGS_FILE" "$SCRIPT_DIR/config/hyprland-bindings.conf"
cleanup_legacy_bindings "$BINDINGS_FILE"
ok "Hyprland bindings installed"

# --- 5. Patch Waybar config ---
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
info "Syncing Waybar config in $WAYBAR_CONFIG"
backup "$WAYBAR_CONFIG"
sync_waybar_project_module "$WAYBAR_CONFIG" "$SCRIPT_DIR/config/waybar-module.jsonc"
ok "Waybar config synced"

# --- 6. Patch Waybar CSS ---
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
info "Installing Waybar styles into $WAYBAR_STYLE"
sed -i '/# >>> hypr-spotlight >>>/,/# <<< hypr-spotlight <<</d' "$WAYBAR_STYLE"
replace_marked_block "$WAYBAR_STYLE" "$SCRIPT_DIR/config/waybar-style.css" "$CSS_MARKER" "$CSS_MARKER_END"
ok "Waybar CSS installed"

# --- 7. Restart walker/elephant ---
if command -v omarchy-restart-walker &>/dev/null; then
    info "Restarting walker/elephant..."
    omarchy-restart-walker
fi

# --- 8. Reload Hyprland ---
if command -v hyprctl &>/dev/null; then
    info "Reloading Hyprland..."
    hyprctl reload > /dev/null 2>&1 || true
fi

# --- 9. Restart waybar ---
if command -v omarchy-restart-waybar &>/dev/null; then
    info "Restarting waybar..."
    omarchy-restart-waybar
elif command -v killall &>/dev/null; then
    killall waybar 2>/dev/null; waybar &disown
fi

echo ""
ok "hypr-spotlight installed!"
echo ""
echo "  Keybindings:"
echo "    SUPER + 1/2/3         Navigate screens within project"
echo "    SUPER + SHIFT + 1/2/3 Move window to screen"
echo "    SUPER + SHIFT + R     Rename current window"
echo "    SUPER + SPACE         Open spotlight"
echo "    SUPER + ALT + 1-9     Switch to project by index"
echo "    SUPER + ALT + N       New project"
echo "    SUPER + ALT + P       Switch project (picker)"
echo "    SUPER + ALT + W       Close project"
echo "    SUPER + ALT + R       Rename current project"
echo ""
echo "  Waybar (click the project indicator):"
echo "    Click        Switch project"
echo "    Right-click  New project"
echo "    Middle-click Close project"
echo "    Scroll       Cycle projects"
