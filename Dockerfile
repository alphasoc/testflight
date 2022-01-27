FROM debian:bullseye-slim
# Flightsim release, v2.2.1
ARG FS_VER=2.2.1
WORKDIR /scratch
COPY . .
# Install flightsim, asoc-zeek script and Zeek-LTS.
# asoc-zeek will drive Zeel config generation and startup.
RUN set -eux; \
	    apt-get update; \
	    apt-get install -y --no-install-recommends \
                ca-certificates \
                curl \
                gnupg \
        ; \
        curl -fsSL https://raw.githubusercontent.com/mrozitron/asoc-zeek/master/bin/asoc-zeek -o asoc-zeek; \
        # Make asoc-zeek executable.
        chmod +x asoc-zeek; \
        curl -fsSL https://github.com/alphasoc/flightsim/releases/download/v${FS_VER}/flightsim_${FS_VER}_linux_64-bit.deb -o flightsim.deb; \
        apt-get install -y ./flightsim.deb; \
        echo 'deb http://download.opensuse.org/repositories/security:/zeek/Debian_11/ /' | tee /etc/apt/sources.list.d/security:zeek.list; \
        curl -fsSL https://download.opensuse.org/repositories/security:zeek/Debian_11/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null; \
        apt-get update; \
        apt-get install -y zeek-lts
# Add path to Zeek binaries (persists on container start).
ENV PATH="/opt/zeek/bin:${PATH}"

# asoc-zeek needs an interface and an organization id.
# The interface will be set manually here, as it's beyond the scope of host.
ENV INTF=eth0
# Must be passed via docker run.
ENV ORG_ID="foo"
# Staging bool.  By default, use production services rather than dev/staging.
ENV STAGING=false

ENTRYPOINT ["/scratch/tf.sh"]