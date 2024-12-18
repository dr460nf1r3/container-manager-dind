#!/usr/bin/env bash

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

    if [ -n "$CI_ADD_PACKAGES" ]; then
        IFS=':'
        read -r -a CI_PACKAGE_ARRAY <<< "$CI_ADD_PACKAGES"
        apk add --no-cache "${CI_PACKAGE_ARRAY[@]}"
    fi

    mkdir /work
    mkdir -p "$COMPOSE_DIR"

    git clone --depth 20 "$CI_REPO_URL" "$CLONE_DIR"
    cd "$CLONE_DIR" || exit
    git checkout "$CI_CHECKOUT"

    # Run the build script
    if [ -f "$CI_BUILD_SCRIPT" ]; then
        chmod +x "$CI_BUILD_SCRIPT"
        
        # shellcheck disable=SC2068
        "$CI_BUILD_SCRIPT" ${CI_BUILD_SCRIPT_ARGS[@]}
    fi
}

function main() {
    init

    pushd "$COMPOSE_DIR" || exit
    docker compose up
    popd || exit
}

main
