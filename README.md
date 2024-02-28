# docker-az-cli

[![CircleCI](https://circleci.com/gh/aegirops/docker-az-cli.svg?style=svg)](https://circleci.com/gh/aegirops/docker-az-cli)

## Description

Docker with az cli and kubectl for CI/CD purpose

This image is based on debian bookworm slim and contains:

- az cli
- Python 3.9.2
- Kubectl
- Curl
- Git
- Docker cli
- Docker compose cli
- Jq
- ytt v0.45.3
- postgresql-client-15
- nslookup
- s3cmd

This image is intended to be used in a gke CI/CD environment.

Other flavors are available containing Nodejs 18.

## DockerHub

Available publicly on:

- https://hub.docker.com/r/aegirops/az-cli
