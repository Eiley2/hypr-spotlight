# hypr-spotlight

Native project-aware spotlight workflow for Hyprland.

`hypr-spotlight` turns groups of workspaces into named projects, exposes the active project in Waybar, and adds a fast Walker/Elephant spotlight that can:

- jump to any tracked window across projects
- open a new instance of any installed app, even if it is already running
- switch projects directly
- run project-oriented actions such as create, rename, or screen management

This repository is intended to be installable, auditable, and maintainable as a standalone OSS project.

## Features

- Named projects backed by deterministic workspace ranges.
- Multi-monitor project activation with monitor-aware workspace switching.
- Native Walker/Elephant spotlight with real application icons.
- Waybar module with click, scroll, and tooltip interactions.
- Window naming support for stable, human-readable spotlight entries.
- Shell-first implementation with a small Python helper for low-latency menu generation.

## Why This Exists

Hyprland workspaces are powerful but low-level. `hypr-spotlight` provides a higher-level workflow:

- `personal`, `work`, and `oss` become first-class contexts.
- Number keys keep navigating the current project, not the global workspace graph.
- Spotlight becomes project-aware instead of forcing you to remember where a window lives.

## Architecture

The project is intentionally simple:

- [`bin/hypr-spotlight`](bin/hypr-spotlight): main CLI for project lifecycle, navigation, Waybar, and spotlight actions.
- [`bin/hypr-spotlight-menu-json`](bin/hypr-spotlight-menu-json): fast Python helper that materializes spotlight entries for Elephant.
- [`config/elephant/menus/hypr-spotlight.lua`](config/elephant/menus/hypr-spotlight.lua): native Walker/Elephant menu definition.
- [`config/hyprland-bindings.conf`](config/hyprland-bindings.conf): example Hyprland bindings.
- [`config/waybar-module.jsonc`](config/waybar-module.jsonc): Waybar module snippet.
- [`config/waybar-style.css`](config/waybar-style.css): module styling.

Runtime state lives in `~/.cache/hypr-spotlight/`.

## Requirements

- Hyprland
- Waybar
- Walker
- Elephant
- `bash`
- `jq`
- `python3`

Works especially well in Omarchy-based setups, but it is not Omarchy-exclusive.

## Install

```bash
git clone https://github.com/Eiley2/hypr-project.git hypr-spotlight
cd hypr-spotlight
bash install.sh
```

Notes:

- The GitHub slug may still be `hypr-project` until the repository itself is renamed upstream.
- The install script performs a hard cutover to `hypr-spotlight`.
- Old `hypr-project` binaries are removed during install.
- Runtime state is expected at `~/.cache/hypr-spotlight/`.

## Uninstall

```bash
cd hypr-spotlight
bash uninstall.sh
```

## Keyboard Workflow

Recommended bindings are shipped in [`config/hyprland-bindings.conf`](config/hyprland-bindings.conf).

| Key | Action |
| --- | --- |
| `SUPER + 1/2/3` | Go to screen 1/2/3 inside the current project |
| `SUPER + SHIFT + 1/2/3` | Move the focused window to screen 1/2/3 |
| `SUPER + ALT + 1-9` | Jump directly to project by creation order |
| `SUPER + ALT + N` | Create a project |
| `SUPER + ALT + P` | Switch projects |
| `SUPER + ALT + W` | Close the current project |
| `SUPER + ALT + R` | Assign a custom name to the focused window |
| `SUPER + ALT + F` | Open the spotlight |

## Spotlight Behavior

The spotlight is native Walker/Elephant, not `dmenu`.

That matters because it enables:

- real application icons
- lower perceived latency
- better ranking and richer item metadata
- window/app/project/action entries in one surface

Window entries are intentionally structured as:

- Title: `project · window title`
- Subtext: `application name · screen N`

This makes duplicate applications like multiple Brave windows distinguishable at a glance.

## CLI

```bash
hypr-spotlight create "client-a"
hypr-spotlight switch "client-a"
hypr-spotlight go 2
hypr-spotlight move 3
hypr-spotlight switch-index 1
hypr-spotlight next
hypr-spotlight prev
hypr-spotlight name
hypr-spotlight find
hypr-spotlight list
hypr-spotlight current
hypr-spotlight waybar
```

## State Model

Each project owns a block of workspaces. With the default configuration:

```text
project alpha ->  1..10
project beta  -> 11..20
project gamma -> 21..30
```

The active screen inside a project is still represented as a standard Hyprland workspace; `hypr-spotlight` simply maps those workspaces to a higher-level project abstraction.

State files:

- `~/.cache/hypr-spotlight/projects`
- `~/.cache/hypr-spotlight/current`
- `~/.cache/hypr-spotlight/window-names`
- `~/.cache/hypr-spotlight/apps-cache.tsv`

## Waybar

The project includes a `custom/project` module snippet and styling.

Waybar interactions:

| Action | Result |
| --- | --- |
| Left click | Open project switcher |
| Right click | Create project |
| Middle click | Close project |
| Scroll up/down | Cycle through projects |

## Configuration

The main runtime knobs live near the top of [`bin/hypr-spotlight`](bin/hypr-spotlight):

- `MIN_SCREENS`: minimum number of dots shown in Waybar
- `BLOCK`: workspace block size reserved per project
- `STATE_DIR`: runtime cache/state location

## Operational Notes

- This release is a hard cutover to `hypr-spotlight`.
- There are no compatibility aliases for `hypr-project`.
- There is no automatic migration from old `~/.cache/hypr-projects/` state.
- If you are migrating manually, move or recreate state explicitly.

## Development

Validation commands:

```bash
bash -n bin/hypr-spotlight
python -m py_compile bin/hypr-spotlight-menu-json
```

Useful local checks:

```bash
bin/hypr-spotlight menu-json | jq '.[0:10]'
rg -n "hypr-spotlight" .
```

## Troubleshooting

### Spotlight opens but shows no results

Check:

- `journalctl --user -u elephant.service -n 100 --no-pager`
- `elephant listproviders | rg hypr-spotlight`
- `~/.config/elephant/menus/hypr-spotlight.lua`

### Spotlight opens but feels slow

The expensive path should be the Walker/Elephant UI, not menu generation. Verify:

```bash
time bin/hypr-spotlight menu-json >/dev/null
```

If that is slow, inspect Hyprland client volume and application cache generation.

### Waybar does not update

Check that Waybar is listening to `SIGRTMIN+11` and that the custom module has been added correctly.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security

See [SECURITY.md](SECURITY.md).

## License

MIT. See [LICENSE](LICENSE).
