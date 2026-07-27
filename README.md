# Dotfiles

A reproducible macOS workstation managed with
[chezmoi](https://www.chezmoi.io/) and 1Password.

This repository is the source of truth for my shell, editor, terminal, packages,
and machine-level automation. A fresh Mac starts with one bootstrap command;
subsequent `chezmoi apply` runs converge package, service, and configuration
state without hiding secrets in Git.

## Bootstrap a new Mac

```bash
curl -fsSL https://raw.githubusercontent.com/SpencerPresley/dotfiles/main/bootstrap.sh | bash
```

The bootstrap is intentionally interactive. It:

1. Installs Xcode Command Line Tools and Homebrew.
2. Installs `chezmoi`, Git, GitHub CLI, 1Password, and the 1Password CLI.
3. Pauses while 1Password CLI integration and its SSH agent are enabled.
4. Authenticates GitHub through `gh auth login`.
5. Installs Oh My Zsh and initializes this repository through chezmoi.
6. Installs the declared Homebrew packages and applications.
7. Applies the managed files and runs the lifecycle scripts.

After it finishes, open a new terminal and start `tmux`. Press `prefix + I` once
to install the TPM-managed plugins.

The `github-work` SSH alias is managed here, but its private key and GitHub
authentication are not. Add the work key to the 1Password SSH agent and
authenticate that account separately.

## What is managed

- **Packages:** command-line tools, applications, fonts, and language tooling
  declared in `Brewfile`
- **Shell:** Zsh, Oh My Zsh, Powerlevel10k, aliases, functions, and prompt-engine
  switching
- **Editor:** a complete Lua-based Neovim configuration with LSPs, formatting,
  linting, navigation, Claude Code, and Yazi integration
- **Terminal:** Ghostty, tmux, TPM, Starship, Oh My Posh, and Yazi
- **Developer tools:** Git, GitHub CLI, Docker/Colima, PostgreSQL, Redis, Ollama,
  Tailscale, and language toolchains
- **Machine automation:** idempotent chezmoi scripts and per-user LaunchAgents
- **Credentials:** 1Password references rendered at apply time; secret values and
  private keys never live in this repository

## Lifecycle automation

The `.chezmoiscripts/` directory owns setup that needs more than copying a
configuration file:

- **Homebrew metadata updates:** a LaunchAgent runs `brew update` every 12 hours.
  It deliberately does not upgrade packages or applications in the background,
  and trusts only the `domt4/autoupdate/autoupdate` command rather than the
  entire tap.
- **Ollama environment:** values from `.chezmoidata/ollama.yaml` are rendered
  into a per-user LaunchAgent and applied to the current launchd session.
- **Ghostty to Yazi theme sync:** changes to the resolved Ghostty configuration,
  local overrides, or generator automatically rebuild the matching Yazi flavor.
- **Package convergence:** Brew, tmux plugins, global npm CLIs, Ollama, Docker
  Compose, and Tailscale are installed or repaired from repo-owned declarations.
- **Secret scanning:** a self-healing Git hook runs gitleaks against staged
  changes before commits to this public repository.

`run_onchange_` scripts include hashes of the declarations they consume, so an
ordinary `chezmoi apply` reruns the relevant automation when its source changes.

## Neovim

The Neovim configuration lives directly under `dot_config/nvim/`; it is no
longer cloned from a separate setup repository. It supports a minimal VS Code
mode as well as the full terminal configuration.

One custom component is `:Tail`, an opt-in live-file follower implemented with
libuv file events and a polling backstop. It:

- follows appends without replacing the current buffer;
- preserves the cursor when scrolled up and follows when already at the bottom;
- survives truncation, atomic rename, and delete/recreate rotation;
- refuses to clobber unsaved edits;
- tears down watchers and timers with the buffer; and
- disables itself above a 10 MB ceiling instead of repeatedly rereading a
  firehose.

The real module is exercised headlessly by adversarial, recovery, and seeded
property-fuzz tests:

```bash
bash dot_config/nvim/tests/tail/executable_run.sh
```

The fuzzer mixes append, truncate, rename, delete, recreate, edit, save, discard,
cursor, and tail-toggle operations while checking buffer and watcher invariants
after every step.

## Repository layout

```text
bootstrap.sh               fresh-machine entry point
Brewfile                    packages, applications, and fonts
.chezmoidata/               structured inputs for templates and scripts
.chezmoiscripts/            installation, convergence, and LaunchAgent logic
.githooks/                  public-repo secret scanning
dot_config/nvim/            Neovim configuration, utilities, and tests
dot_config/ghostty/         rendered terminal configuration
dot_config/tmux/            tmux configuration
private_dot_ssh/            SSH config and public keys; no private key material
```

Chezmoi's source-state names encode the rendered destination and permissions.
For example, `dot_config/nvim/` becomes `~/.config/nvim/`, while `private_`
ensures restrictive permissions on the rendered file—it does not make a source
file secret.

## Day-to-day use

```bash
chezmoi diff
chezmoi apply
```

Machine-specific values belong in chezmoi data or 1Password. Reusable behavior
belongs in this repository.
