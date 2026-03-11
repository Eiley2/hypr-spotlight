# Contributing

## Scope

This project is intentionally small and operationally focused. Contributions should preserve:

- low startup latency
- predictable shell behavior
- minimal runtime dependencies
- clear Hyprland/Waybar/Walker integration boundaries

## Development Principles

- Prefer simple shell or Python over heavier frameworks.
- Keep state formats stable and easy to inspect by hand.
- Do not add compatibility shims or fallback code paths unless they are explicitly justified.
- Optimize for direct operability on a real desktop session, not abstract purity.

## Local Validation

Run before opening a pull request:

```bash
bash -n bin/hypr-spotlight
python -m py_compile bin/hypr-spotlight-menu-json
```

If you change spotlight behavior, also verify:

```bash
bin/hypr-spotlight menu-json | jq '.[0:10]'
```

## Pull Requests

A good PR should include:

- the behavior being changed
- the user-facing impact
- any change to install, bindings, or state layout
- screenshots or short terminal/output snippets when UI behavior changes

## What To Avoid

- adding hidden migration layers
- coupling the project to a specific distro beyond documented requirements
- committing generated files or local state
- renaming core concepts without updating docs and installer behavior
