#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MARKER="# >>> hypr-project >>>"
MARKER_END="# <<< hypr-project <<<"

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

# --- 1. Install script ---
info "Installing hypr-project to ~/.local/bin/"
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/bin/hypr-project" ~/.local/bin/hypr-project
chmod +x ~/.local/bin/hypr-project
ok "Script installed"

# --- 2. Create state directory ---
mkdir -p ~/.cache/hypr-projects
touch ~/.cache/hypr-projects/projects

# --- 3. Patch Hyprland bindings ---
BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"
if [ -f "$BINDINGS_FILE" ] && grep -q "$MARKER" "$BINDINGS_FILE"; then
    warn "Hyprland bindings already patched, skipping"
else
    info "Patching $BINDINGS_FILE"
    backup "$BINDINGS_FILE"
    {
        echo ""
        echo "$MARKER"
        cat "$SCRIPT_DIR/config/hyprland-bindings.conf"
        echo "$MARKER_END"
    } >> "$BINDINGS_FILE"
    ok "Hyprland bindings patched"
fi

# --- 4. Patch Waybar config ---
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
if [ -f "$WAYBAR_CONFIG" ] && grep -q '"custom/project"' "$WAYBAR_CONFIG"; then
    warn "Waybar config already has custom/project, skipping"
else
    info "Patching $WAYBAR_CONFIG"
    backup "$WAYBAR_CONFIG"

    # Add custom/project to modules-left (replace hyprland/workspaces or prepend)
    if grep -q '"hyprland/workspaces"' "$WAYBAR_CONFIG"; then
        sed -i 's/"hyprland\/workspaces"/"custom\/project"/' "$WAYBAR_CONFIG"
        info "Replaced hyprland/workspaces with custom/project in modules-left"
    elif ! grep -q '"custom/project"' "$WAYBAR_CONFIG"; then
        # Prepend to modules-left array
        sed -i 's/"modules-left": \[/"modules-left": ["custom\/project", /' "$WAYBAR_CONFIG"
        info "Added custom/project to modules-left"
    fi

    # Inject the module definition before the last closing brace
    MODULE_JSON=$(cat "$SCRIPT_DIR/config/waybar-module.jsonc" | sed '1d;$d' | sed 's/$//')
    # Find a good insertion point: before the last "}" in the file
    # We insert after the first module definition block
    TMP=$(mktemp)
    awk -v module="$MODULE_JSON" '
        !inserted && /"modules-right"/ {
            found_right = 1
        }
        found_right && !inserted && /\]/ {
            print
            print "  },"
            # Remove leading comma handling - we add after the ] line
            inserted = 1
            next
        }
        { print }
    ' "$WAYBAR_CONFIG" > "$TMP"

    # Simpler approach: use jq-like insertion via sed
    # Insert the module definition after modules-right closing bracket
    # Actually, let's just use a Python one-liner or simple sed
    # The safest approach: insert before the closing } of the file
    if ! grep -q '"custom/project"' "$WAYBAR_CONFIG"; then
        # Remove trailing newlines and last }, insert module, re-add }
        sed -i '/^}$/d' "$WAYBAR_CONFIG"
        # Remove trailing empty lines
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$WAYBAR_CONFIG"
        # Ensure last line has a comma
        sed -i '$ s/}$/},/' "$WAYBAR_CONFIG"
        {
            cat "$SCRIPT_DIR/config/waybar-module.jsonc" | sed '1d;$d'
            echo "}"
        } >> "$WAYBAR_CONFIG"
    fi
    rm -f "$TMP"
    ok "Waybar module definition added"
fi

# --- 5. Patch Waybar CSS ---
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
if [ -f "$WAYBAR_STYLE" ] && grep -q '#custom-project' "$WAYBAR_STYLE"; then
    warn "Waybar CSS already patched, skipping"
else
    info "Patching $WAYBAR_STYLE"
    backup "$WAYBAR_STYLE"
    {
        echo ""
        echo "$MARKER"
        cat "$SCRIPT_DIR/config/waybar-style.css"
        echo "$MARKER_END"
    } >> "$WAYBAR_STYLE"
    ok "Waybar CSS patched"
fi

# --- 6. Restart waybar ---
if command -v omarchy-restart-waybar &>/dev/null; then
    info "Restarting waybar..."
    omarchy-restart-waybar
elif command -v killall &>/dev/null; then
    killall waybar 2>/dev/null; waybar &disown
fi

echo ""
ok "hypr-project installed!"
echo ""
echo "  Keybindings:"
echo "    SUPER + 1/2/3         Navigate screens within project"
echo "    SUPER + SHIFT + 1/2/3 Move window to screen"
echo "    SUPER + ALT + 1-9     Switch to project by index"
echo "    SUPER + ALT + N       New project"
echo "    SUPER + ALT + P       Switch project (picker)"
echo "    SUPER + ALT + W       Close project"
echo ""
echo "  Waybar (click the project indicator):"
echo "    Click        Switch project"
echo "    Right-click  New project"
echo "    Middle-click Close project"
echo "    Scroll       Cycle projects"
