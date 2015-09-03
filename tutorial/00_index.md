#バージョン: v0.4

#Caution!!
####～ 記事を改修中 ～

####変更内容
####・記事の分割(理由：情報が多い、記事長い)
####・Markdownでの表示へ修正(理由：見辛い)
####・説明の追加/修正(理由：分かり辛い)

####以上、ご迷惑をお掛けします。m(\_ \_)m

#Goal
Ruby on Rails TutorialのサンプルアプリケーションをPhoenix-Frameworkで作成する。  

#Dev-Environment
OS: Windows8.1  
Erlang: Eshell V6.4, OTP-Version 17.5  
Elixir: v1.0.5  
Node.js： v0.12.4  
Phoenix Framework: v1.0.0  
Safetybox: v0.1.2  
Scrivener: v1.0.0  
Bootstrap: v3.3.5  
PostgreSQL: postgres (PostgreSQL) 9.4.4  

####Caution:
リリースバージョンが変わればアップグレードする予定です。  
予めご了承下さい。m(\_ \_)m  

#Wait a minute
Ruby on Rails Tutorial作者様、日本語訳を実施して下さった訳者様方に感謝を捧げます。  

Ruby on Rails TutorialをPhoenix-Frameworkでやっていく連載ものです。  

内容は、Phoenix-Frameworkの初心者、入門者レベルです。  
基本、アプリケーション作成部分を主眼に置き実施していきます。  
なので、Elixirの記法であったり、TDD / BDD部分は端折ります。  

いきなりですが、Rails Tutorialの1章の部分は飛ばします。  
Gitは使いますが、herokuは使いません。  

