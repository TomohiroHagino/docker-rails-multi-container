#現状では使用しなくなったが、一応とっておく。
#!/bin/bash
set -e

bundle install
yarn install

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# この２ディレクトリが消えるとpumaとnginxが動かないので念のため
mkdir -p tmp/pids
mkdir -p tmp/sockets

# 自動でrailsサーバー立ち上げたいときはコメントアウトを外す
# bundle exec puma -C config/puma.rb

# 以下のコマンドでメインプロセスを作動させる。 (DockerfileにセットしたCMD)
exec "$@"
