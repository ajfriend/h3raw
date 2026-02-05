# Development Guide

## Versioning

h3raw uses its own [semantic versioning](https://semver.org/), independent of
the underlying H3 C library version. The H3 version that h3raw wraps is
documented in `CHANGELOG.md` and in `build.zig.zon` (as the `.h3` dependency URL).

This decoupling is intentional:

- h3raw may have its own changes (new features, build fixes, Zig version
  updates) that don't correspond to an H3 release.
- An H3 patch release may not require any h3raw changes.
- Matching H3's version could mislead users into thinking h3raw *is* H3.

Note: The initial release `v4.4.1` used a tag matching the H3 version.
All subsequent releases use h3raw's own versioning starting from `v0.1.0`.

## Making a Release

### 1. Update H3 (if needed)

If updating the bundled H3 version:

1. Update the URL in `build.zig.zon` to point to the new H3 release tarball:

   ```zig
   .h3 = .{
       .url = "https://github.com/uber/h3/archive/refs/tags/v<NEW_VERSION>.tar.gz",
       .hash = "...",
   },
   ```

2. Get the new hash by running `zig build`. The build will fail and print the
   correct hash. Update `.hash` with the value it gives you.

3. Run `zig build test` to verify everything works.

### 2. Bump the version

Update the `.version` field in `build.zig.zon`:

```zig
.version = "X.Y.Z",
```

### 3. Update the changelog

Add an entry to `CHANGELOG.md` documenting what changed and which H3 version
is bundled.

### 4. Update the readme

Update the tag version in the installation URL in `readme.md` to match the
new release tag.

### 5. Commit, tag, and push

Create the tag locally and push it along with the commit. This avoids needing
to create releases through the GitHub UI and ensures tags stay in sync with
your local repo.

```sh
git add -A
git commit -m "release vX.Y.Z"
git tag vX.Y.Z
git push origin main --tags
```

The tag is what makes the release available to downstream Zig users. They
reference h3raw via the tag's tarball URL:

```
https://github.com/ajfriend/h3raw/archive/refs/tags/vX.Y.Z.tar.gz
```

When they first run `zig build`, Zig will fetch the tarball and print the
expected hash, which they paste into their `build.zig.zon`.

Optionally, create a GitHub release from the tag afterward for visibility,
but it's not required — the tag alone is sufficient for Zig package resolution.

## Running Tests

```sh
zig build test
```

## CI

GitHub Actions runs on push to `main`. See `.github/workflows/ci.yml`.
