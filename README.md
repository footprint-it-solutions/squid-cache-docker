# Squid Cache Docker

Builds Docker images for Squid Cache. One uses an Alpine base image the other uses Debian. Both are multi-stage builds, to keep the finished image size to a minimum. 

## Usage

Accept/change the major and minor versions in the Dockerfile of your choice and build:

`docker build . -f alpine.Dockerfile -t squid-cache:6.6-alpine`

...or specify at the command line:

```
export MAJOR=6
export MINOR=5
docker build . --build-arg SQUID_MAJOR_VERSION=$MAJOR --build-arg SQUID_MINOR_VERSION=$MINOR -f alpine.Dockerfile -t squid-cache:$MAJOR.$MINOR-alpine
```
