#!/bin/bash
# ⚠️ DEPRECATED: 本项目因性能问题已弃用，请移步 https://github.com/narrator-z/Chat2API
# ⚠️ DEPRECATED: This project is abandoned due to performance issues, see https://github.com/narrator-z/Chat2API
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

export DISPLAY=:42
export LIBGL_ALWAYS_SOFTWARE=1
export NO_AT_BRIDGE=2

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

# Set APPDIR for AppRun script to find chat2api binary
export APPDIR="${EXTRACT_DIR}"

# Fix Xsession error
[ -f /etc/X11/Xsession ] && cp /etc/X11/Xsession /etc/X11/Xsession.backup
echo "#!/bin/bash" > /etc/X11/Xsession
echo "exit 0" >> /etc/X11/Xsession
chmod +x /etc/X11/Xsession

echo "=== Cleanup Xvfb lock files ==="
rm -f /tmp/.X42-lock /tmp/.X11-unix/X42
rm -f /tmp/.X99-lock /tmp/.X11-unix/X99
rm -f /tmp/.X100-lock /tmp/.X11-unix/X100

echo "=== Check XPRA availability ==="
if ! command -v xpra &> /dev/null; then
  echo "ERROR: xpra not found, installing..."
  apt update && apt install -y xpra
fi

echo "=== Start Xvfb ==="
Xvfb :42 -screen 0 1280x720x24 -ac +extension GLX +render &
sleep 2

echo "=== 启动 XPRA (HTML5) ==="

# Install coreutils to get the true command
if ! command -v true &> /dev/null; then
  apt update && apt install -y coreutils
fi

# Fix xdg menu errors by creating minimal menu or disabling it
export XDG_CONFIG_DIRS=/tmp/xdg
mkdir -p /tmp/xdg/menus
# Create empty menu file to prevent parsing errors
cat > /tmp/xdg/menus/applications.menu << 'EOF'
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 2.0//EN"
 "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
  <Name>Applications</Name>
  <DefaultAppDirs/>
  <DefaultDirectoryDirs/>
</Menu>
EOF

echo "=== Starting DBus ==="
mkdir -p /var/run/dbus
mkdir -p /run/user/0
dbus-daemon --system --fork 2>/dev/null || true
# Create session bus with explicit address
dbus-launch --sh-syntax 2>/dev/null > /tmp/dbus-env || true
if [ -f /tmp/dbus-env ]; then
    source /tmp/dbus-env
fi
# Fallback if dbus-launch didn't work
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    dbus-daemon --session --fork --address=unix:path=/run/user/0/bus 2>/dev/null || true
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/0/bus
fi
export NO_AT_BRIDGE=1

# Wait for dbus to be ready
sleep 1

echo "=== Starting XPRA with stability settings ==="

xpra start :42 \
  --use-display \
  --bind-tcp=0.0.0.0:14500 \
  --html=on \
  --notifications=no \
  --mdns=no \
  --daemon=no \
  --min-quality=30 \
  --quality=50 \
  --speed=100 \
  --auto-refresh-delay=500 \
  --compression=6 \
  --encoding=h264 \
  --idle-timeout=0 \
  --server-idle-timeout=0 \
  --exit-with-children=no \
  --exit-with-client=no \
  --resize-display=no \
  --dpi=96 \
  --max-size=1280x720 \
  --start="${APP_RUN} \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --disable-software-rasterizer \
    --disable-setuid-sandbox \
    --ozone-platform=x11"

echo "=== Application started ==="
echo "Access via: http://localhost:14500"

# Keep the script running
while true; do
  sleep 30
  # Check if xpra is still running
  if ! pgrep -f "xpra.*:42" > /dev/null; then
    echo "XPRA process died, restarting..."
    break
  fi
done
