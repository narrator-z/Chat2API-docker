FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# 使用国内镜像源 (阿里云)
RUN echo "deb http://mirrors.aliyun.com/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

RUN apt update && apt install -y \
    curl \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    libgtk-3-0 \
    libnss3 \
    libxss1 \
    libasound2 \
    libgbm1 \
    libfuse2 \
    ca-certificates \
    dbus \
    dbus-x11 \
    x11-utils \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY start.sh /app/start.sh

RUN chmod +x /app/start.sh

EXPOSE 6080 5900

CMD ["/app/start.sh"]