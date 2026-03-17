# nfrastack/container-discourse

## About

This will build a container image for [Discourse](https://www.discourse.org/) - A web based discussion forum.

* Unlike the official Discourse image, this is meant to be self contained without requiring a base image or use the `launcher`
* Flexible Volatile Storage

## Maintainer

* [Nfrastack](https://www.nfrastack.com)

## Table of Contents

- [About](#about)
- [Maintainer](#maintainer)
- [Prerequisites and Assumptions](#prerequisites-and-assumptions)
- [Installation](#installation)
  - [Prebuilt Images](#prebuilt-images)
  - [Multi-Architecture Support](#multi-architecture-support)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
- [Environment Variables](#environment-variables)
  - [Base Images used](#base-images-used)
  - [Core Configuration](#core-configuration)
  - [Database Options](#database-options)
  - [Plugins](#plugins)
- [Users and Groups](#users-and-groups)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [Support & Maintenance](#support--maintenance)
- [References](#references)
- [License](#license)

## Prerequisites and Assumptions

* Assumes you are using some sort of SSL terminating reverse proxy such as:
  * [Traefik](https://github.com/nfrastack/container-traefik)
  * [Nginx](https://github.com/jc21/nginx-proxy-manager)
  * [Caddy](https://github.com/caddyserver/caddy)
* Requires access to a Postgres Server
* Requires access to a Redis Server

## Installation

### Prebuilt Images

Feature limited builds of the image are available on the [Github Container Registry](https://github.com/nfrastack/container-discourse/pkgs/container/container-discourse) and [Docker Hub](https://hub.docker.com/r/nfrastack/discourse).

To unlock advanced features, one must provide a code to be able to change specific environment variables from defaults. Support the development to gain access to a code.

To get access to the image use your container orchestrator to pull from the following locations:

```
ghcr.io/nfrastack/container-discourse:(image_tag)
docker.io/nfrastack/discourse:(image_tag)
```

Image tag syntax is:

`<image>:<optional tag>-<optional_distribution>_<optional_distribution_variant>`

Example:

`ghcr.io/nfrastack/container-discourse:latest` or

`ghcr.io/nfrastack/container-discourse:1.0` or optionally

`ghcr.io/nfrastack/container-discourse:1.0-alpine` or optinally

`ghcr.io/nfrastack/container-discourse:alpine`

* `latest` will be the most recent commit
* An optional `tag` may exist that matches the [CHANGELOG](CHANGELOG.md) - These are the safest
* If it is built for multiple distributions there may exist a value of `alpine` or `debian`
* If there are multiple distribution variations it may include a version - see the registry for availability

Have a look at the container registries and see what tags are available.

#### Multi-Architecture Support

Images are built for `amd64` by default, with optional support for `arm64` and other architectures.

### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for your use.

* Map [persistent storage](#persistent-storage) for access to configuration and data files for backup.
* Set various [environment variables](#environment-variables) to understand the capabilities of this image.

### Persistent Storage

The container operates heavily from the `/app` folder, however there are a few folders that should be persistently mapped to ensure data persistence. The following directories are used for configuration and can be mapped for persistent storage.

| Directory       | Description       |
| --------------- | ----------------- |
| `/logs`         | Logfiles          |
| `/data/uploads` | Uploads Directory |
| `/data/backups` | Backups Directory |
| `/data/plugins` | Plugins Driectory |

### Environment Variables

#### Base Images used

This image relies on a customized base image in order to work.
Be sure to view the following repositories to understand all the customizable options:

| Image                                                   | Description |
| ------------------------------------------------------- | ----------- |
| [OS Base](https://github.com/nfrastack/container-base/) | Base Image  |

Below is the complete list of available options that can be used to customize your installation.

* Variables showing an 'x' under the `Advanced` column can only be set if the containers advanced functionality is enabled.

#### Core Configuration

| Parameter                  | Description                                                        | Default                |
| -------------------------- | ------------------------------------------------------------------ | ---------------------- |
| `BACKUP_PATH`              | Place to store in app backups                                      | `{DATA_PATH}/backups/` |
| `DELIVER_SECURE_ASSETS`    | Enable serving of HTTPS assets                                     | `FALSE`                |
| `ENABLE_DB_MIGRATE`        | Enable DB Migrations on startup                                    | `TRUE`                 |
| `ENABLE_MINIPROFILER`      | Enable Mini Profiler                                               | `FALSE`                |
| `ENABLE_PRECOMPILE_ASSETS` | Enable Precompiling Assets on statup                               | `TRUE`                 |
| `SETUP_MODE`               | Automatically generate config based on these environment variables | `AUTO`                 |
| `ENABLE_CORS`              | Enable CORS                                                        | `FALSE`                |
| `CORS_ORIGIN`              | CORS Origin                                                        | ``                     |
| `UPLOADS_PATH`             | Path to store Uploads                                              | `{DATA_PATH}/uploads/` |

#### Admin Options

>> Only used on first boot

| Parameter     | Description                                 | Default               | Advanced |
| ------------- | ------------------------------------------- | --------------------- | -------- |
| `ADMIN_USER`  | Username for admin                          | `admin`               |          |
| `ADMIN_EMAIL` | Admin email address                         | `admin@example.com`   |          |
| `ADMIN_PASS`  | Admin password - Must be over 10 characters | `nfrastack-discourse` |          |
| `ADMIN_NAME`  | Admin Name (First and Last)                 | `Admin User`          |          |

#### Log Options

| Parameter                | Description            | Default             | Advanced |
| ------------------------ | ---------------------- | ------------------- | -------- |
| `LOG_FILE`               | Discourse Log File     | `discourse.log`     |          |
| `LOG_LEVEL`              | Discourse Log Level    | `info`              |          |
| `LOG_PATH`               | Path to store logfiles | `/logs/`            |          |
| `PLUGIN_LOG_FILE`        | Plugin operations file | `plugin.log`        |          |
| `UNICORN_LOG_FILE`       | Unicorn Log            | `unicorn.log`       |          |
| `UNICORN_LOG_ERROR_FILE` | Unicorn Error Log      | `unicorn_error.log` |          |
| `SIDEKIQ_LOG_FILE`       | SideKiq Log            | `sidekiq.log`       |          |

#### Performance Options

| Parameter         | Description         | Default | Advanced |
| ----------------- | ------------------- | ------- | -------- |
| `UNICORN_WORKERS` | How many Workers    | `8`     |          |
| `SIDEKIQ_THREADS` | Sidekiq Concurrency | `25`    |          |

#### Database Options

##### Postgresql

| Parameter            | Description                                   | Default | Advanced |
| -------------------- | --------------------------------------------- | ------- | -------- |
| `DB_POOL`            | How many Database connections                 | `8`     |          |
| `DB_PORT`            | Database Port                                 | `5432`  |          |
| `DB_TIMEOUT`         | Timeout for established connection in seconds | `5000`  |          |
| `DB_TIMEOUT_CONNECT` | Connection Timeout in Seconds                 | `5`     |          |
| `DB_USER`            | Username of Database                          |         |          |
| `DB_NAME`            | Database name                                 |         |          |
| `DB_PASS`            | Database Password                             |         |          |
| `DB_HOST`            | Hostname of Database Server                   |         |          |

##### Redis

| Parameter                    | Description                                 | Default | Advanced |
| ---------------------------- | ------------------------------------------- | ------- | -------- |
| `REDIS_DB`                   | Redis Database Number                       | `0`     |          |
| `REDIS_ENABLE_TLS`           | Enable TLS when communication to REDIS_HOST | `FALSE` |          |
| `REDIS_PORT`                 | Redis Host Listening Port                   | `6379`  |          |
| `REDIS_SKIP_CLIENT_COMMANDS` | Skip client commands if unsupported         | `FALSE` |          |

#### SMTP Options

| Parameter             | Description                              | Default         | Advanced |
| --------------------- | ---------------------------------------- | --------------- | -------- |
| `SMTP_AUTHENTICATION` | SMTP Authentication type `plain` `login` | `plain`         |          |
| `SMTP_DOMAIN`         | HELO Domain for remote SMTP Host         | `example.com`   |          |
| `SMTP_HOST`           | SMTP Hostname                            | `postfix-relay` |          |
| `SMTP_USER`           | SMTP Username                            |                 |          |
| `SMTP_PASS`           | SMTP Username                            |                 |          |
| `SMTP_PORT`           | SMTP Port                                | `25`            |          |
| `SMTP_START_TLS`      | Enable STARTTLS on connection            | `TRUE`          |          |
| `SMTP_TLS_FORCE`      | Force TLS on connection                  | `FALSE`         |          |
| `SMTP_TLS_VERIFY`     | TLS Certificate verification             | `none`          |          |

#### Plugins

This image includes a collection of Discourse plugins bundled under `/container/data/discourse/plugins` and supports user-provided plugins set by `PLUGIN_PATH`

| Parameter              | Description                                                              | Default                    |
| ---------------------- | ------------------------------------------------------------------------ | -------------------------- |
| `PLUGIN_PATH`          | Path where plugins are stored                                            | `{DATA_PATH}/plugins/`     |
| `PLUGIN_PRIORITY`      | Which source to prefer when a plugin exists in both `image` and `host`.  | `host`                     |
| `PLUGIN_ENABLED_PATH`  | Where enabled plugins (symlinks) are created for Discourse to load them. | `/app/plugins`             |
| `PLUGIN_ENABLE_<NAME>` | Enable Plugin via normalized name `TRUE` `FALSE`                         |                            |
| `PLUGIN_TOOL_COMMAND`  | Command when configuring plugins on container startup                    | `plugin-tool sync` |

>>`<NAME>` may be the short plugin name or include a `discourse_`/`discourse-` prefix.
>> Examples:
>> `PLUGIN_ENABLE_CAKEDAY=TRUE`, `PLUGIN_ENABLE_DISCOURSE_APPLE_AUTH=TRUE`, `PLUGIN_ENABLE_APPLE_AUTH=TRUE`.

Normalization rules:
- Environment names are normalized to a short plugin name by lowercasing and converting `_` to `-`, and stripping a leading `discourse-` or `discourse_` if present. For example `PLUGIN_ENABLE_APPLE_AUTH` -> `apple-auth`, which matches image folder `discourse-apple-auth`.


Plugins Enabled from Image, override with `FALSE` value, Use `plugin-tool list all` to get full list.

| Plugin Environment Variable   | Enabled |
| ----------------------------- | ------- |
| `PLUGIN_ENABLE_CHECKLIST`     |         `TRUE` |
| `PLUGIN_ENABLE_DETAILS`       |         `TRUE` |
| `PLUGIN_ENABLE_NARRATIVE_BOT` |         `TRUE` |
| `PLUGIN_ENABLE_POLL`          |         `TRUE` |
| `PLUGIN_ENABLE_PRESENCE`      |         `TRUE` |
| `PLUGIN_ENABLE_REACTIONS`     |         `TRUE` |
| `PLUGIN_ENABLE_STYLEGUIDE`    |         `TRUE` |

>> Notes
>> Host plugins (in `PLUGIN_PATH`) take precedence by default. Set `PLUGIN_PRIORITY=image` to prefer the packaged image plugins instead.
>> Enabling a plugin creates a symlink in `PLUGIN_ENABLED_PATH` with the short name (e.g. `ai`) pointing to the chosen source directory. If a plugin folder exists in a host-mounted docker volume you can modify it and it will be used when `PLUGIN_PRIORITY=host`.

##### Manually working with Plugins

This image includes a helper script at `/usr/local/bin/plugin-tool` to manage plugins. Important commands:

High-level commands: (also available via `plugin-tool help`):

- `plugin-tool list all` — List all available plugins (image + `PLUGIN_PATH`).
- `plugin-tool list enabled` — List plugins enabled via environment flags (`PLUGIN_ENABLE_* = TRUE`). Alias: `core`.
- `plugin-tool list disabled` — List available plugins that are not enabled. Alias: `optional`.
- `plugin-tool enable <name>` — Enable a plugin by friendly name. Normalizes names (case/underscores) and strips `discourse-` prefix. Examples: `ai`, `apple-auth`, `cakeday`.
- `plugin-tool install <name>` — Copy the image plugin into `PLUGIN_PATH` so you can edit it in your persistent volume.
- `plugin-tool remove <name>` / `plugin-tool uninstall <name>` — Remove enabled symlink or uninstall the copied plugin from `PLUGIN_PATH`.
- `plugin-tool update <name>` — If host plugin is a git repo, attempt `git pull`; otherwise replace the host copy from the image (a backup is created).
- `plugin-tool reset` — Remove all enabled plugin symlinks from `PLUGIN_ENABLED_PATH` (does not delete real directories).
- `plugin-tool status` — Show enabled symlinks, their targets, and host/image version identifiers (git short SHA, `VERSION`/`.plugin-version`, or checksum).

Environment flags and arguments are normalized before lookup. For example:

- `PLUGIN_ENABLE_CAKEDAY=TRUE` -> `cakeday` -> matches `discourse-cakeday` in the image.
- `PLUGIN_ENABLE_APPLE_AUTH=TRUE` -> `apple-auth` -> matches `discourse-apple-auth`.

When enabling a plugin the resolver looks for variants in this order (by default):
1. Host plugin directory in `PLUGIN_PATH` (e.g. `/data/plugins/apple-auth` or `/data/plugins/discourse-apple-auth`).
2. Image plugin directory under `/container/data/discourse/plugins`.

Set `PLUGIN_PRIORITY=image` to invert precedence and prefer the image copy when both exist.

Behaviour notes

- `enable` creates a symlink at `PLUGIN_ENABLED_PATH/<shortname>` that points to the chosen source directory.
  For example `plugin-tool enable ai` -> `/app/plugins/ai -> /data/plugins/discourse-ai` or `/container/data/discourse/plugins/discourse-ai`.
- The tool will refuse to enable if the target path already exists and is not a symlink to avoid accidental data loss.
- `install` copies the image folder name (for example `discourse-ai`) into `PLUGIN_PATH`, if you need to modify things.
- `status` prints a readable summary; it uses git short SHAs when `.git` exists, else `VERSION`/`.plugin-version`, otherwise a checksum.

Examples

Enable the `discourse-ai` plugin (prefers host copy if present):

```bash
PLUGIN_ENABLE_AI=TRUE

/usr/local/bin/plugin-tool enable ai
```

Enable all plugins that have `PLUGIN_ENABLE_*` set to true (batch mode):

```bash
PLUGIN_ENABLE_CAKEDAY=TRUE
PLUGIN_ENABLE_APPLE_AUTH=TRUE

/usr/local/bin/plugin-tool enable env
```

Copy the image plugin into the persistent plugins directory so you can modify it, still needs to be enabled:

```bash
/usr/local/bin/plugin-tool install ai
```

Uninstall a host plugin and remove its enabled symlink:

```bash
/usr/local/bin/plugin-tool uninstall ai
```

Reset enabled plugins (remove symlinks):

```bash
usr/local/bin/plugin-tool reset
```

Show current enabled plugins and versions:

```bash
/usr/local/bin/plugin-tool status
```

Reconcile environment-driven enables/disables (sync examples):

```bash
# Preview changes without modifying filesystem (dry-run):
PLUGIN_ENABLE_AI=TRUE
PLUGIN_ENABLE_OLD=FALSE

/usr/local/bin/plugin-tool sync --dry-run

# Apply changes and prune any enabled symlink not explicitly set TRUE:
/usr/local/bin/plugin-tool sync --prune
```

If you need more detail, run `plugin-tool help` inside the container to see the full command reference.

Advanced install examples (git & archives)

Install directly from a git repository (auto-derived name):

```bash
/usr/local/bin/plugin-tool install https://github.com/discourse/discourse-ai.git
```

Install from a git repo into an explicit name and branch:

```bash
/usr/local/bin/plugin-tool install mymod https://github.com/org/repo.git my-branch
```

Install from an archive URL (zip/tar.gz/zst):

```bash
/usr/local/bin/plugin-tool install https://example.com/plugins/discourse-foo.tar.gz
```

## Users and Groups

| Type  | Name        | ID   |
| ----- | ----------- | ---- |
| User  | `discourse` | 9009 |
| Group | `discourse` | 9009 |

### Networking

| Port   | Protocol | Description    |
| ------ | -------- | -------------- |
| `3000` | tcp      | Unicorn Daemon |

* * *

## Maintenance

### Shell Access

For debugging and maintenance, `bash` and `sh` are available in the container.

Try using the command `rake --tasks`

See above information regarding plugins.


## Support & Maintenance

* For community help, tips, and community discussions, visit the [Discussions board](/discussions).
* For personalized support or a support agreement, see [Nfrastack Support](https://nfrastack.com/).
* To report bugs, submit a [Bug Report](issues/new). Usage questions will be closed as not-a-bug.
* Feature requests are welcome, but not guaranteed. For prioritized development, consider a support agreement.
* Updates are best-effort, with priority given to active production use and support agreements.

## References

* <https://www.discourse.org>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
