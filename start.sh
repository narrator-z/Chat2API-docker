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
EXTRACT_DIR=${APP_DIR}/squashfs-root
LOG_FILE=/app/electron.log
FLAG=${APP_DIR}/.appimage_downloaded

mkdir -p "${APP_DIR}"

# 下载 AppImage（保留你的下载脚本逻辑）
if [ ! -f "${FLAG}" ] || [ ! -f "${APP_IMAGE}" ]; then
  echo "=== 首次或缺失 AppImage，调用 download-appimage.sh ==="
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

if ! xdpyinfo -display :99 >/dev/null 2>&1; then
  echo "错误: Xvfb 启动失败"
  kill ${XVFB_PID} 2>/dev/null || true
  exit 1
fi
echo "Xvfb 已启动 PID=${XVFB_PID}"

# 启动 x11vnc（禁用 IPv6 以避免 listen6 错误）
echo "=== 启动 x11vnc ==="
x11vnc -display :99 -nopw -forever -shared -rfbport 5900 -noxipv6 &
VNC_PID=$!
sleep 1

# 启动 noVNC (websockify)
echo "=== 启动 noVNC(websockify) ==="
# 如果需要 SSL，websockify 会使用 /app/self.pem（下面会自动生成）
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &
WEBSOCKIFY_PID=$!
sleep 1

# 如果缺少证书且 websockify 报 SSL，自动生成自签名证书
if [ ! -f /app/self.pem ]; then
  echo "生成自签名证书 /app/self.pem"
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /app/self.key -out /app/self.crt -subj "/CN=localhost" >/dev/null 2>&1 || true
  if [ -f /app/self.key ] && [ -f /app/self.crt ]; then
    cat /app/self.key /app/self.crt > /app/self.pem
    chmod 600 /app/self.pem
  fi
fi

# 决定如何运行 AppImage：优先使用原始 AppImage（若 /dev/fuse 可用），否则解包后运行
if [ -c /dev/fuse ]; then
  echo "/dev/fuse 存在，直接运行 AppImage"
  APP_RUN="${APP_IMAGE}"
else
  echo "/dev/fuse 不存在，使用解包后的 AppRun"
  if [ ! -d "${EXTRACT_DIR}" ]; then
    echo "解包 AppImage 到 ${EXTRACT_DIR} ..."
    "${APP_IMAGE}" --appimage-extract
    mv squashfs-root "${EXTRACT_DIR}"
    chmod +x "${EXTRACT_DIR}/AppRun"
  fi
  APP_RUN="${EXTRACT_DIR}/AppRun"
fi

# 启动 Electron 应用并记录日志
echo "=== 启动 Electron App ==="
if [ ! -x "${APP_RUN}" ]; then
  echo "错误: 找不到可执行文件 ${APP_RUN}"
  exit 1
fi

"${APP_RUN}" \
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

# 监控循环
while true; do
  sleep 10
  if ! kill -0 ${XVFB_PID} 2>/dev/null; then
    echo "错误: Xvfb 已停止，退出容器"
    exit 1
  fi
  if ! kill -0 ${VNC_PID} 2>/dev/null; then
    echo "警告: x11vnc 已停止，尝试重启..."
    x11vnc -display :99 -nopw -forever -shared -rfbport 5900 -noxipv6 &
    VNC_PID=$!
  fi
  if ! kill -0 ${WEBSOCKIFY_PID} 2>/dev/null; then
    echo "警告: noVNC 已停止，尝试重启..."
    websockify --web=/usr/share/novnc/ 6080 localhost:5900 &
    WEBSOCKIFY_PID=$!
  fi
  if ! kill -0 ${APP_PID} 2>/dev/null; then
    echo "警告: 应用已停止，查看日志: ${LOG_FILE}"
  fi
done
