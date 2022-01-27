# testflight

## Introduction

This project provides a means to build a docker image containing:
1. Zeek LTS (4.0.4)
2. Flightsim (latest release version)
3. asoc-zeek

A control script is also provided (`tf.sh`) as the container entry point.  When the
container is started, `tf.sh` does the following:
1. Starts Zeek via the `asoc-zeek` script
2. Runs all flightsim simulation modules
    - Network telemetry will be collected and sent by Zeek to aSOC
3. Teardown

The goal is to have a cohesive 'service' to test wheather aSOC infrastructure is generating
proper events (at least for those threats that flightsim can simulate).  The other half of
this goal is realized using redash.hq.alphasoc.net.

## Building an Image

Pull the repository, and `cd` to its root directory.  The below will create an image _testflight:latest_:

    docker build --tag=testflight .

## Running the Image

Assuming you want to run the container locally, it's sufficient to:

    docker run --rm --dns 8.8.8.8 -v ~/.ssh:/root/.ssh:ro -e ORG_ID="YOUR_ORGANIZATION_ID" -e STAGING=false testflight:latest

In this case, the following happens:
1. `--rm` will remove the container after it finishes
2. `--dns` should force the container to use `8.8.8.8` for DNS lookups, preventing cases
   where DNS requests are forwarded to host, thus circumenting Zeek detection.
   [DNS](https://docs.docker.com/config/containers/container-networking/#dns-services)
3. `-v` mounts your local `.ssh/` directory as roots on the container.  Assuming you have
   SSH configured correctly, this will allow Zeek to upload telemetry to aSOC SFTP servers.
   For information how to configure this, see:
   [asoc-zeek -> SSH auth](https://github.com/mrozitron/asoc-zeek#sshauthentication)
4. `-e` passes various environment variables to the container.  `ORG_ID` is needed.  `STAGING`
   is `false` by default (you can omit it from the commandline).  If you're a developer and
   communicating with staging services, set it to `true`.
