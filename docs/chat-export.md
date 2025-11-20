<!-- Conversation export: debugging Dockerfile user/permissions and build errors -->
# Chat export — Dockerfile user & build debugging

Date: 2025-11-20

Summary
- The conversation covered why the Docker image needed ownership changes on `/usr/share/nginx/html` when running as a non-root user, why `groupadd`/`useradd` commands failed in an `nginx:alpine` image, and the root cause of a build failure caused by undefined build variables expanding to empty strings (leading to `groupadd: option requires an argument: g`).

Key points and commands discussed
- Dockerfile ownership: files copied during build are owned by root by default. If the container runs a non-root user, that user needs read (and possibly write) permissions to the web files.

- Preferred fixes:

  - Set ownership during copy (preferred):

```dockerfile
COPY --chown=contuser:contgroup . /usr/share/nginx/html
```

  - Or chown after copy (works everywhere):

```dockerfile
COPY . /usr/share/nginx/html
RUN chown -R contuser:contgroup /usr/share/nginx/html
```

- Alpine vs GNU tools: `nginx:alpine` does not include GNU `groupadd`/`useradd` by default. Use Alpine equivalents (`addgroup` / `adduser`) or install `shadow` if you want to keep `groupadd`/`useradd`.

Example (Alpine-native, with build ARG defaults):

```dockerfile
FROM nginx:alpine

ARG USERNAME=contuser
ARG USER_UID=1234
ARG USER_GID=1234

COPY --chown=$USER_UID:$USER_GID . /usr/share/nginx/html

RUN addgroup -g $USER_GID $USERNAME \
    && adduser -D -u $USER_UID -G $USERNAME $USERNAME

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

- Root cause of the build error seen during the conversation: build-time variables like `$USERNAME` / `$USER_GID` were referenced without `ARG` declarations or `--build-arg` values, so they expanded to empty strings. That produced `groupadd -g` with no argument and failed with `option requires an argument: g`. BuildKit also reported `UndefinedVar` warnings.

Troubleshooting tips that were recommended
- Declare `ARG` defaults in the `Dockerfile` (so `docker build` works without extra flags).
- Use `COPY --chown` to avoid an extra layer and ensure ownership is correct at copy time.
- For Alpine, prefer `addgroup`/`adduser` or install `shadow` (`apk add --no-cache shadow`) if you require GNU `useradd`/`groupadd`.
- For debugging, add a `RUN echo` line in the Dockerfile to print ARG values during build (e.g. `RUN echo "$USERNAME $USER_UID $USER_GID"`).

Repository note (explicit)
- The non-root user directive was removed from the `Dockerfile` during the containerisation effort to avoid build failures caused by undefined build variables and Alpine/GNU tool differences. If the team decides to reintroduce a non-root user, follow the recommendations above (declare `ARG` defaults, set ownership with `COPY --chown`, or use Alpine-native commands).

---
**Clarification!**

- Arguments were just in the wrong location, but I chose not to include non-root user as it would need more configs than I need for a calculator app

---


Conversation extract (condensed)
- User: Asked why they needed to `chown /usr/share/nginx/html` to the non-root user.
- Assistant: Explained COPY ownership, why non-root users need access, and suggested `COPY --chown` or `RUN chown -R ...` with references to Docker docs and nginx image.
- User: Reported build failure when variables were defined; provided build logs showing `groupadd: option requires an argument: g` and an `UndefinedVar` warning for `$USERNAME`.
- Assistant: Diagnosed that `$USER_GID`/`$USERNAME` expanded empty because they were not declared or passed; recommended declaring `ARG` defaults and using Alpine `addgroup`/`adduser` or installing `shadow`.

Files referenced
- `Dockerfile`
- `index.html`
- `script.js`
- `Readme.md`

If you want this full chat transcript (including each individual assistant/user message) added instead of this condensed export, tell me and I will append the full verbatim transcript to this file.

Additional conversation — image, registry, and repo layout
Date: 2025-11-20

- User: "does the image need to be provided in the repo?"

- Assistant: Short answer: No — do not commit built Docker images into the repository. Commit the `Dockerfile`, `README` instructions, and helper files; build/push images in CI or locally and publish to a registry (Docker Hub, GHCR, ACR).

  - Why not: images are large binary blobs, bloat history, and are environment-dependent. The `Dockerfile` is the source of truth.
  - Keep in the repo: `Dockerfile`, `README.md`, `.dockerignore`, and optional CI workflows for building/pushing images.
  - Recommended workflow (examples):

```bash
docker build -t <registry>/<repo>:<tag> .
docker run -p 8080:80 <registry>/<repo>:<tag>
docker push <registry>/<repo>:<tag>
```

- Assistant: Offered to add `.dockerignore`, patch the `Dockerfile`, and/or add a GitHub Actions workflow; asked which option the user preferred.

- User: Requested this conversation segment be appended to the chat-export file (this section).

