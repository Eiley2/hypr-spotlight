# hypr-project

Dynamic project workspaces for Hyprland + Waybar. Create named projects on the fly, each with its own set of screens (workspaces), and switch between them instantly.

![concept](https://img.shields.io/badge/Hyprland-Waybar-blue)

## How it works

Each project gets 3 screens (workspaces). Navigate screens within a project with `SUPER+1/2/3`, and switch between projects with `SUPER+ALT+number` or through the waybar module.

```
Project "work"     → workspaces 1, 2, 3
Project "personal" → workspaces 11, 12, 13
Project "oss"      → workspaces 21, 22, 23
```

**Waybar indicator:**
```
work ● ◆ ○
 │    │ │ └─ screen 3: empty
 │    │ └─── screen 2: has windows
 │    └───── screen 1: active
 └────────── project name
```

## Requirements

- [Hyprland](https://hyprland.org/)
- [Waybar](https://github.com/Alexays/Waybar)
- [Walker](https://github.com/abenz1267/walker) (for project picker dialogs)
- `jq`
- `bash`

Works great with [Omarchy](https://omarchy.org/).

## Install

```bash
git clone https://github.com/Eiley2/hypr-project.git
cd hypr-project
bash install.sh
```

## Uninstall

```bash
cd hypr-project
bash uninstall.sh
```

## Keybindings

| Key | Action |
|-----|--------|
| `SUPER + 1/2/3` | Navigate to screen 1/2/3 within current project |
| `SUPER + SHIFT + 1/2/3` | Move window to screen within project |
| `SUPER + ALT + 1-9` | Quick switch to project by creation order |
| `SUPER + ALT + N` | Create new project (walker dialog) |
| `SUPER + ALT + P` | Switch project (walker picker) |
| `SUPER + ALT + W` | Close current project |

## Waybar interactions

| Action | Effect |
|--------|--------|
| Click | Switch project (walker picker) |
| Right-click | Create new project |
| Middle-click | Close current project |
| Scroll | Cycle through projects |

## CLI usage

```bash
hypr-project create "my project"   # Create and switch to project
hypr-project switch "my project"   # Switch to existing project
hypr-project go 2                  # Go to screen 2 of current project
hypr-project move 3                # Move window to screen 3
hypr-project switch-index 2        # Switch to 2nd project
hypr-project next                  # Next project
hypr-project prev                  # Previous project
hypr-project close                 # Close current project
hypr-project list                  # List all projects
hypr-project current               # Print current project name
```

## Configuration

Edit `~/.local/bin/hypr-project` to change:

- `SCREENS=3` — number of screens per project
- `BLOCK=10` — workspace number spacing between projects

## License

MIT
