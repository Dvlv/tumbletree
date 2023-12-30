# This is the Containerfile for your custom image.

# Instead of adding RUN statements here, you should consider creating a script
# in `config/scripts/`. Read more in `modules/script/README.md`

# This Containerfile takes in the recipe, version, and base image as arguments,
# all of which are provided by build.yml when doing builds
# in the cloud. The ARGs have default values, but changing those
# does nothing if the image is built in the cloud.

# !! Warning: changing these might not do anything for you. Read comment above.
ARG IMAGE_MAJOR_VERSION=latest
ARG BASE_IMAGE_URL=registry.opensuse.org/opensuse/tumbleweed:latest

FROM ${BASE_IMAGE_URL}:${IMAGE_MAJOR_VERSION}

# The default recipe is set to the recipe's default filename
# so that `podman build` should just work for most people.
ARG RECIPE=recipe.yml 
# The default image registry to write to policy.json and cosign.yaml
ARG IMAGE_REGISTRY=registry.opensuse.org/opensuse


COPY cosign.pub /usr/share/ublue-os/cosign.pub


# Copy build scripts & configuration
COPY build.sh /tmp/build.sh
COPY config /tmp/config/
COPY ostree-container.sh /tmp/ostree-container.sh
COPY ostree-container-commit.sh /tmp/config/ostree-container-commit.sh

# Copy modules
# The default modules are inside ublue-os/bling
# Custom modules overwrite defaults
COPY modules /tmp/modules/

# `yq` is used for parsing the yaml configuration
# It is copied from the official container image since it's not available as an RPM.
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

RUN zypper --non-interactive install libostree libostree-devel libostree-grub2 cargo wget libopenssl-devel gcc git autoconf automake libtool rpm-devel json-glib-devel libarchive-devel libpolkit-gobject-1-0 polkit-devel awk gcc-c++ libsolv-devel librepo-devel systemd-devel libcap-devel libjson-c-devel libmodulemd-devel sqlite3-devel cmake libpkgconf-devel libgpgme-devel libgpgmepp-devel libxml++-devel cppunit-devel gtk-doc check-devel dnf libsmartcols-devel libdnf-devel docbook-xsl-*

RUN /tmp/ostree-container.sh

# Run the build script, then clean up temp files and finalize container build.
RUN chmod +x /tmp/build.sh && /tmp/build.sh && \
    rm -rf /tmp/* /var/* 

RUN /tmp/ostree-container-commit.sh

