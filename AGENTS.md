- Do not make extra changes! Only make the changes requested!

# Style
- Do your best to modularize the configuration into different files
- Refer to binaries in the nix way. For example `${pkgs.firefox}/bin/firefox` instead of `firefox`.

# Post change hooks
1. Add newly created untracked files with `git add NEWLY_CREATED_FILE`
2. Test `nix flake check` passes
3. Format with `nix fmt **/*.nix`
