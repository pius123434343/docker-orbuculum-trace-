# Base image
FROM ubuntu:22.04

# Non-interactive mode for APT
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libftdi1-dev \
    libhidapi-dev \
    pkg-config \
    meson \
    ninja-build \
    python3-pip \
    cmake \
    libczmq-dev \
    libncurses-dev \
    libsdl2-dev \
    libelf-dev \
    libcapstone-dev \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    udev \
    gdb-multiarch \
&& apt-get clean

# Upgrade Meson
RUN pip3 install --upgrade meson

# Set working directory for Blackmagic
WORKDIR /app

# Clone Blackmagic repository and build the project
RUN git clone --depth=1 --branch=main https://github.com/blackmagic-debug/blackmagic.git . && \
    meson setup build && \
    meson compile -C build

# Ensure the binary is executable and add it to PATH
RUN chmod +x /app/build/blackmagic
ENV PATH="/app/build:${PATH}"

# Set working directory for Orbuculum
WORKDIR /orbuculum

# Clone Orbuculum from GitHub and build
RUN git clone https://github.com/orbcode/orbuculum.git . && \
    meson setup build && \
    ninja -C build

# Install Orbuculum
RUN ninja -C build install

# Configure dynamic linker for Orbuculum
RUN echo "/usr/local/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/orbuculum.conf && ldconfig

# Set OBJDUMP environment variable
ENV OBJDUMP=/usr/bin/arm-none-eabi-objdump

# Default to bash
CMD ["/bin/bash"]

