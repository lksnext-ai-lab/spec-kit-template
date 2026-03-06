# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.5.0] — 2026-03-06

### Changed

- Fix `irm | iex` one-liner compatibility: wrap script body in `& { } @args` scriptblock.
- Fix `$PSCommandPath` empty in iex mode: `Find-RunMode` falls back to cwd.
- Move PSScriptAnalyzer suppressions to `tools/PSScriptAnalyzerSettings.psd1`.

## [2.4.2] — 2026-03-06

### Changed

- Version bumped to 2.4.2.

## [2.4.0] — 2026-03-05

### Changed

- Version bumped to 2.4.0 manually (release-please workflow replaced with manual trigger)
- GitHub Actions release workflow changed to `workflow_dispatch` only; no longer runs automatically on push to `main`

## [2.3.0](https://github.com/lksnext-ai-lab/spec-kit-template/compare/v2.2.1...v2.3.0) — 2025-07-08

### Added

- **Auto-update system**: bootstrap detects existing SPEC-KIT installations via `tools/.speckit` and offers interactive update flow
- **Interactive selector**: arrow-key navigation with contextual hint panels for all multi-choice prompts (replaces numbered input)
- **`--check` flag**: exits 0 (up to date) or 1 (update available) for CI integration
- **`--update` flag**: forces re-application of managed files even when versions match
- **`.speckit` control file**: JSON metadata (version, install date, managed paths) generated at install time
- **Update menu**: view changelog, view affected files, apply update, or skip
- **Git dirty-tree protection**: detects uncommitted changes in managed files with double-confirmation before overwriting
- **VS Code reload prompt**: offers automatic workspace reload after update
- **LKS Next branding**: header and footer display "by LKS Next" attribution

### Changed

- Version bumped to 2.3.0 with `# x-release-please-version` marker for automated releases
- Header updated with "by LKS Next" line in both PS1 and SH scripts
- Summary box updated with "SPEC KIT by LKS Next" footer branding

## [2.2.1](https://github.com/lksnext-ai-lab/spec-kit-template/releases/tag/v2.2.1)

### Fixed

- Initial public release with bootstrap wizard for Windows (PowerShell) and Unix (Bash)
