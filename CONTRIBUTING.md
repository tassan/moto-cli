# Contributing

Issues and PRs welcome.

- Keep it a single dependency-light bash script (`moto`); needs only docker, curl and optionally aws CLI.
- Lint: `shellcheck moto test/smoke.sh`
- Test: `./test/smoke.sh` (uses its own container `moto-smoke` on port 5599, safe next to a running `moto`)
- New command: add a `cmd_*` function, a line in `cmd_help`, a `case` entry, and a README row.
