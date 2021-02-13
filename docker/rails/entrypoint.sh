#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# 自動でrailsサーバー立ち上げたいときはコメントアウトを外す
# bundle exec puma -C config/puma.rb

# 以下のコマンドでメインプロセスを作動させる。 (DockerfileにセットしたCMD)
exec "$@"
