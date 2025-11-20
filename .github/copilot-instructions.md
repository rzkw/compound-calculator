<!-- Purpose: guidance for AI coding agents to be immediately productive in this repo -->
# Copilot / AI Agent Instructions — compound-calculator

Purpose: Help an AI contributor quickly understand, modify, and extend this small static web app.

- **Big picture**: This repository is a single-page, static Compound Interest Calculator built with vanilla HTML, CSS and JavaScript. There is no build system or bundler. The app is served as static files (`index.html`, `styles.css`, `script.js`) and can be deployed directly to any static host (Azure Static Web Apps was used previously — see `Readme.md`).

- **Key files**:
  - `index.html` — single entry point, contains form and result placeholders. Important element IDs: `calculator-form`, `principal`, `rate`, `time`, `compounds`, `result`, `future-value`, `interest-earned`.
  - `script.js` — DOM-driven logic. Main points: code runs inside `DOMContentLoaded`; `calculateCompoundInterest()` and `formatCurrency()` are small pure functions. The form submission handler prevents default and displays results by removing the `hidden` class.
  - `styles.css` — presentational styles only.
  - `Dockerfile` — uses `nginx:alpine` and copies the repo root into `/usr/share/nginx/html`. Note: a non-root user is created (`contuser`) but no `chown` is present (there is a commented placeholder). If changing file ownership is required, add an explicit `chown -R contuser:contgroup /usr/share/nginx/html` after copy.
  - `Readme.md` — usage and deployment link; follow the contributing flow listed there for PRs.

- **Architecture & patterns to preserve**:
  - Keep logic small and DOM-centric — JS expects elements to exist by ID; avoid introducing frameworks or build steps unless you also add a clear build + Dockerfile change.
  - Prefer pure helper functions for logic (see `calculateCompoundInterest`) so they can be unit-tested if you later add tests.

- **Developer workflows** (how-to run / build / debug locally):
  - Quick local preview: open `index.html` in a browser, or run a simple static server from the project root, e.g.: `python -m http.server 8000` then open `http://localhost:8000`.
  - Buildless static deploy: since files are static, deployment is a straight copy to static host (Azure Static Web Apps, Netlify, GitHub Pages).
  - Containerize: build and run the included Docker image:

    docker build -t compound-calculator .
    docker run -p 8080:80 compound-calculator

    Note: the `Dockerfile` currently creates a non-root user but omits a `chown` — if containers fail with permission issues, add `RUN chown -R contuser:contgroup /usr/share/nginx/html`.

- **Project-specific conventions & gotchas**:
  - IDs in `index.html` are relied upon directly from `script.js`. When renaming fields, update both files.
  - `script.js` uses `parseFloat`/`parseInt` without additional validation. Guard against NaN or missing inputs when adding features or unit tests.
  - There are no automated tests or linters. If you add them, include a short README section and update the Dockerfile or CI accordingly.

- **Integration points / external dependencies**:
  - No runtime npm/node dependencies — it is completely client-side and static.
  - Deployment: Azure Static Web Apps link is present in `Readme.md`; CI/CD config is not present in the repo.

- **When editing the Dockerfile**:
  - If adding a build step (e.g., bundling with webpack), move the build artifacts into the copy destination and change the `COPY` path to only include the `dist`/`build` output.
  - Preserve the port mapping (`EXPOSE 80`) and `nginx` `CMD` unless you intentionally switch base images.

- **Suggested quick PR examples** (concrete, small tasks an AI agent can implement):
  - Add input validation and friendly error messages for NaN or negative inputs in `script.js`.
  - Implement unit tests for `calculateCompoundInterest()` by extracting it into a module and adding a minimal test harness (e.g., Jest) — update README with test commands.
  - Make the Dockerfile set correct ownership after `COPY` (add `chown`) and remove the commented placeholder.

If anything in these notes is unclear or you want more detail (example PR, tests, or CI additions), tell me which area to expand and I will iterate. 
