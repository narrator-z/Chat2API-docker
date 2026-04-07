#!/bin/bash
set -euo pipefail

export DISPLAY=:99
export NO_AT_BRIDGE=1
export LIBGL_ALWAYS_SOFTWARE=1
export ELECTRON_OZONE_PLATFORM_HINT=x11
export ELECTRON_ENABLE_LOGGING=1
export ELECTRON_ENABLE_STACK_DUMPING=1

APP_DIR=/app/downloads
APP_IMAGE=${APP_DIR}/app.AppImage
LOG_FILE=/app/electron.log

# 首次下载 AppImage
if [ ! -f "${APP_DIR}/.appimage_downloaded" ]; then
    echo "=== 首次启动，下载 AppImage ==="
    /app/download-appimage.sh
else
    echo "=== AppImage 已存在，跳过下载 ==="
fi

# 清理残留 X 锁
rm -f /tmp/.X99-lock
rm -f /tmp/.X11-unix/X99

# 启动 Xvfb
echo "=== 启动 Xvfb :99 ==="
Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render &
XVFB_PID=$!
sleep 2

# 检查 Xvfb 是否可用
if ! xdpyinfo -display :99 >/dev/null 2>&1; then
    echo "Xvfb 启动失败，退出"
    kill ${XVFB_PID} 2>/dev/null || true
    exit 1
fi
echo "Xvfb 已启动 PID=${XVFB_PID}"

# 启动 x11vnc
echo "=== 启动 x11vnc ==="
x11vnc -display :99 -nopw -forever -shared -rfbport 5900 &
VNC_PID=$!
sleep 1

# 启动 noVNC (websockify)
echo "=== 启动 noVNC(websockify) ==="
# 如果 /usr/share/novnc 路径不存在，websockify 仍会启动，但 noVNC 页面可能不可用
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &
WEBSOCKIFY_PID=$!
sleep 1

# 启动 Electron AppImage
echo "=== 启动 Electron App ==="
if [ ! -x "${APP_IMAGE}" ]; then
    echo "错误: 找不到 AppImage: ${APP_IMAGE}"
    exit 1
fi

# 以后台方式启动并记录日志
"${APP_IMAGE}" \
    --no-sandbox \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-dev-shm-usage \
    --disable-setuid-sandbox \
    --disable-features=VizDisplayCompositor \
    --ozone-platform=x11 \
    2>&1 | tee "${LOG_FILE}" &
APP_PID=$!

echo "应用已启动 PID=${APP_PID} 日志: ${LOG_FILE}"

# 清理函数
cleanup() {
    echo "收到退出信号，清理进程..."
    kill ${APP_PID} 2>/dev/null || true
    kill ${WEBSOCKIFY_PID} 2>/dev/null || true
    kill ${VNC_PID} 2>/dev/null || true
    kill ${XVFB_PID} 2>/dev/null || true
    wait 2>/dev/null || true
    exit 0
}
trap cleanup SIGINT SIGTERM

# 监控循环（简单监控，不自动重启主应用）
while true; do
    sleep 10

    if ! kill -0 ${XVFB_PID} 2>/dev/null; then
        echo "错误: Xvfb 已停止，退出容器"
        exit 1
    fi

    if ! kill -0 ${VNC_PID} 2>/dev/null; then
        echo "警告: x11vnc 已停止，尝试重启..."
        x11vnc -display :99 -nopw -forever -shared -rfbport 5900 &
        VNC_PID=$!
    fi

    if ! kill -0 ${WEBSOCKIFY_PID} 2>/dev/null; then
        echo "警告: noVNC 已停止，尝试重启..."
        websockify --web=/usr/share/novnc/ 6080 localhost:5900 &
        WEBSOCKIFY_PID=$!
    fi

    if ! kill -0 ${APP_PID} 2>/dev/null; then
        echo "警告: 应用已停止，查看日志: ${LOG_FILE}"
        # 不自动重启应用，避免重复启动导致资源泄露
    fi
done
