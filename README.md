# nfrastack/container-discourse

## About

This will build a container image for [Discourse](https://www.discourse.org/) - A web based discussion forum.

* Unlike the official Discourse image, this is meant to be self contained without requiring a base image or use the `launcher`
* Flexible Volatile Storage

## Maintainer

* [Nfrastack](https://www.nfrastack.com)

## Table of Contents

* [About](#about)
* [Maintainer](#maintainer)
* [Table of Contents](#table-of-contents)
* [Prerequisites and Assumptions](#prerequisites-and-assumptions)
* [Installation](#installation)
  * [Prebuilt Images](#prebuilt-images)
  * [Multi-Architecture Support](#multi-architecture-support)
  * [Quick Start](#quick-start)
  * [Persistent Storage](#persistent-storage)
* [Environment Variables](#environment-variables)
  * [Base Images used](#base-images-used)
  * [Core Configuration](#core-configuration)
  * [Admin Options](#admin-options)
  * [Log Options](#log-options)
  * [Performance Options](#performance-options)
  * [Database Options](#database-options)
    * [Postgresql](#postgresql)
    * [Redis](#redis)
  * [SMTP Options](#smtp-options)
  * [Plugins](#plugins)
* [Users and Groups](#users-and-groups)
  * [Networking](#networking)
* [Maintenance](#maintenance)
  * [Shell Access](#shell-access)
* [Support & Maintenance](#support--maintenance)
* [References](#references)
* [License](#license)

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

| Parameter     | Description                                 | Default               |
| ------------- | ------------------------------------------- | --------------------- |
| `ADMIN_USER`  | Username for admin                          | `admin`               |
| `ADMIN_EMAIL` | Admin email address                         | `admin@example.com`   |
| `ADMIN_PASS`  | Admin password - Must be over 10 characters | `nfrastack-discourse` |
| `ADMIN_NAME`  | Admin Name (First and Last)                 | `Admin User`          |

#### Log Options

| Parameter                | Description            | Default             |
| ------------------------ | ---------------------- | ------------------- |
| `LOG_FILE`               | Discourse Log File     | `discourse.log`     |
| `LOG_LEVEL`              | Discourse Log Level    | `info`              |
| `LOG_PATH`               | Path to store logfiles | `/logs/`            |
| `UNICORN_LOG_FILE`       | Unicorn Log            | `unicorn.log`       |
| `UNICORN_LOG_ERROR_FILE` | Unicorn Error Log      | `unicorn_error.log` |
| `SIDEKIQ_LOG_FILE`       | SideKiq Log            | `sidekiq.log`       |

#### Performance Options

| Parameter         | Description         | Default |
| ----------------- | ------------------- | ------- |
| `UNICORN_WORKERS` | How many Workers    | `8`     |
| `SIDEKIQ_THREADS` | Sidekiq Concurrency | `25`    |

#### Database Options

##### Postgresql

| Parameter            | Description                                   | Default |
| -------------------- | --------------------------------------------- | ------- |
| `DB_POOL`            | How many Database connections                 | `8`     |
| `DB_PORT`            | Database Port                                 | `5432`  |
| `DB_TIMEOUT`         | Timeout for established connection in seconds | `5000`  |
| `DB_TIMEOUT_CONNECT` | Connection Timeout in Seconds                 | `5`     |
| `DB_USER`            | Username of Database                          |         |
| `DB_NAME`            | Database name                                 |         |
| `DB_PASS`            | Database Password                             |         |
| `DB_HOST`            | Hostname of Database Server                   |         |

##### Redis

| Parameter                    | Description                                 | Default |
| ---------------------------- | ------------------------------------------- | ------- |
| `REDIS_DB`                   | Redis Database Number                       | `0`     |
| `REDIS_ENABLE_TLS`           | Enable TLS when communication to REDIS_HOST | `FALSE` |
| `REDIS_PORT`                 | Redis Host Listening Port                   | `6379`  |
| `REDIS_SKIP_CLIENT_COMMANDS` | Skip client commands if unsupported         | `FALSE` |

#### SMTP Options

| Parameter             | Description                              | Default         |
| --------------------- | ---------------------------------------- | --------------- |
| `SMTP_AUTHENTICATION` | SMTP Authentication type `plain` `login` | `plain`         |
| `SMTP_DOMAIN`         | HELO Domain for remote SMTP Host         | `example.com`   |
| `SMTP_HOST`           | SMTP Hostname                            | `postfix-relay` |
| `SMTP_USER`           | SMTP Username                            |                 |
| `SMTP_PASS`           | SMTP Username                            |                 |
| `SMTP_PORT`           | SMTP Port                                | `25`            |
| `SMTP_START_TLS`      | Enable STARTTLS on connection            | `TRUE`          |
| `SMTP_TLS_FORCE`      | Force TLS on connection                  | `FALSE`         |
| `SMTP_TLS_VERIFY`     | TLS Certificate verification             | `none`          |

#### Plugins

Presently not working

| Parameter                          | Description                   | Default                |
| ---------------------------------- | ----------------------------- | ---------------------- |
| `PLUGIN_PATH`                      | Path where plugins are stored | `{DATA_PATH}/plugins/` |
| `PLUGIN_ENABLE_AUTOMATION`         |                               | `FALSE`                |
| `PLUGIN_ENABLE_ASSIGN`             |                               | `FALSE`                |
| `PLUGIN_ENABLE_CHAT_INTEGRATION`   |                               | `FALSE`                |
| `PLUGIN_ENABLE_CHECKLIST`          |                               | `FALSE`                |
| `PLUGIN_ENABLE_DETAILS`            |                               | `TRUE`                 |
| `PLUGIN_ENABLE_EVENTS`             |                               | `FALSE`                |
| `PLUGIN_ENABLE_FOOTNOTES`          |                               | `FALSE`                |
| `PLUGIN_ENABLE_FORMATTING_TOOLBAR` |                               | `FALSE`                |
| `PLUGIN_ENABLE_LAZY_VIDEOS`        |                               | `TRUE`                 |
| `PLUGIN_ENABLE_LOCAL_DATES`        |                               | `TRUE`                 |
| `PLUGIN_ENABLE_MERMAID`            |                               | `TRUE`                 |
| `PLUGIN_ENABLE_NARRATIVE_BOT`      |                               | `TRUE`                 |
| `PLUGIN_ENABLE_POLLS`              |                               | `TRUE`                 |
| `PLUGIN_ENABLE_POST_VOTING`        |                               | `FALSE`                |
| `PLUGIN_ENABLE_PRESENCE`           |                               | `TRUE`                 |
| `PLUGIN_ENABLE_PUSH_NOTIFICATIONS` |                               | `FALSE`                |
| `PLUGIN_ENABLE_SAME_ORIGIN`        |                               | `FALSE`                |
| `PLUGIN_ENABLE_SOLVED`             |                               | `FALSE`                |
| `PLUGIN_ENABLE_SPOILER_ALERT`      |                               | `FALSE`                |
| `PLUGIN_ENABLE_STYLEGUIDE`         |                               | `TRUE`                 |
| `PLUGIN_ENABLE_VOTING`             |                               | `FALSE`                |

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
