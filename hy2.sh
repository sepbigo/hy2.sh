#!/bin/bash

# 检查curl是否已经安装
if command -v curl >/dev/null 2>&1; then
    echo "curl 已经安装，正在执行命令..."
    bash <(curl -fsSL https://get.hy2.sh/)
else
    echo "curl 未安装。正在尝试安装curl..."
    sudo apt-get update && sudo apt-get install curl -y
    if command -v curl >/dev/null 2>&1; then
        echo "curl 安装成功，正在执行命令..."
        bash <(curl -fsSL https://get.hy2.sh/)
    else
        echo "尝试安装curl失败。请手动安装curl再运行此脚本。"
    fi
fi

# 执行openssl命令
openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout /etc/hysteria/server.key -out /etc/hysteria/server.crt -subj "/CN=bing.com" -days 36500

# 更改文件所有权
sudo chown hysteria /etc/hysteria/server.key
sudo chown hysteria /etc/hysteria/server.crt

# 提示用户输入端口
read -p "请输入端口: " port

# 提示用户输入密码
read -sp "请输入密码: " password

# 更新配置文件
echo "
listen: :$port #端口

tls:
  cert: /etc/hysteria/server.crt
  key: /etc/hysteria/server.key

auth:
  type: password
  password: $password
  
masquerade:
  type: proxy
  proxy:
    url: https://bing.com 
    rewriteHost: true
" > /etc/hysteria/config.yaml

echo "配置文件已更新。"
systemctl start hysteria-server.service
systemctl enable hysteria-server.service
systemctl status hysteria-server.service
