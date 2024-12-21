#!/usr/bin/env bash

set -eo pipefail

COMPOSE_DIR="/work/compose"
CLONE_DIR="/work/repo"

if [ -z "$CI_BRANCH" ] || [ -z "$CI_REPO_URL" ] || [ -z "$CI_BUILD_SCRIPT" ]; then
    echo "You need to provide the following environment variables:"
    echo "CI_BRANCH: The branch to checkout"
    echo "CI_REPO_URL: The repository URL"
    echo "CI_BUILD_SCRIPT: The build script to run"
    exit 1
fi

if [ -z "$CI_CHECKOUT" ]; then
    CI_CHECKOUT="$CI_BRANCH"
fi

function init() {
    # Run the original entrypoint, and wait for the daemon to start
    dockerd-entrypoint.sh &
    sleep 10

    # We don't want to run the init script if it has already been run
    if [ -f "$COMPOSE_DIR/.init_done" ]; then
        return
    else
        init_first_time
        touch "$COMPOSE_DIR/.init_done"
    fi
}

function init_first_time() {
    if [ -n "$CI_ADD_PACKAGES" ]; then
        IFS=':'
        read -r -a CI_PACKAGE_ARRAY <<<"$CI_ADD_PACKAGES"
        apk add --no-cache "${CI_PACKAGE_ARRAY[@]}"
    fi

    mkdir -p "$COMPOSE_DIR"

    git clone --depth 20 "$CI_REPO_URL" "$CLONE_DIR"
    cd "$CLONE_DIR" || exit 2
    git checkout "$CI_CHECKOUT"

    # Run the build script
    if [ -f "$CI_BUILD_SCRIPT" ]; then
        chmod +x "$CI_BUILD_SCRIPT"

        # shellcheck disable=SC2068
        "$CI_BUILD_SCRIPT" ${CI_BUILD_SCRIPT_ARGS[@]}
    else 
        echo "Build script not found"
        exit 1
    fi

    # Authenticate, if needed
    if [ -n "$CI_DOCKERHUB_USER" ] && [ -n "$CI_DOCKERHUB_PASS" ]; then
        if [ -z "$CI_REGISTRY" ]; then
            CI_REGISTRY="https://index.docker.io/v1/"
        fi
        echo "$CI_DOCKERHUB_PASS" | docker login -u "$CI_DOCKERHUB_USER" --password-stdin "$CI_REGISTRY"
    fi
}

function main() {
    init

    pushd "$COMPOSE_DIR" || exit 2
    docker compose up
    popd || exit 2
}

main
