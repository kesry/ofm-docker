#!/bin/bash
set -e

# 每次启动清掉遗留的锁文件
rm -f /root/.our-free-model/service.lock

# 后台启动 Caddy
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

# 前台启动 standalone（容器主进程）
exec npm run start:standalone
