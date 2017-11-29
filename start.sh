#!/bin/bash

docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock --name cli-docker -itd pipelineai/cli-docker:master
