- Do not make extra changes! Only make the changes requested!

# Memory 
Make edits to this AGENTS.md file when:
- the user corrected a mistake: write down the corrected pattern to avoid making it again.
- something took a lot of time to work through: write down hints for next time

- **Avoid Duplicate Imports**: If a package or script is imported and used directly in a specific module (e.g., `sway.nix`), do not also add it to `packages.nix` unless it is explicitly needed in the global environment independently of that module.

# Style
- Do your best to modularize the configuration into different files
- Refer to binaries in the nix way. For example `${pkgs.firefox}/bin/firefox` instead of `firefox`.
- For custom scripts or packages, always use the interpolated path `${pkg}/bin/binary` in configurations rather than relying on `exec binary` and the PATH.

# Post change hooks
1. Add newly created untracked files with `git add NEWLY_CREATED_FILE`
2. Test `nix flake check` passes
3. Format with `nix fmt **/*.nix`
