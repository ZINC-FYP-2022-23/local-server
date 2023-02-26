# Dockerfile for running production version of grader in a Docker container.
#
# It expects the following files to be present within the Docker container:
#  - "/srv/zinc-grader-daemon.jar" - the grader daemon jar file
#  - "/srv/config.properties" - the grader configuration file
#
# If you're running this container in a Docker compose server, make sure to mount the zinc-grader-daemon.jar and config.properties
# files into the container's `/srv` directory. The zinc-grader-daemon.jar file can be obtained by running `./gradlew daemon:shadowJar`
# in the root of "grader" repo.

FROM openjdk:11-jdk-slim AS base

RUN apt-get update
RUN apt-get -y install tzdata
RUN apt-get -y --purge autoremove
RUN apt-get clean all
ENV TZ Asia/Hong_Kong

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /srv

FROM base AS prod
CMD java \
  -Xmx2048M \
  -Dgrader.profile="$PWD/config.properties" \
  -jar ./zinc-grader-daemon.jar