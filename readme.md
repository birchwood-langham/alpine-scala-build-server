# Alpine Linux Scala Build Server

This is a docker image that can be used to compile Scala projects. The image should be used as part of a multi-stage
build to compile the Scala code and create a fat jar using SBT's assembly plugin. 

The jar can be copied to the target Docker image to be deployed.

To create the image, run the provided build script.

```bash
./build.sh
```

## Usage

The following environment variables are supported when starting the build server:

| Environment Variable | Required | Notes | Example |
| -------------------- | -------- | ----- | ------- |
| PROJECT_PATH | Y | The path to the remote repository (do not include the http://gitlab.com/) | bl-paladin/nsa-backoffice/go-projects/go-protobuf-messages.git |
| OUTPUT_DIR | Y | Where to write the output of the build | /output |
| TOKEN | N | The access token to the repo account for private accounts | Secret! Don't tell anyone! |
| SONATYPE_HOST | N | Host for your Sonatype Nexus server | nexus.mydomain.com |
| SONATYPE_USER | N | User name for the Sonatype Nexus server | myuser |
| SONATYPE_PASS | N | Password for the Sonatype Nexus server | secret! |
| BRANCH | N | Specify the branch to check out and buildd | hotfix/my-hotfix |
| TAG | N | Specify a specific tag to checkout and build | v1.0.0 |
| USE_GITLAB | N | Checkout the code from GitLab instead of GitHub | |
| CREATE_TARBALL | N | If set to true, a tarball with all the project code will be zipped and placed in the output folder with the executable | |

### Example

The following snippet will launch a build server and pull the project from GitHub and put the executable generated jar
in the specified output path. The output path is volume mapped to your current directory on the docker host.

```bash
docker run --rm -v $PWD:/output \
    -e PROJECT_PATH=path/to/project.git \
    -e OUTPUT_DIR=/output \
    birchwoodlangham/alpine-scala-build-server:latest
```

To check out the project from GitLab instead of GitHub:

```bash
docker run --rm -v $PWD:/output \
    -e PROJECT_PATH=path/to/project.git \
    -e OUTPUT_DIR=/output \
    -e USE_GITLAB=true \
    birchwoodlangham/alpine-scala-build-server:latest
```

For private repos, you need to provide an access token:

```bash
docker run --rm -v $PWD:/output \
    -e PROJECT_PATH=path/to/project.git \
    -e OUTPUT_DIR=/output \
    -e TOKEN='myverysecrettoken'
    birchwoodlangham/alpine-scala-build-server:latest
```

And for GitLab:

```bash
docker run --rm -v $PWD:/output \
    -e PROJECT_PATH=path/to/project.git \
    -e OUTPUT_DIR=/output \
    -e TOKEN='myverysecrettoken'
    -e USE_GITLAB=true \
    birchwoodlangham/alpine-scala-build-server:latest
```

If your project needs to access a private Sonatype Nexus registry to pull libraries that you need, you can provide the host
and credentials to use:

```bash
docker run --rm -v $PWD:/output \
    -e PROJECT_PATH=path/to/project.git \
    -e OUTPUT_DIR=/output \
    -e SONATYPE_HOST=nexus.domain.com \
    -e SONATYPE_USER=user \
    -e SONATYPE_PASS=secret! \
    birchwoodlangham/alpine-scala-build-server:latest
```

### Branches and Tags

If your project is not on the master branch, or you just want to build from a particular branch instead of the master branch, you can specify the branch to
check out your code from by setting the BRANCH environment variable

If not provided, the master branch will be used to do the build, to use a release tag instead, provide the Tag to use by setting the TAG environment variable.

> NOTE:
> 
> Do not specify both branch and tag environment variables, it doesn't make sense to do so, you're either compile a specific version on a specific branch
> or you're compiling a tagged version.

#### Branches and Tags Examples

1. The following snippet will launch a build server and pull the project from a development branch using the token you specify and put the executable generated 
in the specified output path. The output path is volume mapped to your current directory on the docker host.

    ```bash
    docker run --rm -v $PWD:/output \
        -e BRANCH=develop \
        -e PROJECT_PATH=path/to/project.git \
        -e OUTPUT_DIR=/output \
        birchwoodlangham/alpine-scala-build-server:latest
    ```

2. To build from a specific release tag, supply the TAG environment variable

    ```bash
    docker run --rm -v $PWD:/output \
        -e TAG=v1.0.0 \
        -e PROJECT_PATH=path/to/project.git \
        -e OUTPUT_DIR=/output \
        birchwoodlangham/alpine-scala-build-server:latest
    ```
