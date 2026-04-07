FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# 国内源
RUN echo "deb http://mirrors.aliyun.com/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

RUN apt update && apt install -y \
    curl \
    xvfb \
    xpra \
    xpra-html5 \
    x11-utils \
    ca-certificates \
    iproute2 \
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

EXPOSE 14500

CMD ["/app/start.sh"]
