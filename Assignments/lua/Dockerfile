FROM ubuntu:latest

RUN apt-get -y update && \
    apt-get -y install \
    git wget curl unzip \
    fish \
    lua5.1 luarocks \
    build-essential

RUN apt-get install -y libpcre3-dev \
    libssl-dev perl make build-essential curl

# RUN systemctl disable nginx && systemctl stop nginx
RUN apt-get -y install --no-install-recommends wget gnupg ca-certificates lsb-release
RUN wget -O - https://openresty.org/package/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/openresty.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/arm64/ubuntu $(lsb_release -sc) main" | \
    tee /etc/apt/sources.list.d/openresty.list > /dev/null

RUN apt-get -y update
RUN apt-get -y install openresty

RUN luarocks install moonscript && \
    luarocks install lapis && \
    luarocks install lpeg

ENV PATH="/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin:${PATH}"
ENV LUA_PATH="/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;./?.lua"
ENV LUA_CPATH="/usr/local/lib/lua/5.1/?.so;./?.so"

RUN apt-get -y install neovim

# RUN add-apt-repository ppa:maveonair/helix-editor && apt-get update
# RUN apt-get install helix

# # Install Lua LSP
# RUN wget -O - https://github.com/LuaLS/lua-language-server/releases/download/3.12.0/lua-language-server-3.12.0-linux-arm64.tar.gz > ~/lua-language-server-3.12.0-linux-arm64.tar.gz
# RUN mkdir -p ~/.local/share/lua-lang-server && \
#     tar --extract --file ~/lua-language-server-3.12.0-linux-arm64.tar.gz -av -C ~/.local/share/lua-lang-server
# RUN ln -s ~/.local/share/lua-lang-server/bin/lua-language-server ~/.local/bin/lua-language-server
# RUN lua-language-server

