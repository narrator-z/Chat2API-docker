#!/bin/bash

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

# 下载 AppImage
echo "正在下载 Chat2API $ARCH 版本..."
echo "查询 GitHub API: $GITHUB_API_URL"

# 获取完整的 API 响应用于调试
API_RESPONSE=$(curl -s "$GITHUB_API_URL")

# 查找对应的 AppImage 下载链接
LATEST_RELEASE=$(echo "$API_RESPONSE" | grep "browser_download_url.*${APPIMAGE_SUFFIX}" | cut -d '"' -f 4)

if [ -z "$LATEST_RELEASE" ]; then
    echo "错误: 无法找到 $ARCH 版本的 AppImage"
    echo "尝试查找所有 AppImage 链接:"
    echo "$API_RESPONSE" | grep "browser_download_url" | head -5
    exit 1
fi

echo "下载地址: $LATEST_RELEASE"

# 如果启用了 GitHub CDN 代理，替换下载 URL
if [ "$USE_GITHUB_CDN" = "true" ]; then
    echo "使用 GitHub CDN 代理: https://gh-proxy.org/"
    LATEST_RELEASE="https://gh-proxy.org/$LATEST_RELEASE"
    echo "最终下载地址: $LATEST_RELEASE"
else
    echo "最终下载地址: $LATEST_RELEASE"
fi

echo "开始下载 AppImage..."
curl -L -o /app/downloads/app.AppImage "$LATEST_RELEASE"
chmod +x /app/downloads/app.AppImage

echo "AppImage 下载完成"

# 创建标记文件表示已下载
touch /app/downloads/.appimage_downloaded
