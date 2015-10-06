#バージョン: v0.5

#Goal
Ruby on Rails TutorialのサンプルアプリケーションをPhoenix-Frameworkで作成する。  

#Dev-Environment
OS: Windows8.1  
Erlang: Eshell V7.1, OTP-Version 18.1  
Elixir: v1.1.1  
Node.js： v0.12.4  
Phoenix Framework: v1.0.3  
Safetybox: v0.1.2  
Scrivener: v1.0.0  
Bootstrap: v3.3.5  
PostgreSQL: postgres (PostgreSQL) 9.4.4  

#Wait a minute
Ruby on Rails Tutorial作者様、日本語訳を実施して下さった訳者様方に感謝を捧げます。  

Ruby on Rails TutorialをPhoenix-Frameworkで実施する企画です。  

内容は、Phoenix-Frameworkの初心者、入門者を対象としてものです。  
アプリケーション作成部分を主眼に置き実施していきます。  
そのため、Elixirの記法であったり、TDD / BDDの部分は端折ります。  

また、Gitは使いますが、herokuは使いません。  

何故、Ruby on Rails Tutorialをやるのか？  

理由は三つ・・・  

- Web開発における基本的な知識が足りないから習得する
- Phoenix-Frameworkのチュートリアルがないから自分で作る (公式のGuideくらい？)
- ElixirはRubyライク、Phoenix-FrameworkはRailsライクなので変換が比較的容易

ソースコード一式はGithubへアップしています。  
Github: [darui00kara/phoenix_tutorial (master)](https://github.com/darui00kara/phoenix_tutorial)  

#Index
Rails Tutorial for Phoenix  
|> What is Phoenix-Framework?  
|> 環境構築(一章相当部分)  
|> [Demo application(二章相当部分)](https://github.com/darui00kara/phoenix_tutorial/blob/master/tutorial/02_demo_app.md)  
|> [Static pages(三章相当部分)](https://github.com/darui00kara/phoenix_tutorial/blob/master/tutorial/03_static_pages.md)  
|> Elixirの記法や機能(四章相当部分)  
|> [Filling in layout(五章相当部分)](https://github.com/darui00kara/phoenix_tutorial/blob/master/tutorial/04_filling_in_layout.md)  
|> [Modeling users(六章相当部分)](https://github.com/darui00kara/phoenix_tutorial/blob/master/tutorial/05_modeling_users.md)  
|> [Sign up(七章相当部分)](https://github.com/darui00kara/phoenix_tutorial/blob/master/tutorial/06_sign_up.md)  
|> [Sign-in and Sign-out(八章相当部分)](https://github.com/darui00kara/phoenix_tutorial/blob/master/tutorial/07_sign_in_out.md)  
|> [Updating users(九章相当部分)](https://github.com/darui00kara/phoenix_tutorial/blob/master/tutorial/08_updating_users.md)  
|> [User microposts(第十章相当部分)](https://github.com/darui00kara/phoenix_tutorial/blob/master/tutorial/09_user_microposts.md)  
|> [Following users(第十一章相当部分)](https://github.com/darui00kara/phoenix_tutorial/blob/master/tutorial/10_following_users.md)  

# Roadmap

- [x] v0.1 ・・・ Rails Tutorialを一通りやり通す
- [x] v0.2 ・・・ ソースコードのリファクタリング、変更点の記事
- [x] v0.3 ・・・ v1.0.0へバージョンアップ
- [x] v0.4 ・・・ デザイン(CSS)の改善
- [x] v0.5 ・・・ 記事の改修(ほぼ書き直し)
- [ ] v1.0 ・・・ Phoenix v1.0.3アップグレード and 記事の説明や不足を追加
- [ ] v0.? ・・・ RSS(フィード)の実装
- [ ] v?.? ・・・ 新機能の実装
- [ ] v?.? ・・・ 自作のページネーションライブラリを組込む

##v0.1の詳細

Ruby on Rails TutorialをPhoenix-Frameworkで実施して記事にする。  

##v0.2の詳細

ソースコードのリファクタリングを実施します。  
具体的には、機能の重複を排除、粒度が大きい関数を分割、抽象度の向上..etc  
主体としては上記の三つになります。それ以外にも細かいところがある感じですね。  

記事の回収と並行するのが難しいので、変更点の記事をアップしていきます。  

~~現在、着手する所ですので暫し待たれよ。~~  

##v0.3の詳細

v1.0.0へバージョンアップします。  

##v0.4 (デザインの改善)

さて今のままでは、デザインがクソです。  
せめて、styleで直書きしている部分をCSSに書き直すくらいはしないといけません。  
デザイン(CSS)の改善します。  

##v0.5の詳細

ソースコードを改善したら、記事へと反映しないと分かり辛くなってしまいますね。  

記事の改修には、以前目次に書いていた改修内容も含まれています。  
これは約束(コミット)している内容ですね。  

ほぼ書き直しに近い形になりますかね・・・  

##v1.0の詳細

~~現在のところ何をするか決めていません。~~  
~~実装していない機能の実装をするかもしれませんし、新機能の実装をするかもしれません。~~  

Phoenix v1.0.3アップグレードを行いチュートリアルの一通りの実施を行う。  
上記の実施に伴い、記事の説明や不足分を加筆修正する。  

##v0.? (RSSフィード)

フィードは実装していませんでしたね。  
そうTutorialを一通り実施したら、RSSフィードを別で実装すると言いました。  
(忘れてませんよ？)  

##v?.? (Pagination)

利用していたページネーションライブラリですが・・・非常に役に立ちました。  
しかし、機能が足りないと感じる部分もありました。  

なので、あのライブラリをベースにして自分用のページネーションライブラリの実装を考えています。  
どの段階で着手するかは分かりません。  

しかし、着手する前により良い改善や新しいライブラリが見つかればやらない可能性もあります。  
その時の状況次第ですね。  

Railsで使えるWillPaginateみたいなライブラリを誰かが実装してくれれば、  
私が作る必要もないのですが(笑)  

##言うだけなら無料

Channelを使って書き直してみる？  

#Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/)  