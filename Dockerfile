# See here for image contents: https://github.com/microsoft/vscode-dev-containers/blob/main/containers/ubuntu/.devcontainer/base.Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/base:jammy

# This Dockerfile's base image has a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt and install packages
RUN dpkg --add-architecture i386 \
    && apt update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt install -y --no-install-recommends \
        sudo \
        git \
        build-essential \
        gcc-multilib \
        g++-multilib \
        cgdb \
        gcovr \
        cmake \
        ninja-build \
        cppcheck  \
        unifdef \
        libpcap-dev:i386 \
        libcmocka-dev:i386 \
        ethtool \
        iproute2 \
        dnsmasq \
        isc-dhcp-server \
        iptables \
        net-tools \
        dnsutils  \
        iputils-ping \
        ncat \
        tofrodos \
        dos2unix \
        gawk \
        software-properties-common \
    #
    # [Optional] Update UID/GID if needed
    && if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \
    groupmod --gid $USER_GID $USERNAME \
    && usermod --uid $USER_UID --gid $USER_GID $USERNAME \
    && chown -R $USER_UID:$USER_GID /home/$USERNAME; \
    fi \
    #
    # Clean up
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*

COPY ./scripts/init_network.sh /home/$USERNAME
COPY ./config/dhcpd.conf /etc/dhcp/dhcpd.conf
COPY ./config/isc-dhcp-server /etc/default/isc-dhcp-server
COPY ./config/.gdbinit /home/$USERNAME

RUN chmod +x /home/$USERNAME/init_network.sh
ENTRYPOINT /home/$USERNAME/init_network.sh && bash

