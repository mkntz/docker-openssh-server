---
name: update-versions
description: 'Check for the latest stable Alpine Linux version (excluding edge) and its openssh-server package version, then update deploy-tags.yml and README.md, and on user approval commit, tag, and push a new release. Use when the user asks to check for updates, bump Alpine/OpenSSH version, or cut a new release/tag for docker-openssh-server.'
---

# Update Alpine / OpenSSH Versions

Checks Alpine Linux and `openssh-server` package versions, updates repo files, and (on approval) releases a new tag.

## Procedure

### 1. Find the latest stable Alpine version

Fetch `https://dl-cdn.alpinelinux.org/alpine/` (directory listing). Extract all `vX.Y/` entries, **ignore `edge/` and `latest-stable/`**, and pick the numerically highest `X.Y`.

Record as `ALPINE_VERSION` (e.g. `3.24`).

### 2. Find the openssh-server version for that Alpine branch

Fetch `https://pkgs.alpinelinux.org/package/v{ALPINE_VERSION}/main/x86_64/openssh-server` and read the `Version` field (format like `10.3_p1-r1`).

Convert to this repo's tag pattern:
- Replace the `_` with nothing: `10.3_p1-r1` → `10.3p1-r1`
- Strip the trailing `-rN` release suffix: `10.3p1-r1` → `10.3p1`

Record as `OPENSSH_VERSION` (e.g. `10.3p1`).

### 3. Compare against current repo state

Read the current values from:
- [README.md](../../../README.md) — Alpine badge and OpenSSH badge ([lines 3-5](../../../README.md#L3-L5))
- [.github/workflows/deploy-tags.yml](../../workflows/deploy-tags.yml) — `env.ALPINE_VERSION` ([line 8](../../workflows/deploy-tags.yml#L8))

If both `ALPINE_VERSION` and `OPENSSH_VERSION` already match the latest found values, report "up to date" and stop — do not make any changes.

### 4. Update files if newer versions are available

- **[deploy-tags.yml](../../workflows/deploy-tags.yml)**: update `env.ALPINE_VERSION` to the new value.
- **[README.md](../../../README.md)**:
  - Update the three shields.io badges (Docker Image, Alpine Version, OpenSSH Version) near the top of the file.
  - Prepend a new entry to the "Supported tags and respective `Dockerfile` links" list, linking to `blob/{OPENSSH_VERSION}/Dockerfile`.
  - Replace every occurrence of the old `mkntz/openssh-server:{OLD_VERSION}` / `openssh-server:{OLD_VERSION}` string throughout the file (usage examples, docker-compose snippet, build commands) with `{OPENSSH_VERSION}`.

### 5. Wait for user review and approval

Present a summary of the changed files/values and pause. Do **not** commit, tag, or push until the user explicitly approves.

### 6. On approval: commit, tag, and push

From the repo root:

```bash
git add .github/workflows/deploy-tags.yml README.md
git commit -m "chore: update Alpine to {ALPINE_VERSION} and OpenSSH to {OPENSSH_VERSION}"
git tag -a {OPENSSH_VERSION} -m "chore: update Alpine to {ALPINE_VERSION} and OpenSSH to {OPENSSH_VERSION}"
git push origin main --follow-tags
```

Notes:
- Tags in this repo use the bare OpenSSH version with no `v` prefix (e.g. `10.3p1`, `10.2p1`, `10.0p1`, `9.9p2`).
- Pushing the tag triggers [deploy-tags.yml](../../workflows/deploy-tags.yml), which builds and publishes the Docker image.
