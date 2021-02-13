# 複数コンテナ対応タイプ

# サービスに関して

- 名称：プロジェクト名


# 自分用のメモ。

```
nginxとpumaの連携をするために
config/puma.rbの末尾に以下を足す必要があった。

app_root = File.expand_path("../..", __FILE__)
bind "unix://#{app_root}/tmp/sockets/puma.sock"

そして、
nginxコンテナとの連携のために
dockerボリュームで

tmp_volumeと、public_volumeというところにrailsのtmpディレクトリを同期。
その影響で、tmp/pids/ とtmp/sockets/ が
環境を変えた時に消えてしまう問題があった。

そしてその２つが消えてしまうと、pumaが動かなくなり、nginxとの同期もうまくいかなくなる。
なので、rails用のentrypoint.shに

mkdir -p tmp/pids
mkdir -p tmp/sockets

を追加した。

これでバインドできることを確認した。
```


# 環境構築

```
0. まずはこのリポジトリをクローンして、.gitフォルダを削除する
rm -rf .git

1. docker desktopをインストールしたあと、Railsのリポジトリをクローンする。
$ git clone <クローンしたいRailsリポジトリ>
$ mv <クローンしたいRailsリポジトリ名>/* .
(もし新規作成するなら、 rails new . --database=postgresql --skip-test)

2. そして、/docker/railsディレクトリに入っているDockerfileの1行目にかかれたRubyのバージョンをお好みのものに変更する。

3. そして、/docker/railsディレクトリに入っているGemfileをクローンしたプロジェクトのGemfileで上書きする。Gemfile.lockは空っぽにする。
$ cp Gemfile ./docker/rails/
$ cp Gemfile.lock ./docker/rails/

(Railsのバージョンは5、開発時はsqlite3、本番時はpostgresqlを使用するのを想定してます。)


4. ここから環境構築。　初回時はこれ（imageがなければimageビルドから）コンテナの起動までを行う。
$ docker-compose up -d

railsコンテナのターミナルに直接アクセス
コンテナから抜ける時はCommand+P,Q
$ docker-compose exec rails ash

5. サーバーの立ち上げ
$ bundle exec puma -C config/puma.rb
(rails s -b 0.0.0.0で立ち上げると、nginxにbindされない。)

6. DB関連 コンテナに直接アクセスして以下のコマンドをやればOK(bundle execつけなくてもいい)
#(コンテナ内で) rails db:reset
#(コンテナ内で) rails db:create
#(コンテナ内で) rails db:migrate

作業を終了する時はコンテナを終了させます。
$ docker-compose stop

2回目以降からは以前に作ったコンテナを起動させます。
$ docker-compose start

2回目以降start起動するとデタッチドモードになってログを確認できません。見たいときはこれ。-fを外せばtailしない。
$ docker-compose logs -f

railsコマンドを使用するときはvendor/bundle配下のrailsを使うようにします。
（まずはコンテナにアクセス、そして以下コマンド）
$ bundle exec rails ●●● ~
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
