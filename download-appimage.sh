#!/bin/bash
set -euo pipefail

DEST_DIR=/app/downloads
DEST_FILE=${DEST_DIR}/app.AppImage
FLAG=${DEST_DIR}/.appimage_downloaded
TMP_FILE=${DEST_DIR}/app.AppImage.tmp
SHA256_EXPECTED=""   # 可选：填写预期 sha256 值以启用校验
USE_GITHUB_CDN=${USE_GITHUB_CDN:-false}
GITHUB_API_URL="https://api.github.com/repos/xiaoY233/Chat2API/releases/latest"
ARCH=$(dpkg --print-architecture)

# 架构映射
if [ "$ARCH" = "amd64" ]; then
  APPIMAGE_SUFFIX="x86_64.AppImage"
elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
  APPIMAGE_SUFFIX="arm64.AppImage"
else
  echo "不支持的架构: $ARCH"
  exit 1
fi

mkdir -p "${DEST_DIR}"

# 如果标志存在且文件存在，直接退出
if [ -f "${FLAG}" ] && [ -f "${DEST_FILE}" ]; then
  echo "AppImage 已存在且标志文件存在，跳过下载"
  exit 0
fi

echo "查询 GitHub API: ${GITHUB_API_URL}"
API_RESPONSE=$(curl -sS -H "Accept: application/vnd.github.v3+json" -A "chat2api-downloader/1.0" "${GITHUB_API_URL}" || true)

# 处理空响应或被限流的情况
if [ -z "${API_RESPONSE}" ]; then
  echo "警告: GitHub API 无响应，尝试直接构造下载链接或重试"
fi

LATEST_RELEASE=$(echo "${API_RESPONSE}" | grep "browser_download_url.*${APPIMAGE_SUFFIX}" | cut -d '"' -f 4 || true)

if [ -z "${LATEST_RELEASE}" ]; then
  echo "未从 API 找到匹配的 AppImage，尝试从页面直接抓取或退出。"
  echo "部分 API 响应片段（前 10 行）:"
  echo "${API_RESPONSE}" | head -n 10
  exit 1
fi

# 可选使用 CDN 代理
if [ "${USE_GITHUB_CDN}" = "true" ]; then
  echo "使用 GitHub CDN 代理"
  LATEST_RELEASE="https://gh-proxy.org/${LATEST_RELEASE}"
fi

echo "下载地址: ${LATEST_RELEASE}"

# 下载函数（curl 优先，wget 回退），带重试与超时
download_with_retry() {
  local url="$1"
  local out="$2"
  local max_retries=5
  local attempt=0
  while [ $attempt -lt $max_retries ]; do
    attempt=$((attempt+1))
    echo "下载尝试 ${attempt}/${max_retries}..."
    if command -v curl >/dev/null 2>&1; then
      if curl -fL --connect-timeout 10 --max-time 600 -A "chat2api-downloader/1.0" -o "${out}" "${url}"; then
        return 0
      fi
    elif command -v wget >/dev/null 2>&1; then
      if wget -O "${out}" "${url}"; then
        return 0
      fi
    else
      echo "错误: 系统中既没有 curl 也没有 wget"
      return 2
    fi
    echo "下载失败，等待 3 秒后重试..."
    sleep 3
  done
  return 1
}

# 执行下载到临时文件
rm -f "${TMP_FILE}"
if ! download_with_retry "${LATEST_RELEASE}" "${TMP_FILE}"; then
  echo "错误: 下载失败"
  rm -f "${TMP_FILE}"
  exit 1
fi

# 可选 sha256 校验
if [ -n "${SHA256_EXPECTED}" ]; then
  echo "校验 sha256..."
  SHA256_ACTUAL=$(sha256sum "${TMP_FILE}" | awk '{print $1}')
  if [ "${SHA256_ACTUAL}" != "${SHA256_EXPECTED}" ]; then
    echo "错误: sha256 校验失败 (expected ${SHA256_EXPECTED}, got ${SHA256_ACTUAL})"
    rm -f "${TMP_FILE}"
    exit 2
  fi
fi

# 原子移动并设置权限
mv "${TMP_FILE}" "${DEST_FILE}"
chmod +x "${DEST_FILE}"

# 创建标志文件（仅在成功后）
touch "${FLAG}"
echo "AppImage 下载并准备完成: ${DEST_FILE}"
