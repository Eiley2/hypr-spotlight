# Security Policy

## Supported Scope

This project is a local desktop workflow tool. Security-sensitive areas include:

- shell command execution from menu actions
- install and uninstall scripts that modify local configuration
- parsing of `.desktop` files and Hyprland state

## Reporting

If you find a security issue, report it privately to the maintainer before opening a public issue.

Include:

- affected version or commit
- reproduction steps
- impact assessment
- any relevant logs or environment notes

## Expectations

- Do not publish weaponized repro steps before the issue is acknowledged.
- Keep reports focused on real impact, not hypothetical style concerns.
- Command-injection or unsafe config mutation findings are high-priority.
