#!/bin/bash

# 定义颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # 恢复默认颜色

echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}      Sing-box (NaiveProxy 协议) 一键安装脚本     ${NC}"
echo -e "${GREEN}==================================================${NC}"

# 1. 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}错误：必须使用 root 用户运行此脚本！请使用 sudo -i 切换后重试。${NC}"
   exit 1
fi

echo -e "${YELLOW}📝 请输入节点配置信息：${NC}"

# 2. 交互式获取用户配置
read -p "👉 请输入你的解析好的域名 (例如: naive.example.com): " DOMAIN
read -p "👉 请输入你的邮箱 (用于 Let's Encrypt 自动申请证书): " EMAIL
read -p "👉 请设置 NaiveProxy 用户名 (默认直接回车为 user123): " USERNAME
USERNAME=${USERNAME:-user123}
read -p "👉 请设置 NaiveProxy 密码 (默认直接回车为 pass123): " PASSWORD
PASSWORD=${PASSWORD:-pass123}
read -p "👉 请给这个节点起个名字 (默认直接回车为 NaiveProxy): " NODE_NAME
NODE_NAME=${NODE_NAME:-NaiveProxy}

echo -e "\n${YELLOW}🧹 [1/4] 正在清理旧环境，释放 80 和 443 端口...${NC}"
systemctl stop caddy sing-box nginx apache2 2>/dev/null
pkill -9 caddy sing-box nginx apache2 2>/dev/null

echo -e "${YELLOW}📦 [2/4] 正在安装最新版 Sing-box...${NC}"
# 使用官方脚本自动拉取最新版
bash <(curl -Ls https://raw.githubusercontent.com/SagerNet/sing-box/main/install.sh)

echo -e "${YELLOW}⚙️ [3/4] 正在生成服务端配置文件...${NC}"
mkdir -p /etc/sing-box
cat <<EOF > /etc/sing-box/config.json
{
  "log": {
    "level": "info"
  },
  "inbounds": [
    {
      "type": "naive",
      "tag": "naive-in",
      "listen": "::",
      "listen_port": 443,
      "users": [
        {
          "username": "$USERNAME",
          "password": "$PASSWORD"
        }
      ],
      "tls": {
        "enabled": true,
        "server_name": "$DOMAIN",
        "acme": {
          "domain": ["$DOMAIN"],
          "email": "$EMAIL"
        }
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}
EOF

echo -e "${YELLOW}🚀 [4/4] 正在配置系统服务并启动 Sing-box...${NC}"
systemctl daemon-reload
systemctl enable sing-box
systemctl restart sing-box

# 生成分享链接
SHARE_LINK="http2://${USERNAME}:${PASSWORD}@${DOMAIN}:443#${NODE_NAME}"

echo -e "\n${GREEN}==================================================${NC}"
echo -e "${GREEN}🎉 搭建彻底完成！${NC}"
echo -e "--------------------------------------------------"
echo -e "${YELLOW}👇 请复制下方链接，直接导入到你的 Flowz 客户端：${NC}"
echo -e ""
echo -e "${CYAN}${SHARE_LINK}${NC}"
echo -e ""
echo -e "--------------------------------------------------"
echo -e "${YELLOW}⚠️ 注意事项：${NC}"
echo -e "1. 首次启动时，Sing-box 需要向 Let's Encrypt 申请证书，请等待 1-2 分钟后再连接。"
echo -e "2. 如果连接失败，请在 VPS 运行以下命令查看证书是否申请成功："
echo -e "   ${GREEN}journalctl -u sing-box -f${NC}"
echo -e "${GREEN}==================================================${NC}"
