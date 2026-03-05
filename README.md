# Dotfiles for Chezmoi

## Instructions for Me

This requires that the age key is available at `~/.config/chezmoi/key.txt`. Also, have the age public key available, as you'll need to input it during `init`.

```bash
export CHEZMOI_SOURCE_DIR=~/Code/dotfiles
chezmoi init --apply --prompt -ssh DataLabTechTV/dotfiles
```

## Instructions for you

If you want to try my configs, go right ahead, but obviously you won't be able to decrypt any `*.age` secrets I might have committed, or use the SSH version of the repo.

I would recommend you try to run the following command:

```bash
chezmoi init --apply DataLabTechTV/dotfiles
```

```
When you get prompted to input the age public key, just type whatever. You'll then need to replace any decrypted includes (grep for `age`). For example, you'll find one on the `~/.config/fish/config.fish`, where I set the MAC address for my home lab.
```

## Common Commands

Track a new file (or use `-r` to recursively track all files in a directory):

```bash
chezmoi add ~/.config/app/app.conf
```

Edit a config (use the system path):

```bash
chezmoi edit ~/.config/fish/config.fish
```

Check what changed:

```bash
chezmoi diff
```

Apply changes (files will be copied over to the system path):

```bash
chezmoi apply
```

Encrypt a secret and save it in the repo (not applied, but used in templates):

```bash
chezmoi encrypt /tmp/secret -o ~/Code/dotfiles/.chezmoitemplates/secrets/secret.age
```

Decrypt a secret to the stdout:

```bash
chezmoi decrypt ~/Code/dotfiles/.chezmoitemplates/secrets/secret.age
```

## Templates

Only files ending with `.tmpl` will be rendered as templates (e.g., see `config.fish.tmpl`).

In order to include the content of an encrypted file, you can use something like this:

```jinja
{{ include ".chezmoitemplates/secrets/secret.age" | decrypt | trim }}
```

This includes a file from the root of the dotfiles repo and, in this case, decrypts it (as long as you have the age private key setup in the path described in the chezmoi config). We usually add `trim` as well, since age encrypted files tend to have a newline at the end, regardless of the original file (I might be wrong).

If you need to escape `{{ ... }}`, the cleaner way is to use the following strategy, with template variables:

```jinja
{{ $podman_fmt := "{{.Host.RemoteSocket.Path}}" -}}
set -x DOCKER_HOST unix://(podman info --format '{{ $podman_fmt }}')
```
