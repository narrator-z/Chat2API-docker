# Chat2API Docker

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
- **Automatic Updates**: Downloads the latest x86_64 AppImage from Chat2API releases during build
- **Web Interface**: Includes noVNC for web-based access to the application interface

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

3. Start with the published image:
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

3. Build and run from source:
   ```bash
   docker-compose -f docker-compose.build.yml up -d
   ```

#### Access the Application

- Web Interface: http://localhost:6080
- API Endpoint: http://localhost:8080

### Docker Compose Files

- **`docker-compose.yml`** - Uses the pre-built image from GitHub Container Registry
- **`docker-compose.build.yml`** - Builds the image from source locally

### GitHub CDN Proxy

For users in regions with slow GitHub access, you can enable GitHub CDN proxy:

1. Edit your `docker-compose.yml` or `docker-compose.build.yml`:
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

When enabled, the AppImage will be downloaded through `https://gh-proxy.org/` for faster access.

### Configuration

- Configuration files should be placed in the `./config` directory
- The config directory is mounted to `/root/` in the container
- Port 6080: Web interface (noVNC)
- Port 8080: API endpoint

### Architecture

This Docker setup includes:
- Debian 12 base image
- Virtual display (Xvfb) for headless operation
- noVNC web interface
- All necessary dependencies for Chat2API AppImage
- Automatic download of the latest Chat2API release

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
- **自动更新**：构建时从 Chat2API 发布版本自动下载最新的 x86_64 AppImage
- **Web 界面**：包含 noVNC 用于基于 Web 的应用程序界面访问

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

3. 使用发布镜像启动：
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

3. 从源代码构建并运行：
   ```bash
   docker-compose -f docker-compose.build.yml up -d
   ```

#### 访问应用程序

- Web 界面：http://localhost:6080
- API 端点：http://localhost:8080

### Docker Compose 文件

- **`docker-compose.yml`** - 使用 GitHub Container Registry 中的预构建镜像
- **`docker-compose.build.yml`** - 从源代码本地构建镜像

### GitHub CDN 代理

对于 GitHub 访问较慢地区的用户，可以启用 GitHub CDN 代理：

1. 编辑你的 `docker-compose.yml` 或 `docker-compose.build.yml`：
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

### 配置

- 配置文件应放置在 `./config` 目录中
- 配置目录挂载到容器内的 `/root/` 目录
- 端口 6080：Web 界面（noVNC）
- 端口 8080：API 端点

### 架构

此 Docker 设置包含：
- Debian 12 基础镜像
- 用于无头操作的虚拟显示（Xvfb）
- noVNC Web 界面
- Chat2API AppImage 所需的所有依赖项
- 自动下载最新的 Chat2API 发布版本

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
