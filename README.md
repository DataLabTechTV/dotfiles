# Dotfiles for Chezmoi

## Setup

My chezmoi dotfiles are designed to work with and without secrets, conditionally on whether the age private key is available on the current system. For you, an external user, always follow the [Without Secrets](#without-secrets) instructions. You can also clone my repo and replace my secrets with your own, in which case you'll be able to follow the [With Secrets](#with-secrets) instructions.

### With Secrets

This requires that the age private key is available, by default at `~/.config/chezmoi/key.txt`. Configs will include decrypted secrets.

```bash
chezmoi init --source ~/Code/dotfiles --apply -ssh DataLabTechTV/dotfiles
```

### Without Secrets

For systems where the age private key is not available, you won't be able to decrypt any `*.age` secrets that I have committed. I'm also assuming that the SSH private key for this repo is not available on the target system, so I removed the `--ssh` option. While I don't include it here, you can customize your source dir with `--source` as well, here.

```bash
chezmoi init --apply DataLabTechTV/dotfiles
```

> [!NOTE]
> Notice that `~/.config/chezmoi/chezmoi.toml` won't include the typical configs for for age encryption to work. If the age private key becomes available, you'll need to run `chezmoi init` again to regenerate the chezmoi config.

## Cheat Sheet

### Common Commands

#### Track a Config File

Track a new file (or use `-r` to recursively track all files in a directory):

```bash
chezmoi add ~/.config/app/app.conf
```

#### Edit a Config File

Edit a config (use the system path):

```bash
chezmoi edit ~/.config/fish/config.fish
```

#### View Changes

Check what changed:

```bash
chezmoi diff
```

#### Apply Changes

Apply changes (files will be copied over to the system path):

```bash
chezmoi apply
```

#### Encrypting Secrets

Encrypt a secret and save it in the repo (not applied, but used in templates):

```bash
chezmoi encrypt /tmp/secret -o ~/Code/dotfiles/.chezmoitemplates/secrets/secret.age
```

#### Decrypting Secrets

Decrypt a secret to the stdout:

```bash
chezmoi decrypt ~/Code/dotfiles/.chezmoitemplates/secrets/secret.age
```

### Templates

Only files ending with `.tmpl` will be rendered as templates (e.g., see `config.fish.tmpl`).

#### Decrypting Secrets

In order to include the content of an encrypted file, you can use something like this:

```jinja
{{ include ".chezmoitemplates/secrets/secret.age" | decrypt | trim }}
```

This includes a file from the root of the dotfiles repo and, in this case, decrypts it, as long as you have the age private key setup in the path described in the chezmoi config. We usually add `trim` as well, since age encrypted files tend to have a newline at the end, regardless of the original file (I might be wrong).

#### Escaping `{{ ... }}`

If you need to escape `{{ ... }}`, the cleaner way is to use the following strategy, with template variables:

```jinja
{{ $podman_fmt := "{{.Host.RemoteSocket.Path}}" -}}
set -x DOCKER_HOST unix://(podman info --format '{{ $podman_fmt }}')
```

#### Global Template Variables

Any variable defined on the chezmoi config file, under `[data]`, can be accessed globally on any config template. For example, we use it check if an age private key was configured, when we need to use decrypted values on our configs.

```jinja
{{ if .hasAgePrivateKey }}
{{- $homelab_mac := include ".chezmoitemplates/secrets/homelab.mac.age" | decrypt | trim -}}
abbr wake-delorean sudo ether-wake {{ $homelab_mac }}
{{- end }}
```
