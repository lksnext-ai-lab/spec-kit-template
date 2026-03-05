# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.4.0](https://github.com/lksnext-ai-lab/spec-kit-template/compare/v2.3.0...v2.4.0) (2026-03-05)


### Features

* add bootstrap script for workspace setup ([6c8c598](https://github.com/lksnext-ai-lab/spec-kit-template/commit/6c8c598efcc66a290455a7c87c97ed8076a31b67))
* Add comprehensive specification documents for project structure ([26693ab](https://github.com/lksnext-ai-lab/spec-kit-template/commit/26693abdfb10729cf8e4b39a769207719027b7b7))
* add evolutionary mode prompts and skills for codebase integration ([4b3530a](https://github.com/lksnext-ai-lab/spec-kit-template/commit/4b3530afc8db51adc03776ce1f3eb008a4b5a907))
* Add markdownlint configuration to disable line length rule ([add4f9e](https://github.com/lksnext-ai-lab/spec-kit-template/commit/add4f9ed8b942b5de5409b7b17f8064e9aedcdbc))
* Add styling for markdown grid and update custom agents documentation ([0c548e7](https://github.com/lksnext-ai-lab/spec-kit-template/commit/0c548e7a9ee759ddec6b1b6c6b70767125172d5d))
* Enhance codebase documentation and discovery processes ([c21899a](https://github.com/lksnext-ai-lab/spec-kit-template/commit/c21899a7f540fb826223d055674f243feaa38ad2))
* implement auto-update system and interactive selector for bootstrap process ([4aa96d9](https://github.com/lksnext-ai-lab/spec-kit-template/commit/4aa96d9643a6d64b1810d4d49b207043a5f0b3c7))
* Implement close iteration script and related documentation ([a04879c](https://github.com/lksnext-ai-lab/spec-kit-template/commit/a04879cb93864fd099c2ace15dc88c1d23a86da0))
* Implement export to DOCX functionality with command generation and documentation updates ([5a86121](https://github.com/lksnext-ai-lab/spec-kit-template/commit/5a8612118fa9441c4150276e0b0a988078e9e068))


### Bug Fixes

* adjust error handling for native commands in Invoke-Setup function ([4bd7d48](https://github.com/lksnext-ai-lab/spec-kit-template/commit/4bd7d48f21cbc859bbd76b506a1756c12a59836a))
* adjust header height and improve TUI display functions in bootstrap scripts ([c27a2b9](https://github.com/lksnext-ai-lab/spec-kit-template/commit/c27a2b9e61acd2f6675c4484386724ccdc883ca9))
* improve header display and cursor management in bootstrap scripts ([3cdf97d](https://github.com/lksnext-ai-lab/spec-kit-template/commit/3cdf97da35f78956fecd053057d9fb50d59e7f52))
* restore strict error handling after executing native commands in Invoke-Setup function ([790d926](https://github.com/lksnext-ai-lab/spec-kit-template/commit/790d926fdd02e835bcc84f37b61572a21d23755f))
* update repository references to lksnext-ai-lab in bootstrap scripts and documentation ([ca74836](https://github.com/lksnext-ai-lab/spec-kit-template/commit/ca74836a48d4c7398b6eafe2322b558c0e3be561))

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
