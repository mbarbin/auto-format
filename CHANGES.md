## 0.0.9 (2024-08-19)

### Changed

- Switch to using `commandlang` for commands.

## 0.0.8 (2024-07-26)

### Added

- Added dependabot config for automatically upgrading action files.

### Changed

- Upgrade `ppxlib` to `0.33` - activate unused items warnings.
- Upgrade `ocaml` to `5.2`.
- Upgrade `dune` to `3.16`.
- Upgrade base & co to `0.17`.

## 0.0.7 (2024-04-05)

### Changed

- Use `run` instead of `bash` in generated dune rules actions.

## 0.0.6 (2024-03-13)

### Changed

- Upgrade `fpath-base` to `0.0.9` (was renamed from `fpath-extended`).
- Upgrade `eio` to `1.0` (no change required).
- Uses `expect-test-helpers` (reduce core dependencies)
- Upgrade `eio` to `0.15`.
- Run `ppx_js_style` as a linter & make it a `dev` dependency.
- Upgrade GitHub workflows `actions/checkout` to v4.
- In CI, specify build target `@all`, and add `@lint`.

## 0.0.5 (2024-02-27)

### Changed

- List ppxs instead of `ppx_jane`.
- Upgrade to `fpath-extended.0.0.7` (breaking change).

## 0.0.4 (2024-02-14)

### Changed

- Upgrade dune to `3.14`.
- Build the doc with sherlodoc available to enable the doc search bar.

## 0.0.3 (2024-02-09)

### Changed

- Internal changes related to the release process.
- Upgrade dune and internal dependencies.
- Upgrade to `Eio_writer.0.0.3` API (breaking change).

## 0.0.2 (2024-01-17)

### Changed

- Now deploying odoc upon release.
- Update warnings flags.
- Remove description that duped synopsis in dune-project and opam file.

## 0.0.1 (2023-11-12)

Initial release.
