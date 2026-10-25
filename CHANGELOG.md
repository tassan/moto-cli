# Changelog

All notable changes to this project are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Dates are UTC.

## [Unreleased]

### Added
- `CHANGELOG.md`.
- Claude Code skill: `skills/moto/SKILL.md`.
- `AGENTS.md` (and `CLAUDE.md` pointing to it): instructions for AI agents using or developing moto-cli.

## [0.1.2.1] - 2026-10-25

### Added
- README: CI badge.

## [0.1.2] - 2026-10-25

### Added
- README: "Why" section and vibecoded disclaimer.
- GitHub repository description and topics.

## [0.1.1] - 2026-10-25

### Added
- `moto version` (also `-v`, `--version`).
- README: Terraform example.

### Changed
- README: HTTPS clone URL.

## [0.1.0] - 2026-10-25

### Added
- `moto` CLI: `start`, `stop`, `restart`, `status`, `info`, `env`, `reset`, `logs`, `aws`, `update`, `doctor`, `help`.
- Moto server in Docker on `localhost:5555`, with an auto-created `moto` aws profile.
- Env overrides: `MOTO_PORT`, `MOTO_REGION`, `MOTO_IMAGE`, `MOTO_NAME`, `MOTO_PROFILE`.
- MIT license, CONTRIBUTING, end-to-end smoke test, CI (shellcheck + smoke).

[Unreleased]: https://github.com/tassan/moto-cli/compare/v0.1.2.1...HEAD
[0.1.2.1]: https://github.com/tassan/moto-cli/compare/v0.1.2...v0.1.2.1
[0.1.2]: https://github.com/tassan/moto-cli/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/tassan/moto-cli/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/tassan/moto-cli/releases/tag/v0.1.0
