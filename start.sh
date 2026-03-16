#!/bin/bash

export DISPLAY=:99

echo "=== 下载 Chat2API AppImage ==="
# 检测架构并下载对应的 AppImage
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
    ARCH="x86_64"
    APPIMAGE_SUFFIX="x86_64.AppImage"
elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
    APPIMAGE_SUFFIX="arm64.AppImage"
else
    echo "不支持的架构: $ARCH"
    exit 1
fi

# 设置 GitHub API URL
GITHUB_API_URL="https://api.github.com/repos/xiaoY233/Chat2API/releases/latest"

# 如果启用了 GitHub CDN 代理
if [ "$USE_GITHUB_CDN" = "true" ]; then
    echo "使用 GitHub CDN 代理: https://gh-proxy.org/"
    GITHUB_API_URL="https://gh-proxy.org/https://api.github.com/repos/xiaoY233/Chat2API/releases/latest"
fi

# 下载 AppImage
echo "正在下载 Chat2API $ARCH 版本..."
LATEST_RELEASE=$(curl -s "$GITHUB_API_URL" | \
grep "browser_download_url.*${APPIMAGE_SUFFIX}" | \
cut -d '"' -f 4)

if [ -z "$LATEST_RELEASE" ]; then
    echo "错误: 无法找到 $ARCH 版本的 AppImage"
    exit 1
fi

echo "下载地址: $LATEST_RELEASE"

# 如果启用了 GitHub CDN 代理，替换下载 URL
if [ "$USE_GITHUB_CDN" = "true" ]; then
    LATEST_RELEASE="https://gh-proxy.org/$LATEST_RELEASE"
fi

curl -L -o /app/downloads/app.AppImage "$LATEST_RELEASE"
chmod +x /app/downloads/app.AppImage

echo "AppImage 下载完成"

echo "=== 清理残留的 X 服务器锁文件 ==="
rm -f /tmp/.X99-lock
rm -f /tmp/.X11-unix/X99

echo "=== 初始化 DBus 环境 ==="
mkdir -p /run/dbus /var/run/dbus
chmod 755 /run/dbus /var/run/dbus

# 生成 machine-id
if [ ! -f /etc/machine-id ]; then
    dbus-uuidgen > /etc/machine-id
fi
if [ ! -f /var/lib/dbus/machine-id ]; then
    mkdir -p /var/lib/dbus
    cp /etc/machine-id /var/lib/dbus/machine-id
fi

# 启动 DBus
echo "启动 DBus..."
rm -f /run/dbus/system_bus_socket
dbus-daemon --system --fork
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

echo "=== 启动 X 服务器 ==="
# 使用更详细的参数启动 Xvfb
Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
XVFB_PID=$!

# 等待 Xvfb 完全启动
echo "等待 Xvfb 启动..."
sleep 3

# 验证 Xvfb 是否正常运行
if ! xdpyinfo -display :99 >/dev/null 2>&1; then
    echo "Xvfb 启动失败，重试..."
    kill $XVFB_PID 2>/dev/null
    rm -f /tmp/.X99-lock
    Xvfb :99 -screen 0 1920x1080x24 -ac &
    sleep 3
fi

echo "Xvfb 已启动，PID: $XVFB_PID"

echo "=== 启动窗口管理器 ==="
fluxbox &
FLUXBOX_PID=$!
sleep 1

echo "=== 启动 VNC 服务器 ==="
# 确保 x11vnc 能够连接到 X server
x11vnc -display :99 \
    -nopw \
    -forever \
    -shared \
    -ncache 10 \
    -ncache_cr \
    -noshm \
    -noipv6 \
    -rfbport 5900 &
VNC_PID=$!

# 等待 VNC 启动
sleep 2

# 验证 VNC 是否运行
if ! nc -z localhost 5900 2>/dev/null; then
    echo "VNC 服务器启动失败，重试..."
    kill $VNC_PID 2>/dev/null
    x11vnc -display :99 -nopw -forever -shared -rfbport 5900 &
    sleep 2
fi

echo "=== 启动 noVNC ==="
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &
WEBSOCKIFY_PID=$!
sleep 1

echo "=== 启动 Electron App ==="

# 设置环境变量
export ELECTRON_ENABLE_LOGGING=1
export ELECTRON_ENABLE_STACK_DUMPING=1
export NO_AT_BRIDGE=1
export LIBGL_ALWAYS_SOFTWARE=1  # 使用软件渲染

# 验证 X server 是否可访问
xdpyinfo -display :99 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "X server :99 可访问，启动应用..."
    
    # 启动应用
    /app/downloads/app.AppImage \
        --appimage-extract-and-run \
        --no-sandbox \
        --disable-gpu \
        --disable-dev-shm-usage \
        --disable-setuid-sandbox \
        --disable-features=VizDisplayCompositor \
        --use-gl=swiftshader \
        --ozone-platform=x11 \
        --enable-logging=stderr \
        2>&1 | tee /app/electron.log &
    APP_PID=$!
    
    echo "应用已启动，PID: $APP_PID"
else
    echo "错误: 无法访问 X server :99"
    exit 1
fi

echo "=== 所有服务已启动 ==="
echo "Xvfb PID: $XVFB_PID"
echo "Fluxbox PID: $FLUXBOX_PID"
echo "VNC PID: $VNC_PID"
echo "noVNC PID: $WEBSOCKIFY_PID"
echo "App PID: $APP_PID"
echo ""
echo "访问 noVNC: http://$(hostname -i):6080/vnc.html"
echo "或使用 VNC 客户端连接: $(hostname -i):5900"

# 监控进程状态（但不重启，避免重复启动问题）
while true; do
    sleep 30
    
    # 检查关键进程是否还在运行
    if ! kill -0 $XVFB_PID 2>/dev/null; then
        echo "错误: Xvfb 已停止，容器将退出"
        exit 1
    fi
    
    if ! kill -0 $VNC_PID 2>/dev/null; then
        echo "警告: VNC 服务器已停止，尝试重启..."
        x11vnc -display :99 -nopw -forever -shared -rfbport 5900 &
        VNC_PID=$!
    fi
    
    if ! kill -0 $WEBSOCKIFY_PID 2>/dev/null; then
        echo "警告: noVNC 已停止，尝试重启..."
        websockify --web=/usr/share/novnc/ 6080 localhost:5900 &
        WEBSOCKIFY_PID=$!
    fi
    
    if ! kill -0 $APP_PID 2>/dev/null; then
        echo "警告: 应用已停止，查看日志: /app/electron.log"
        # 可以选择重启应用
        # /app/app.AppImage --appimage-extract-and-run --no-sandbox --disable-gpu 2>&1 | tee /app/electron.log &
        # APP_PID=$!
    fi
done