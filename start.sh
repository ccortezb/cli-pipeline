#!/bin/bash

docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock --name kubernetes -itd pipelineai/kubernetes:master
