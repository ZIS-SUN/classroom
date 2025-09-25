# Repository Guidelines

This guide defines structure, conventions, and day-to-day commands for contributing changes. Keep changes small, focused, and verified locally before opening a PR.

## Project Structure & Module Organization
- `src/` production code, organized by feature (e.g., `src/<feature>/...`).
- `tests/` unit/integration tests mirroring `src/` paths.
- `scripts/` local tooling (format, lint, release) runnable as executables.
- `assets/` static files; `docs/` documentation; `.github/` CI workflows.
- Keep modules cohesive; colocate small helpers with their feature; extract shared utilities to `src/lib`.

## Build, Test, and Development Commands
- Preferred entrypoints are Make targets when a `Makefile` exists:
  - `make setup` install deps; `make dev` run local dev/watchers.
  - `make test` run suite; `make lint` lint/format; `make build` create artifacts.
- Without Make, use language-native scripts if present:
  - Node: `npm ci && npm run dev|test|lint|build` (see `package.json`).
  - Python: `pip install -r requirements.txt && pytest -q`.
- Scripts in `scripts/` take precedence when available (e.g., `./scripts/format`).

## Coding Style & Naming Conventions
- Indentation: 2 spaces for JSON/YAML; follow language defaults elsewhere.
- Filenames: lowercase; `kebab-case` for JS/TS; `snake_case` for Python.
- Code style: respect existing configs (`.editorconfig`, ESLint/Prettier, Ruff/Black).
- Public APIs: prefer clear names over abbreviations; avoid one-letter identifiers.

## Testing Guidelines
- Mirror `src/` structure in `tests/` (e.g., `src/foo/bar.ts` → `tests/foo/bar.spec.ts`).
- Aim for ≥80% coverage on changed code; include negative paths and edge cases.
- Fast tests by default; mark slow/integration tests explicitly.
- Run locally: `make test` or the language-native test command above.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- Subject ≤72 chars; imperative mood; reference issues (e.g., `Refs #123`).
- PRs include: clear summary, rationale, screenshots for UI, and test notes.
- Keep PRs focused; update docs and `scripts/*` when behavior changes.

## Security & Configuration Tips
- Do not commit secrets; use `.env.example` and environment variables.
- Add new config with safe defaults; document required env vars in `docs/`.

## Agent-Specific Instructions
- Make minimal, targeted patches; do not add license headers unprompted.
- Follow these guidelines; prefer repository scripts over ad-hoc commands.
- When reorganizing code, update tests, docs, and CI configs together.

