# 複数コンテナ対応タイプ

# サービスに関して

```
設定のダルさを極限まで抑えつつRailsプロジェクトをDocker化できます。

rails newで作ることもできるようにしました。

こちらは、コンテナオーケストレーション対応版。

基本的にマルチにコンテナを使用したい場合はこちらを使う。

```

# 環境構築

```
0. まずはこのリポジトリをクローンして、.gitフォルダを削除する
(mac,linuxの場合)
$ rm -rf .git
(windowsの場合)
> del .git

1. docker desktopをインストールしたあと、Railsのリポジトリをクローンする。
(mac,linux)
$ mv <クローンしたいRailsリポジトリ名>/* .
(windows)
> move <クローンしたいRailsリポジトリ名>/* .

(もし新規作成するなら、 rails new <プロジェクト名> --skip-test)
(mac,linux)
(mv <プロジェクト名>/* .)
(windows)
(move <プロジェクト名>/* .)

2. そして、/docker/railsディレクトリに入っているDockerfileの1行目にかかれたRubyのバージョンをお好みのものに変更する。

3. そして、/docker/railsディレクトリに入っているGemfileをクローンしたプロジェクトのGemfileで上書きする。Gemfile.lockは空っぽにする。
(mac,linux)
$ cp Gemfile ./docker/rails/
$ cp Gemfile.lock ./docker/rails/
(windowsの場合)
> copy Gemfile ./docker/rails/
> copy Gemfile.lock ./docker/rails/

(Railsのバージョンは5もしくは6、データベースはpostgresql,mysql,sqlite3のどれかを使用するのを想定してます。)


4. ここから環境構築。初回時はこれ（imageがなければimageビルドから）コンテナの起動までを行う。
(mac,linux,windows共通)
docker-compose up -d

railsコンテナのターミナルに直接アクセス
(mac,linux,windows共通)
docker-compose exec rails ash

5. サーバーの立ち上げ
(mac,linux,windows共通)
bundle exec puma -C config/puma.rb
(rails s -b 0.0.0.0で立ち上げると、nginxにbindされない。)

6. DB関連 コンテナに直接アクセスして以下のコマンドをやればOK(bundle execつけなくてもいい)
#(コンテナ内で) rails db:reset
#(コンテナ内で) rails db:create
#(コンテナ内で) rails db:migrate

作業を終了する時はコンテナを終了させます。
(mac,linux,windows共通)
docker-compose stop

2回目以降からは以前に作ったコンテナを起動させます。
(mac,linux,windows共通)
docker-compose start

2回目以降start起動するとデタッチドモードになってログを確認できません。見たいときはこれ。-fを外せばtailしない。
(mac,linux,windows共通)
docker-compose logs -f

railsコマンドを使用するときはvendor/bundle配下のrailsを使うようにします。
（まずはコンテナにアクセス、そして以下コマンド）
(mac,linux,windows共通)
bundle exec rails ●●● ~
```

# Rspec
```
モデルでのテストコードを作っていく場合は下記のように
（まずはコンテナにアクセス、そして以下コマンド）
$ rails g rspec:model model_name

コントローラーでのテストコードを作っていく場合は下記のようにする。コントローラー名にsをつけるのを忘れずに。
（まずはコンテナにアクセス、そして以下コマンド）
$ rails g rspec:controller controllers_name
```

```
# Dockerの操作マニュアルはこちら
```
https://qiita.com/okyk/items/a374ddb3f853d1688820
```
# Rspecの操作マニュアルはこちら
```
一番良かった参考書
https://leanpub.com/everydayrailsrspec-jp/read

models_spec 初めてRSpecでRailsアプリのモデルをテストする
https://qiita.com/y4u0t2a1r0/items/ae4d832fbfb697b4b253

controllers_spec
※今となってはやらなくていいです。

requests_spec リクエストに対するレスポンスが仕様に沿っているか検証します。
※コントローラースペックの代わりに現在はこちらのテストをします。
https://qiita.com/t2kojima/items/ad7a8ade9e7a99fb4384

features_spec、アプリの利用者が使うものと全く同じフォームを使ってテストできます。
https://nyoken.com/rspec-feature-capybara

モデルにあるファイルアップロード機能や、メール送信機能、ジオコーディング(緯度経度)連携のテストの仕方
説明しきれず、、コレを買うといいかも
https://leanpub.com/everydayrailsrspec-jp/read

# Rubocop
```
コンテナ内でrubocopと入力すれば使えます。
```

# ESLint
```
https://blog.rista.jp/entry/2017/12/27/135622
```
# デバッグ
```
pryいれてあります
```

# 新規作成するときの注意書き

```
nginxとpumaの連携をするために
config/puma.rbの末尾に以下を足す必要があります。

----------------------------------------------
app_root = File.expand_path("../..", __FILE__)
bind "unix://#{app_root}/tmp/sockets/puma.sock"

ポートでのlistenは不要なのでコメントアウトする。
#port  ENV.fetch("PORT") { 3000 }

ポートでのlistenはコメントしておかないとsocketのlistenが行われず（pumaの仕様？）ハマった。
https://qiita.com/himatani/items/b6c267dfb330a47fea9f
----------------------------------------------

そして、
nginxコンテナとの連携のために
`tmp/sockets/puma.sockと言うファイルが必要になるんですけども、
これは自動でディレクトリ作成されないため
ディレクトリをホスト側で自分で作る必要があります。

(ホスト側で)mkdir -p tmp/pids
(ホスト側で)mkdir -p tmp/sockets

あと、postgresqlやmysqlを使用する場合、
config/database.ymlでdbの宛先してあげる設定する必要があります。

default: &default
  adapter: postgresql
  encoding: unicode
  host: db
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <%= ENV.fetch('DATABASE_USER') { 'postgres' } %>
  password: <%= ENV.fetch('DATABASE_PASSWORD') { 'password' } %>
  host: <%= ENV.fetch('DATABASE_URL') { 'db' } %>
  port: <%= ENV.fetch('DATABASE_PORT') { 5432 } %>

こんな感じで。
これでバインドできます。
```
