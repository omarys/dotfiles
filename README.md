# Dotfiles

## Install

```bash
git clone https://github.com/omarys/dotfiles ~/.dotfiles
cd ~/.dotfiles
stow --no-folding .
```

The repository's `.stowrc` also sets `--no-folding`. This keeps application
folders as real directories so new runtime files stay outside the checkout.
Existing directory symlinks need to be split before they can isolate local data.

## Codex

Keep `~/.codex` as a real directory. Stow links the shared instructions,
`hooks.json`, and the two custom skill directories into it. Install `context-mode`
and `rekal` before using the configured hooks and MCP servers.

On a new system, copy the configuration template once:

```bash
if [ ! -e ~/.codex/config.toml ]; then
    cp ~/.dotfiles/.codex/config.toml.example ~/.codex/config.toml
fi
```

Edit `~/.codex/config.toml` locally. Credentials, project trust, command approvals,
plugin installations, bundled skills, sessions, databases, and caches belong in
`~/.codex`; do not link them into the repository. Git and Stow allow only the
shared Codex files. Add an explicit exception to both ignore files when adding
another shared file.

## Pi

Keep `~/.pi/agent` a real directory. Stow links only the shared files into it:
`settings.json`, `AGENTS.md`, the extensions, and `~/.pi/agents/*.md`. Auth tokens,
sessions, caches, and installed packages stay local to each machine.

Packages are declared once, in `.pi/agent/settings.json`. Pi installs them into
`~/.pi/agent/npm` on first launch, so that directory is never committed or stowed.
Do not recreate `.pi/settings.json`, `.pi/trust.json`, or `.pi/extensions` at the
repository root: Pi would read them as a project-scoped package declaration and
install a second copy of every package into `.pi/npm` whenever you run `pi` from
inside `~/.dotfiles`.

### Local patch

`.pi/patches/pi-antigravity/` holds a fix patch for the installed
`pi-antigravity` version. Pi rebuilds `~/.pi/agent/npm` from its `package.json` on
every install, update, and removal, which discards the patch. Re-apply it after any
of those:

```bash
~/.dotfiles/.pi/patches/pi-antigravity/apply.sh
```

The script refuses to run against an unexpected package version, and is a no-op
when the patch is already applied. Drop the patch directory once the fixes land
upstream.
