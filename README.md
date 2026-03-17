# 🚀 Sing-box + NaiveProxy 一键部署脚本

这是一个基于最新版 [Sing-box](https://github.com/SagerNet/sing-box) 原生 NaiveProxy 协议的一键搭建脚本。无需繁琐地编译 Caddy 插件，一行命令即可完成服务端部署。

## ✨ 特性
- **原生支持**：使用 Sing-box 1.13+ 内置的 Naive 协议，性能更好，无需 Caddy 转发。
- **自动证书**：集成 ACME 自动向 Let's Encrypt 申请并续期 TLS 证书。
- **一键导入**：搭建完成后自动生成 `http2://` 格式的 URI 链接，完美适配 Flowz现代客户端。
- **纯净环保**：脚本会自动清理冲突环境，并在系统后台静默运行守护进程。

## 🛠️ 准备工作
在运行脚本之前，请确保你满足以下条件：
1. 一台可以通过 SSH 访问的 VPS（推荐 Debian/Ubuntu 系统）。
2. 一个已经**解析到该 VPS IP** 的域名。
3. VPS 防火墙已放行 **80** 和 **443** 端口（80端口用于首次申请证书）。

## 📦 一键安装

请使用 `root` 用户登录你的 VPS，然后复制并运行以下命令（建议点击代码块右上角的“复制”按钮）：

bash -c "$(curl -Ls https://raw.githubusercontent.com/dododook/NaiveProxy/refs/heads/main/install.sh?v=2)"
