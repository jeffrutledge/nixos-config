- Do not make extra changes! Only make the changes requested!
- Do not commit changes without asking!

# Memory 
Make edits to this AGENTS.md file when:
- the user corrected a mistake: write down the corrected pattern to avoid making it again.
- something took a lot of time to work through: write down hints for next time

- **Avoid Duplicate Imports**: If a package or script is imported and used directly in a specific module (e.g., `sway.nix`), do not also add it to `packages.nix` unless it is explicitly needed in the global environment independently of that module.
- **Package Organization**: When a package requires custom scripts or auxiliary files (like `alacritty-cwd-launch`), create a directory for the package (e.g., `home/alacritty/`), name the main configuration `default.nix`, and place the auxiliary files in that same directory.

# Style
- Do your best to modularize the configuration into different files
- Refer to binaries in the nix way. For example `${pkgs.firefox}/bin/firefox` instead of `firefox`.
- Prefer `writeShellApplication` over `writeShellScriptBin`
- For custom scripts or packages, always use the interpolated path `${pkg}/bin/binary` in configurations rather than relying on `exec binary` and the PATH.

## Neovim
- use ./home/neovim/after/ftplugin for file type specific settings like indents
- put each package settings into its own lua file

# Post change hooks
1. Add newly created untracked files with `git add -N NEWLY_CREATED_FILE`
2. Test `nix flake check` passes. Ignore warnings about dirty Git tree
3. Format with `nix fmt`
