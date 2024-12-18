# Container Manager dind image

This image is supposed to be used in connection with the [Container Manager](https://github.com/dr460nf1r3/container-manager).

## Usage

The following environment variables are available:

- `CI_BRANCH`: the branch to checkout after cloning the repository, if no commit is specified
- `CI_REPO_URL`: the URL of the repository to clone
- `CI_BUILD_SCRIPT`: the script to run after cloning the repository, can be mounted in as a volume or passed as part of the cloned repository. This should build the compose file, which will be used to start the containers via dind. The script should output the compose file to `$COMPOSE_DIR` (default: `/work/compose`).

Optioonally, the following environment variables can be set:

- `CI_BUILD_SCRIPT_ARGS`: arguments to pass to the build script
- `CI_CHECKOUT`: the commit hash or tag to checkout after cloning the repository
