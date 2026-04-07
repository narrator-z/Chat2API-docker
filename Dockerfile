FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# 换源
RUN echo "deb http://mirrors.aliyun.com/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

# 安装 xpra + headless X + noVNC依赖
RUN apt update && apt install -y \
    curl \
    xvfb \
    xpra \
    x11-utils \
    netcat-openbsd \
    ca-certificates \
    iproute2 \
    websockify \
    novnc \
    x11vnc \
    dbus \
    dbus-x11 \
    libgtk-3-0 \
    libnss3 \
    libxss1 \
    libasound2 \
    libgbm1 \
    libdrm2 \
    libgl1 \
    libxrandr2 \
    libxdamage1 \
    libxcomposite1 \
    libx11-xcb1 \
    libfuse2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY start.sh /app/start.sh
COPY download-appimage.sh /app/download-appimage.sh

RUN chmod +x /app/start.sh /app/download-appimage.sh

EXPOSE 14500 8080

CMD ["/app/start.sh"]
