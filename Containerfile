# SPDX-FileCopyrightText: © 2026 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="Discourse" \
        org.opencontainers.image.description="Forum software" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/discourse" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-discourse/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-discourse.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    DISCOURSE_VERSION="v2026.2.0" \
    DISCOURSE_REPO_URL="https://github.com/discourse/discourse" \
    OXIPNG_VERSION="v9.1.5" \
    OXIPNG_REPO_URL="https://github.com/oxipng/oxipng" \
    DISCOURSE_USER \
    DISCOURSE_GROUP

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    DISCOURSE_USER=${DISCOURSE_USER:-"discourse"} \
    DISCOURSE_GROUP=${DISCOURSE_GROUP:-"discourse"} \
    RUBY_ALLOCATOR=/usr/lib/libjemalloc.so.2 \
    RAILS_ENV=production \
    RUBY_GC_MALLOC_LIMIT=90000000 \
    RUBY_GLOBAL_METHOD_CACHE_SIZE=131072 \
    PATH=/usr/local/share/pnpm:${PATH} \
    IMAGE_NAME="nfrastack/discourse" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-discourse/"

EXPOSE 3000

RUN echo "" && \
    BUILD_ENV=" \
                10-nginx/ENABLE_NGINX=FALSE \
                10-nginx/NGINX_MODE=PROXY \
                10-nginx/NGINX_PROXY_URL=http://127.0.0.1:[env:LISTEN_PORT] \
              " \
              && \
    DISCOURSE_BUILD_DEPS_DEBIAN=" \
                                        gettext \
                                        libbz2-dev \
                                        libfreetype6-dev \
                                        libicu-dev \
                                        libjpeg-dev \
                                        libpq-dev \
                                        libtiff-dev \
                                        libxml2-dev \
                                        libxslt-dev \
                                " && \
    DISCOURSE_RUN_DEPS_DEBIAN=" \
                                    advancecomp \
                                    brotli \
                                    ghostscript \
                                    gifsicle \
                                    git \
                                    gsfonts \
                                    imagemagick \
                                    jhead \
                                    jpegoptim \
                                    libicu76 \
                                    libjpeg-turbo-progs \
                                    libpq5 \
                                    libxml2 \
                                    netcat-openbsd \
                                    nodejs \
                                    optipng \
                                    pngquant \
                                    postgresql-client \
                                    postgresql-contrib \
                                    unzip \
                              " && \
    SHARED_BUILD_DEPS_DEBIAN="  \
                                bison \
                                build-essential \
                                g++ \
                                gcc \
                                libssl-dev \
                                make \
                                patch \
                                pkg-config \
                            " && \
    \
    source /container/base/functions/container/build && \
    container_build_log image && \
    create_user "${DISCOURSE_USER}" 9009 "${DISCOURSE_GROUP}" 9009 /app && \
    package repo add node 24 && \
    package repo add postgres && \
    package update && \
    package upgrade && \
    package install \
                    DISCOURSE_BUILD_DEPS \
                    DISCOURSE_RUN_DEPS \
                    SHARED_BUILD_DEPS \
                    SHARED_RUN_DEPS \
                    && \
    \
    package build ruby 3.4 && \
    \
    mkdir -p /usr/src/oxipng && \
    curl -sSL "${OXIPNG_REPO_URL}"/releases/download/"${OXIPNG_VERSION}"/oxipng-"${OXIPNG_VERSION/v/}"-$(container_info arch)-unknown-linux-gnu.tar.gz | tar xvfz - --strip 1 -C /usr/src/oxipng && \
    mv /usr/src/oxipng/oxipng /usr/local/bin/oxipng && \
    container_build_log add "OxiPNG" "${OXIPNG_VERSION}" "pkg ${OXIPNG_REPO_URL}" && \
    \
    npm install --global \
                            svgo \
                            terser \
                            uglify-js \
                            pnpm@10 \
                            && \
    rm -rf /app && \
    clone_git_repo "${DISCOURSE_REPO_URL}" "${DISCOURSE_VERSION}" /app && \
    BUNDLER_VERSION="$(grep "BUNDLED WITH" Gemfile.lock -A 1 | grep -v "BUNDLED WITH" | tr -d "[:space:]")" && \
    gem install bundler:"${BUNDLER_VERSION}" && \
    container_build_log add "Bundler" "${BUNDLER_VERSION}" "gem" && \
    chown -R "${DISCOURSE_USER}":"${DISCOURSE_GROUP}" /app && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle config --local path ./vendor/bundle && \
    bundle config set --local deployment true && \
    bundle config set --local without development test && \
    bundle install --jobs $(nproc) && \
    cd /app && \
    #sudo -u "${DISCOURSE_USER}" git config --add safe.directory /app && \
    mkdir -p /usr/local/share/pnpm && \
    pnpm install --frozen-lockfile && \
    pnpm cache delete && \
    find /app/vendor/bundle -name tmp -type d -exec rm -rf {} + && \
    curl -sSL https://git.io/GeoLite2-ASN.mmdb -o /app/vendor/data/GeoLite2-ASN.mmdb && \
    curl -sSL https://git.io/GeoLite2-City.mmdb -o /app/vendor/data/GeoLite2-City.mmdb && \
    ln -sf "$(which convert)" "/usr/bin/magick" && \
    mkdir -p /container/data/discourse/plugins && \
    mv /app/plugins/* /container/data/discourse/plugins && \
    rm -rf /container/data/discourse/plugins/discourse-nginx-performance-report && \
    chown -R "${DISCOURSE_USER}":"${DISCOURSE_GROUP}" \
                                                    /container/data/discourse \
                                                    /app \
                                                    && \
    container_build_log add "Discourse" "${DISCOURSE_VERSION}" "${DISCOURSE_REPO_URL}" && \
    package remove \
                    DISCOURSE_BUILD_DEPS \
                    SHARED_BUILD_DEPS \
                    && \
    package cleanup && \
    rm -rf \
            /app/.cursor \
            /app/.devcontainer \
            /app/.editorconfig \
            /app/.github \
            /app/.prettier* \
            /app/.skills \
            /app/.vscode \
            /app/.vscode-sample \
            /app/.zed \
            /app/bin/docker \
            /app/AGENTS.md \
            /app/AI-AGENTS.md \
            /app/GEMINI.md \
            /app/CLAUDE.md \
            /app/Brewfile \
            /app/CODEOWNERS \
            /app/CONTRIBUTING.md \
            /app/config/dev_defaults.yml \
            /app/config/*.sample \
            /app/config/logrotate.conf \
            /app/config/multisite.yml.production-sample \
            /app/config/nginx* \
            /app/config/puma* \
            /app/config/unicorn_upstart.conf \
            /app/deploy.rb.sample \
            /app/d \
            /app/discourse.sublime-project \
            /app/install-imagemagick \
            /app/lefthook.yml \
            /app/test \
            /app/translator.yml \
            /app/vendor/bundle/ruby/*/cache/* \
            && \
    package remove && \
    package cleanup

COPY rootfs /
