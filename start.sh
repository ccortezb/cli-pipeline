#!/bin/bash

docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock --name cli-pipeline -itd pipelineai/cli-pipeline:master