ソースコード一式はGithubへアップしています。  
また、各章毎にプロジェクト名でブランチが存在しています。  
Github: [darui00kara/phoenix_tutorial (master)](https://github.com/darui00kara/phoenix_tutorial)  

ロードマップは以下のリンク先です。  
参考: [Roadmap](http://daruiapprentice.blogspot.jp/2015/08/rails-tutorial-for-phoenix-roadmap.html)  

フレームワークのバージョンをv1.0.0へアップグレードしました。
参考: [Upgrade version of Phoenix-Framework](http://daruiapprentice.blogspot.jp/2015/08/rails-tutorial-for-phoenix-upgrade-version.html)  

デザインを修正しました。
参考: [Modification of the design](http://daruiapprentice.blogspot.jp/2015/09/rails-tutorial-for-phoenix-modification-of-the-design.html)  

#Index
Rails Tutorial for Phoenix  
|> 環境構築(一章相当部分)  
|> [Demo application(二章相当部分)](http://daruiapprentice.blogspot.jp/2015/06/rails-tutorial-for-phoenix_20.html)  
|> [Static pages(三章相当部分)](http://daruiapprentice.blogspot.jp/2015/06/rails-tutorial-for-phoenix_21.html)  
|> Elixirの記法や機能(四章相当部分)  
|> [Filling in layout(五章相当部分)](http://daruiapprentice.blogspot.jp/2015/06/rails-tutorial-for-phoenix_26.html)  
|> [ユーザモデルの作成(六章相当部分)](http://daruiapprentice.blogspot.jp/2015/07/elixirphoenix.html)  
|> [ユーザ登録(七章相当部分)](http://daruiapprentice.blogspot.jp/2015/07/rails-tutorial-for-phoenix.html)  
|> [サインイン/サインアウト(八章相当部分)](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html)  
|> [ユーザーの更新・表示・削除(九章相当部分)](http://daruiapprentice.blogspot.jp/2015/07/updating-showing-and-deleting-users.html)  
|> [ユーザーのマイクロポスト(第十章相当部分)](http://daruiapprentice.blogspot.jp/2015/08/user-of-micropost.html)  
|> [ユーザーをフォローする(第十一章相当部分)](http://daruiapprentice.blogspot.jp/2015/08/following-users.html)  
|> Refactoring  

##環境構築(一章相当部分)
Phoenix-Frameworkの簡単な説明。  
参考: [Phoenix-Frameworkの簡単なまとめ](http://daruiapprentice.blogspot.jp/2015/06/elixirphoenixphoenix.html)  

環境構築について。  
以前、Elixir+Phoenix環境を構築した記事があるのでそちらを参照して下さい。  

Git  
|> [Githubへの登録](http://daruiapprentice.blogspot.jp/2015/04/github.html)  
|> [msysGitのインストール](http://daruiapprentice.blogspot.jp/2015/05/msysgit.html)  
|> [GithubへSSH鍵を登録](http://daruiapprentice.blogspot.jp/2015/05/githubssh.html)  
|> [ローカルからGithubのリポジトリへ接続](http://daruiapprentice.blogspot.jp/2015/05/git.html)  

Elixir  
|> [Elixirが熱い！？知らないけどとりあえずインストールする](http://daruiapprentice.blogspot.jp/2015/05/elixir.html)  
|> [ElixirにmixでPhoenixを混ぜ混ぜしてやる！！](http://daruiapprentice.blogspot.jp/2015/05/elixirmixphoenix.html)  
|> [Phoenixが欲しいって言うからNode.jsをインスコするよ！！](http://daruiapprentice.blogspot.jp/2015/05/phoenixnodejs.html)  
|> [今更ハイライト！？SublimeText3でElixirをハイライトする！！](http://daruiapprentice.blogspot.jp/2015/07/elixir-highlights-in-sublime.html)  
|> [Upgrade phoenix.new of mix archive](http://daruiapprentice.blogspot.jp/2015/07/upgrade-phoenix-new-of-mix-archive.html)  

##[デモアプリを作ろう！！(二章相当部分)](http://daruiapprentice.blogspot.jp/2015/06/rails-tutorial-for-phoenix_20.html)
特になし  

##[基本的なところ(三章相当部分)](http://daruiapprentice.blogspot.jp/2015/06/rails-tutorial-for-phoenix_21.html)
特になし  

##Elixirの記法や機能(四章相当部分)
Elixirの記法や機能について知りたい方へ。  
先駆者の方がいらっしゃいます。なので、そちらを参照すべし！  
参考： [Qiita - Elixir 基礎文法最速マスター](http://qiita.com/niku/items/729ece76d78057b58271)  

[@niku](https://twitter.com/niku_name)氏、参考にさせて頂きました。  

##[レイアウトを作ろう～(五章相当部分)](http://daruiapprentice.blogspot.jp/2015/06/rails-tutorial-for-phoenix_26.html)
寄り道： [PhoenixからBootstrap3を使う！+今更CSS入門！？](http://daruiapprentice.blogspot.jp/2015/06/elixirphoenixphoenixbootstrap3css.html)

##[ユーザモデルの作成(六章相当部分)](http://daruiapprentice.blogspot.jp/2015/07/elixirphoenix.html)
ここでは、PhoenixのGuideにある[Ecto Models](http://www.phoenixframework.org/v0.13.1/docs/ecto-models)の機能を紹介すると共に、  
ユーザモデルにパスワード(カラム)の追加を行う。  

詳細・・・  
モデルモジュールの自動生成、マイグレーション、  
再マイグレーション(カラム追加)、Validation(検証)、virtualオプションを実施する。  

各機能  
|> [シンプルなsafetybox(暗号化ライブラリ)を使う](http://daruiapprentice.blogspot.jp/2015/06/elixirsafetybox.html)  
|> [PhoenixとEctoのコマンドまとめ](http://daruiapprentice.blogspot.jp/2015/06/phoenixphoenixecto.html)  
|> [EctoModelsの機能を使う](http://daruiapprentice.blogspot.jp/2015/06/elixirphoenixectomodels.html)  
|> [Ecto.ChangesetのValidate関数を使う](http://daruiapprentice.blogspot.jp/2015/06/elixirphoenixectochangesetvalidate.html)  
|> [Ectoを使って再マイグレーションする](http://daruiapprentice.blogspot.jp/2015/06/phoenixecto.html)  
|> [Ectoのvirtualオプションを検証する](http://daruiapprentice.blogspot.jp/2015/07/phoenixectovirtual.html)  
|> [Ectoで1対多の関係性を検証する](http://daruiapprentice.blogspot.jp/2015/07/phoenixecto1.html)  

##[ユーザ登録(七章相当部分)](http://daruiapprentice.blogspot.jp/2015/07/rails-tutorial-for-phoenix.html)
この章ではユーザを登録し表示できるようにする。  

詳細・・・(モデル以外の自動生成は利用しないで実施する)  
ユーザを表示、gravatar画像、ユーザを登録、  
ユーザ登録失敗、ユーザ登録成功、flashを利用を実施する。  

各機能  
|> [ユーザを画面に表示する](http://daruiapprentice.blogspot.jp/2015/07/elixirphoenix_7.html)  
|> [Use a Gravatar image](http://daruiapprentice.blogspot.jp/2015/07/elixirphoenixuse-gravatar-image.html)  
|> [User registration](http://daruiapprentice.blogspot.jp/2015/07/elixirphoenixuser-registration.html)  

##[サインイン/サインアウト(八章相当部分)](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html)
この章ではサインインとサインアウトの機能を実装する。  

詳細・・・  
サインイン、サインアウト、セッション、認証、ページ制限。  

各機能  
|> [Create login form](http://daruiapprentice.blogspot.jp/2015/07/title.html)  
|> [Add the session to the login](http://daruiapprentice.blogspot.jp/2015/07/elixirphoenixadd-session-to-login.html)  
|> [Processing after the sign-in](http://daruiapprentice.blogspot.jp/2015/07/processing-after-the-sign-in.html)  

##[ユーザーの更新・表示・削除(九章相当部分)](http://daruiapprentice.blogspot.jp/2015/07/updating-showing-and-deleting-users.html)
この章ではユーザの更新・表示・削除を実装する。  
またそれに伴って、参照できるページを制限する認可とアクセス制御、ユーザの一覧に対するページネーションを実装します。  

認可とアクセス制御、ページネーションは厄介ですね・・・意外とガッツリしてる。  
すんなり終わらせてはくれなさそうです(笑)  

各機能  
|> [PhoenixのPlugについて分かったこと](http://daruiapprentice.blogspot.jp/2015/07/phoenix-plug.html)  
|> [Phoenixでもページネーションがしたい！！(その1)](http://daruiapprentice.blogspot.jp/2015/07/phoenix-pagination-01.html)  
|> [Phoenixでもページネーションがしたい！！(その2)](http://daruiapprentice.blogspot.jp/2015/07/phoenix-pagination-02.html)  
|> [Updating users](http://daruiapprentice.blogspot.jp/2015/07/updating-users.html)  
|> [Authorization](http://daruiapprentice.blogspot.jp/2015/07/phoenix-authorization.html)  
|> [All Users (implements pagination)](http://daruiapprentice.blogspot.jp/2015/07/all-users-implements-pagination.html)  
|> [Delete user](http://daruiapprentice.blogspot.jp/2015/07/phoenix-delete-user.html)  

##[ユーザーのマイクロポスト(第十章相当部分)](http://daruiapprentice.blogspot.jp/2015/08/user-of-micropost.html)
この章では、ユーザと紐づくマイクロポストの実装を行う。  
Micropostモデルの作成から始まり、マイクロポストの表示、作成、削除を実装する。  

各機能  
|> [Create Micropost model](http://daruiapprentice.blogspot.jp/2015/07/create-micropost-model.html)  
|> [Microposts List (with pagination)](http://daruiapprentice.blogspot.jp/2015/08/microposts-list-with-pagination.html)  
|> [Operation of Micropost](http://daruiapprentice.blogspot.jp/2015/08/operation-of-micropost.html)  

##[ユーザーをフォローする(第十一章相当部分)](http://daruiapprentice.blogspot.jp/2015/08/following-users.html)
この章では、ユーザのフォロー機能を実装する。  

各機能  
|> [many to many (Part 1)](http://daruiapprentice.blogspot.jp/2015/08/many-to-many.html)  
|> [many to many (Part 2)](http://daruiapprentice.blogspot.jp/2015/08/many-to-many-part2.html)  
|> [Relationship Model](http://daruiapprentice.blogspot.jp/2015/08/relationship-model.html)  
|> [Web interface for the user who follows](http://daruiapprentice.blogspot.jp/2015/08/web-interface-for-the-user-who-follows.html)  
|> [Micropost of following users](http://daruiapprentice.blogspot.jp/2015/08/micropost-of-following-users.html)  

##Refactoring
第十一章終了時点では、ソースコードが汚いので修正をします。  
後に、記事へ反映後、削除する予定です。  

Refactoring  
|> [Pagination refactoring](http://daruiapprentice.blogspot.jp/2015/08/pagination-refactoring.html)  
|> [View refactoring](http://daruiapprentice.blogspot.jp/2015/08/phoenix-tutorial-view-refactoring.html)  
|> [Templates refactoring](http://daruiapprentice.blogspot.jp/2015/08/rails-tutorial-for-phoenix-templates-refactoring.html)  
|> [Last refactoring](http://daruiapprentice.blogspot.jp/2015/08/rails-tutorial-for-phoenix-last-refactoring.html)  

#Speaking to oneself 
何故、Ruby on Rails Tutorialをやるのか？  

理由は三つ・・・  

- Web開発における知識が習得できる
- Phoenix-Frameworkのチュートリアルがない (公式のGuideくらい？)
- ElixirはRubyライク、Phoenix-FrameworkはRailsライクなので変換が比較的容易

上記の三点に合致し、Rails Tutorialはちょうど良い教材になるため。  

#Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/)  