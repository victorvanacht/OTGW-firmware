FROM mcr.microsoft.com/devcontainers/python:3.12-trixie

RUN rm -f /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        libffi-dev \
        libstdc++6 \
        libusb-1.0-0 \
        make \
        udev \
        usbutils \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir platformio \
    && usermod -aG dialout vscode

USER vscode