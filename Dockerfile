FROM ubuntu:latest

RUN apt-get update && apt-get install -y git nodejs npm gh curl build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev ripgrep net-tools iproute2 libyaml-dev

RUN git clone https://github.com/rbenv/rbenv.git /opt/rbenv && \
    git clone https://github.com/rbenv/ruby-build.git /opt/rbenv/plugins/ruby-build && \
    echo 'export PATH="/opt/rbenv/bin:$PATH"' >> /etc/environment && \
    echo 'eval "$(rbenv init -)"' >> /etc/bash.bashrc && \
    export PATH="/opt/rbenv/bin:$PATH" && eval "$(rbenv init -)" && \
    cd /opt/rbenv/plugins/ruby-build && git pull && \
    RBENV_ROOT=/opt/rbenv /opt/rbenv/bin/rbenv install 3.4.4 && \
    RBENV_ROOT=/opt/rbenv /opt/rbenv/bin/rbenv install 3.3.8 && \
    RBENV_ROOT=/opt/rbenv /opt/rbenv/bin/rbenv install 3.2.3 && \
    RBENV_ROOT=/opt/rbenv /opt/rbenv/bin/rbenv global 3.4.4 && \
    userdel -r ubuntu && \
    useradd -m -s /bin/bash -u 1000 claude && \
    mkdir -p /workspace && \
    chown claude:claude /workspace

# Force cache invalidation for Claude Code installation
ARG CLAUDE_CACHE_BUST=1
RUN npm install -g @anthropic-ai/claude-code

# Copy scripts to /usr/local/bin as root
COPY refresh_token /usr/local/bin/refresh_token
COPY login_start /usr/local/bin/login_start
COPY login_finish /usr/local/bin/login_finish
COPY entrypoint.sh /usr/local/bin/claude-entrypoint
RUN chmod +x /usr/local/bin/refresh_token && \
    chmod +x /usr/local/bin/login_start && \
    chmod +x /usr/local/bin/login_finish && \
    chmod +x /usr/local/bin/claude-entrypoint

USER claude
WORKDIR /workspace

# Create .claude directory and declare it as a volume
RUN mkdir -p /home/claude/.claude
VOLUME ["/home/claude/.claude"]

# Create .config/claude-code directory for Claude to initialize its config
RUN mkdir -p /home/claude/.config/claude-code && \
    echo 'export PATH="/opt/rbenv/bin:$PATH"' >> /home/claude/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> /home/claude/.bashrc

ENTRYPOINT ["/usr/local/bin/claude-entrypoint"]