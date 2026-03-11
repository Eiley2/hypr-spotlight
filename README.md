# hypr-spotlight

`hypr-spotlight` is a project-aware workspace and spotlight workflow for Hyprland.

It lets you:

- group workspaces into named projects
- jump between screens inside the current project with number keys
- switch projects quickly
- assign custom labels to important windows
- set small icons for projects
- run window actions and move windows between projects from spotlight
- rank windows, projects, and apps by usage over time
- see the active project in Waybar
- open a native Walker/Elephant spotlight for windows, apps, projects, and actions

## How It Works

Each project gets a block of workspaces.

With the default settings:

```text
project 1 -> workspaces 1..10
project 2 -> workspaces 11..20
project 3 -> workspaces 21..30
```

Inside a project:

- `SUPER + 1/2/3` goes to screens inside that project
- `SUPER + SHIFT + 1/2/3` moves the focused window inside that project
- `SUPER + SPACE` opens the spotlight

The spotlight is native Walker/Elephant, so it shows real app icons and opens windows, apps, projects, and actions from one place.

## Requirements

- Hyprland
- Waybar
- Walker
- Elephant
- `bash`
- `jq`
- `python3`

## Install

```bash
git clone https://github.com/Eiley2/hypr-spotlight.git
cd hypr-spotlight
bash install.sh
```

The installer will:

- install `hypr-spotlight` and `hypr-spotlight-menu-json` into `~/.local/bin`
- install the Elephant menu definition
- patch Hyprland bindings
- patch Waybar config and styles
- restart Walker/Elephant and Waybar when possible

## Uninstall

```bash
cd hypr-spotlight
bash uninstall.sh
```

The uninstaller will:

- remove the installed binaries
- remove the Elephant menu
- remove the Hyprland and Waybar sections added by the installer
- optionally remove runtime state from `~/.cache/hypr-spotlight`

## Keybindings

| Key | Action |
| --- | --- |
| `SUPER + 1/2/3` | Go to screen 1/2/3 in the current project |
| `SUPER + SHIFT + 1/2/3` | Move the focused window to screen 1/2/3 |
| `SUPER + SHIFT + R` | Rename current window |
| `SUPER + SPACE` | Open spotlight |
| `SUPER + ALT + 1-9` | Switch to project by index |
| `SUPER + ALT + N` | Create project |
| `SUPER + ALT + P` | Switch project |
| `SUPER + ALT + W` | Close project |
| `SUPER + ALT + R` | Rename current project |

## License

MIT. See [LICENSE](LICENSE).
