- Do not make extra changes! Only make the changes requested!

# Memory 
Make edits to this AGENTS.md file when:
- the user corrected a mistake: write down the corrected pattern to avoid making it again.
- something took a lot of time to work through: write down hints for next time

# Style
- Do your best to modularize the configuration into different files
- Refer to binaries in the nix way. For example `${pkgs.firefox}/bin/firefox` instead of `firefox`.

# Post change hooks
1. Add newly created untracked files with `git add NEWLY_CREATED_FILE`
2. Test `nix flake check` passes
3. Format with `nix fmt **/*.nix`
