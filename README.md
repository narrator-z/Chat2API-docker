# ⚠️ 项目已弃用 / Project Deprecated

**中文：** 由于性能问题，本项目已不再维护。请移步至新项目获取 Docker 部署指导：
👉 **[https://github.com/narrator-z/Chat2API](https://github.com/narrator-z/Chat2API)**

**English:** Due to performance issues, this project is no longer maintained. Please visit the new project for Docker deployment guidance:
👉 **[https://github.com/narrator-z/Chat2API](https://github.com/narrator-z/Chat2API)**

---

# Chat2API Docker (Deprecated)

[English](#english) | [中文](#中文)

---

## English

### Overview

This project provides a Docker containerization of [Chat2API](https://github.com/xiaoY233/Chat2API), a native desktop application that offers an OpenAI-compatible API for multiple AI service providers. The main contribution of this project is packaging Chat2API into a Docker container, enabling it to run on headless hosts.

### Features

- **OpenAI-Compatible API**: Provides a unified API interface for multiple AI service providers
- **Multiple AI Providers**: Supports DeepSeek, GLM, Kimi, MiniMax, Qwen, Z.ai and more
- **Cross-Platform**: Runs on any Docker-compatible system (Linux, Windows, macOS)
- **Headless Operation**: Perfect for server deployment without GUI requirements
- **Automatic Updates**: Downloads the latest AppImage (supports amd64 and arm64) from Chat2API releases during build
- **Web Interface**: Includes xpra (HTML5) for web-based access to the application interface

### Supported AI Service Providers

- DeepSeek
- GLM (智谱清言)
- Kimi (月之暗面)
- MiniMax
- Qwen (通义千问)
- Z.ai
- And more...

### Quick Start

#### Option 1: Using Pre-built Image (Recommended)

1. Clone this repository:
   ```bash
   git clone https://github.com/narrator-z/Chat2API-docker.git
   cd Chat2API-docker
   ```

2. Create a config directory (optional):
   ```bash
   mkdir config
   ```

3. Create the external network (required):
   ```bash
   docker network create chat2api
   ```

4. Start with the published image:
   ```bash
   docker-compose up -d
   ```

#### Option 2: Building from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/narrator-z/Chat2API-docker.git
   cd Chat2API-docker
   ```

2. Create a config directory (optional):
   ```bash
   mkdir config
   ```

3. Create the external network (required):
   ```bash
   docker network create chat2api
   ```

4. Build the image:
   ```bash
   docker build -t chat2api-docker .
   ```

5. Update docker-compose.yml to use the local image:
   ```yaml
   services:
     chat2api:
       image: chat2api-docker
   ```

6. Start the container:
   ```bash
   docker-compose up -d
   ```

#### Access the Application

- Web Interface: http://localhost:14500
- API Endpoint: http://localhost:58002

### Docker Compose Configuration

- **`docker-compose.yml`** - Uses the pre-built image from GitHub Container Registry
- Requires an external network named `chat2api` to be created before starting

### GitHub CDN Proxy

GitHub CDN proxy is **disabled by default**. To enable it for faster download speeds:

1. Edit your `docker-compose.yml`:
   ```yaml
   services:
     chat2api:
       environment:
         - USE_GITHUB_CDN=true
   ```

2. Or use environment variable:
   ```bash
   USE_GITHUB_CDN=true docker-compose up -d
   ```

When enabled, AppImage will be downloaded through `https://gh-proxy.org/` for faster access.

### Releases

Docker images are tagged with semantic version numbers:

- **`ghcr.io/narrator-z/chat2api-docker:latest`** - Latest main branch build
- **`ghcr.io/narrator-z/chat2api-docker:v1.0.0`** - Stable release v1.0.0
- **`ghcr.io/narrator-z/chat2api-docker:main`** - Main branch build

#### Using Specific Versions

To use a specific version:
```yaml
services:
  chat2api:
    image: ghcr.io/narrator-z/chat2api-docker:v1.0.0
    # ... rest of configuration
```

#### Release Process

Releases are automatically created when tags are pushed:

```bash
# Create a new release
git tag -a v1.0.1 -m "Release v1.0.1"
git push origin v1.0.1
```

This will:
- Create a GitHub release with changelog
- Build and push Docker image with version tag
- Update documentation

### Configuration

- Configuration files should be placed in `./config` directory
- The config directory is mounted to `/root/` in the container
- Downloaded AppImage files are available in `./downloads` directory
- Port 14500: Web interface (xpra HTML5)
- Port 58002: API endpoint

### Volume Mounts

- **`./config:/root/`** - Application configuration and data
- **`./downloads:/app/downloads`** - Downloaded AppImage and runtime files

### Architecture

This Docker setup includes:
- Debian 12 base image
- Virtual display (Xvfb) for headless operation
- xpra HTML5 web interface
- All necessary dependencies for Chat2API AppImage
- Automatic download of the latest Chat2API release
- Support for both amd64 and arm64 architectures

### Original Project

This is a Docker containerization of the original [Chat2API](https://github.com/xiaoY233/Chat2API) project by xiaoY233.

### Documentation

For detailed usage instructions and API documentation, please refer to the official [Chat2API Documentation](https://chat2api-doc.vercel.app/).

### Key Features of Chat2API

- **OpenAI Compatible**: Standard OpenAI-compatible API endpoints for seamless integration
- **Multi-Provider Support**: Connect to multiple AI services with a single unified API
- **Dashboard Monitoring**: Real-time request traffic, token usage, and success rate statistics
- **Proxy Configuration**: Flexible proxy settings and load balancing strategies
- **API Key Management**: Generate and manage API keys for secure access control
- **Request Logging**: Detailed request logs for debugging and analysis
- **Secure**: Credentials encrypted with AES-256
- **Fast**: Native performance with Electron

### Integration Examples

Chat2API works seamlessly with various AI clients:

- **GitHub Copilot** - VS Code extension
- **RooCode** - AI coding assistant  
- **Cline** - Autonomous coding agent
- **Cherry Studio** - Desktop AI client

Python integration example:
```python
from openai import OpenAI

client = OpenAI(
    api_key="your-api-key",
    base_url="http://localhost:8080/v1"
)

response = client.chat.completions.create(
    model="DeepSeek-V3.2",
    messages=[
        {"role": "user", "content": "Hello, who are you?"}
    ]
)

print(response.choices[0].message.content)
```

---

## 中文

### 概述

本项目提供了 [Chat2API](https://github.com/xiaoY233/Chat2API) 的 Docker 容器化方案。Chat2API 是一个原生桌面应用程序，为多个 AI 服务提供商提供 OpenAI 兼容的 API。本项目的主要贡献是将 Chat2API 封装到 Docker 容器中，使其能够在无头主机上运行。

### 特性

- **OpenAI 兼容 API**：为多个 AI 服务提供商提供统一的 API 接口
- **多 AI 提供商支持**：支持 DeepSeek、GLM、Kimi、MiniMax、Qwen、Z.ai 等
- **跨平台**：可在任何兼容 Docker 的系统上运行（Linux、Windows、macOS）
- **无头运行**：完美适用于无需 GUI 的服务器部署
- **自动更新**：构建时从 Chat2API 发布版本自动下载最新的 AppImage（支持 amd64 和 arm64）
- **Web 界面**：包含 xpra (HTML5) 用于基于 Web 的应用程序界面访问

### 支持的 AI 服务提供商

- DeepSeek
- GLM (智谱清言)
- Kimi (月之暗面)
- MiniMax
- Qwen (通义千问)
- Z.ai
- 以及更多...

### 快速开始

#### 选项 1：使用预构建镜像（推荐）

1. 克隆此仓库：
   ```bash
   git clone https://github.com/narrator-z/Chat2API-docker.git
   cd Chat2API-docker
   ```

2. 创建配置目录（可选）：
   ```bash
   mkdir config
   ```

3. 创建外部网络（必需）：
   ```bash
   docker network create chat2api
   ```

4. 使用发布镜像启动：
   ```bash
   docker-compose up -d
   ```

#### 选项 2：从源代码构建

1. 克隆此仓库：
   ```bash
   git clone https://github.com/narrator-z/Chat2API-docker.git
   cd Chat2API-docker
   ```

2. 创建配置目录（可选）：
   ```bash
   mkdir config
   ```

3. 创建外部网络（必需）：
   ```bash
   docker network create chat2api
   ```

4. 构建镜像：
   ```bash
   docker build -t chat2api-docker .
   ```

5. 更新 docker-compose.yml 以使用本地镜像：
   ```yaml
   services:
     chat2api:
       image: chat2api-docker
   ```

6. 启动容器：
   ```bash
   docker-compose up -d
   ```

#### 访问应用程序

- Web 界面：http://localhost:14500
- API 端点：http://localhost:58002

### Docker Compose 配置

- **`docker-compose.yml`** - 使用 GitHub Container Registry 中的预构建镜像
- 需要在启动前创建名为 `chat2api` 的外部网络

### GitHub CDN 代理

GitHub CDN 代理**默认禁用**。如需启用以获得更快的下载速度：

1. 编辑你的 `docker-compose.yml`：
   ```yaml
   services:
     chat2api:
       environment:
         - USE_GITHUB_CDN=true
   ```

2. 或使用环境变量：
   ```bash
   USE_GITHUB_CDN=true docker-compose up -d
   ```

启用后，AppImage 将通过 `https://gh-proxy.org/` 下载以获得更快的访问速度。

### 发布版本

Docker 镜像使用语义化版本号标记：

- **`ghcr.io/narrator-z/chat2api-docker:latest`** - 最新主分支构建
- **`ghcr.io/narrator-z/chat2api-docker:v1.0.0`** - 稳定版本 v1.0.0
- **`ghcr.io/narrator-z/chat2api-docker:main`** - 主分支构建

#### 使用特定版本

要使用特定版本：
```yaml
services:
  chat2api:
    image: ghcr.io/narrator-z/chat2api-docker:v1.0.0
    # ... 其他配置
```

#### 发布流程

推送标签时自动创建发布版本：

```bash
# 创建新版本
git tag -a v1.0.1 -m "Release v1.0.1"
git push origin v1.0.1
```

这将：
- 创建带更新日志的 GitHub 发布
- 构建并推送带版本标签的 Docker 镜像
- 更新文档

### 配置

- 配置文件应放置在 `./config` 目录中
- 配置目录挂载到容器内的 `/root/` 目录
- 下载的 AppImage 文件可在 `./downloads` 目录中访问
- 端口 14500：Web 界面（xpra HTML5）
- 端口 58002：API 端点

### 卷挂载

- **`./config:/root/`** - 应用程序配置和数据
- **`./downloads:/app/downloads`** - 下载的 AppImage 和运行时文件

### 架构

此 Docker 设置包含：
- Debian 12 基础镜像
- 用于无头操作的虚拟显示（Xvfb）
- xpra HTML5 Web 界面
- Chat2API AppImage 所需的所有依赖项
- 自动下载最新的 Chat2API 发布版本
- 支持 amd64 和 arm64 架构

### 原始项目

这是 xiaoY233 的原始 [Chat2API](https://github.com/xiaoY233/Chat2API) 项目的 Docker 容器化版本。

### 文档

详细的使用说明和 API 文档，请参考官方 [Chat2API 文档](https://chat2api-doc.vercel.app/)。

### Chat2API 核心功能

- **OpenAI 兼容**：标准的 OpenAI 兼容 API 端点，无缝集成现有工具
- **多提供商支持**：通过单一统一 API 连接多个 AI 服务
- **仪表板监控**：实时请求流量、令牌使用和成功率统计
- **代理配置**：灵活的代理设置和负载均衡策略
- **API 密钥管理**：生成和管理 API 密钥以实现安全访问控制
- **请求日志**：详细的请求日志用于调试和分析
- **安全**：使用 AES-256 加密凭据
- **快速**：Electron 原生性能

### 集成示例

Chat2API 与各种 AI 客户端无缝协作：

- **GitHub Copilot** - VS Code 扩展
- **RooCode** - AI 编程助手
- **Cline** - 自主编程代理
- **Cherry Studio** - 桌面 AI 客户端

Python 集成示例：
```python
from openai import OpenAI

client = OpenAI(
    api_key="your-api-key",
    base_url="http://localhost:8080/v1"
)

response = client.chat.completions.create(
    model="DeepSeek-V3.2",
    messages=[
        {"role": "user", "content": "你好，你是谁？"}
    ]
)

print(response.choices[0].message.content)
```

## License

This project follows the same license as the original Chat2API project.
