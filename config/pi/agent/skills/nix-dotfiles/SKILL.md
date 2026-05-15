---
name: nix-dotfiles
description: Works on Kamil's Nix and dotfiles setup safely. Use for NixOS, nix-darwin, Home Manager, package, symlink, and desktop configuration tasks.
---

# Nix Dotfiles

Use this skill when working in Kamil's dotfiles repository.

- Prefer Home Manager links over manual symlinks.
- Do not run `sudo`, `nixos-rebuild switch`, or `darwin-rebuild switch` unless explicitly requested.
- For NixOS desktop config, focus on files under `nix/` and referenced config paths.
- Keep secrets out of tracked files, especially `.env`, auth files, and tokens.
- Use `nix eval` or targeted `nix build` checks when practical.
