FROM node:26-bookworm-slim

# 构建参数：版本号由工作流传入
ARG VERSION=v2.8.0

# 安装 Caddy 和 git
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update \
    && apt-get install -y caddy \
    && rm -rf /var/lib/apt/lists/*

# 拉取项目源码：分支由 ARG 传入
WORKDIR /app
RUN git clone -b ${VERSION} https://github.com/Ebony-Vinyl/dsh-our-free-model.git --depth=1 . \
    && npm install

# 准备数据目录
RUN mkdir -p /root/.our-free-model

# Caddy 配置：8080 -> 127.0.0.1:18900
RUN cat > /etc/caddy/Caddyfile <<'EOF'
:8080 {
    reverse_proxy 127.0.0.1:18900 {
        header_up Host "127.0.0.1:18900"
        header_up Origin "http://127.0.0.1:18900"
        header_up X-Real-IP "127.0.0.1"
        header_up X-Forwarded-For "127.0.0.1"
        header_up X-Forwarded-Proto "http"
    }
}
EOF

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
