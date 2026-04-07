#!/bin/bash
set -e

# Cleanup function
cleanup() {
  echo "=== Cleaning up processes ==="
  pkill -f Xvfb || true
  pkill -f xpra || true
  rm -f /tmp/.X99-lock /tmp/.X11-unix/X99
  exit 0
}

# Set trap for cleanup
trap cleanup SIGTERM SIGINT EXIT

export DISPLAY=:99
export LIBGL_ALWAYS_SOFTWARE=1
export NO_AT_BRIDGE=1

APP_DIR=/app/downloads
APP_IMAGE=${APP_DIR}/app.AppImage
EXTRACT_DIR=${APP_DIR}/app-extracted

mkdir -p "${APP_DIR}"

echo "=== 下载 AppImage ==="
if [ ! -f "${APP_IMAGE}" ]; then
  /app/download-appimage.sh
fi

echo "=== 强制解包（避免 FUSE） ==="
if [ ! -d "${EXTRACT_DIR}" ]; then
  cd "${APP_DIR}"
  "${APP_IMAGE}" --appimage-extract
  mv squashfs-root "${EXTRACT_DIR}"
  chmod +x "${EXTRACT_DIR}/AppRun"
fi

APP_RUN="${EXTRACT_DIR}/AppRun"

echo "=== Cleanup Xvfb lock files ==="
rm -f /tmp/.X99-lock /tmp/.X11-unix/X99

echo "=== Check XPRA availability ==="
if ! command -v xpra &> /dev/null; then
  echo "ERROR: xpra not found, installing..."
  apt update && apt install -y xpra
fi

echo "=== 启动 Xvfb ==="
Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render &
sleep 2

echo "=== 启动 XPRA (HTML5) ==="

xpra start :100 \
  --bind-tcp=0.0.0.0:14500 \
  --html=on \
  --notifications=no \
  --mdns=no \
  --start-child="${APP_RUN} \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --disable-software-rasterizer \
    --disable-setuid-sandbox \
    --ozone-platform=x11" \
  --daemon=no

echo "=== Application started ==="
echo "Access via: http://localhost:14500"

# Keep the script running
while true; do
  sleep 30
  # Check if xpra is still running
  if ! pgrep -f "xpra.*:100" > /dev/null; then
    echo "XPRA process died, restarting..."
    break
  fi
done
