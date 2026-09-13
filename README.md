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
