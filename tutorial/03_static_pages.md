# Goal
ほぼ静的なページを作成する。  

# Wait a minute
ここで作成していくのは静的ページです。  
一番最初の基本中の基本ですね。  

さて、それではサンプルアプリケーションの第一歩を踏み出しましょう！  

# Index
Static pages  
|> Preparation  
|> Add route  
|> Create controller  
|> Create view & template  
|> Let's run!  
|> Add about page  
|> Little dynamic  
|> Before the end  

## Preparation
作成するにしても、まだサンプルアプリケーション用のプロジェクトを作成していませんね。  
プロジェクトの作成を行います。  

#### Example:

```cmd
>cd path/to/project
>mix phoenix.new sample_app
>cd sample_app
>mix ecto.create
>mix phoenix.server
>Ctrl+C
```

gitを使いブランチを切ります。  

#### Example:

```cmd
>git checkout -b static_pages
>git branch
  master
* static_pages
```

git initをしていない方は、初期化も行って下さい。  

この作業は章の始まりに必ず実施します。
何か問題が起こっても、ブランチを切り捨てるだけで済みます。

これで準備良し。  

それでは、Phoenix-Frameworkへ新しくページを追加していきましょう！  
しかし今回に関しては、自動生成は使わず手動でファイルを追加していきます。  

自動生成の有難みが分かります。  
ありがたや、ありがたや...  

## Add route
新しくページを追加するために、まず最初にやることはルーティングの追加です。  

ルーティングの追加を行います。  

#### File: web/router.ex

```elixir
scope "/", SampleApp do
  ...

  get "/home", StaticPagesController, :home
  get "/help", StaticPagesController, :help
end
```

追加したルーティングは以下のように、
Phoenix-Frameworkのコマンドを使って確認することができます。  

生成されたルーティングを見てみましょう。  

#### Example:

```cmd
>mix phoenix.routes
...
static_pages_path  GET     /home                SampleApp.StaticPagesController :home
static_pages_path  GET     /help                SampleApp.StaticPagesController :help
```

この時、指定したコントローラが存在している必要はありません。  

ルーティングの記述方法について、  
Phoenix-Frameworkのルーティングは次のような構成になっています。  

```elixir
get "/home", StaticPagesController, :home
```

上記を分解すると、以下のようになっています。  

- get: HTTPメソッド (HTTP Method)
- "/home": パス (Path)
- StaticPagesController: コントローラ名 (Controller name)
- :home: アクション名 (Action name)

では、デモアプリケーションで追加していたルーティングはどうなっているのでしょうか？  

```elixir
resources "/users", UserController
```

HTTPメソッド名ではなく、resources。  
また、アクションに当たる部分が記述されていませんね。  

これはRESTfulなルーティングを生成してくれる記述です。  

上記の記述で生成されたルーティングを覚えていますか？  
あの一行が以下のようなルーティングになります。  

#### Example:

```cmd
>mix phoenix.routes
...
user_path  GET     /users           DemoApp.UserController.index/2
user_path  GET     /users/:id/edit  DemoApp.UserController.edit/2
user_path  GET     /users/new       DemoApp.UserController.new/2
user_path  GET     /users/:id       DemoApp.UserController.show/2
user_path  POST    /users           DemoApp.UserController.create/2
user_path  PATCH   /users/:id       DemoApp.UserController.update/2
           PUT     /users/:id       DemoApp.UserController.update/2
user_path  DELETE  /users/:id       DemoApp.UserController.delete/2
```

少し強引ですが、上記に沿って表現すると...  

- resources: HTTPメソッド
- "users": パス
- UserController: コントローラ
- アクション部分: RESTfulのアクション全部

と言ったようになります。  

現状の段階では、resourcesを使えば一気にルーティングを作ってくれると言う認識で結構です。  
大丈夫です。チュートリアルを終える頃には、好きなルーティングを作れるようになっていることでしょう。  

#### Note:
Phoenix-Frameworkの大部分は、Elixirの機能であるマクロで作られています。  
ルーティングの機能もマクロで実装されています。  
チュートリアルでは触れませんが、興味があればマクロもといメタプログラミングに触ってみると面白いと思います。  

## Create Controller
次は、コントローラの作成を行っていきます。  

コントローラでは、ルーティングで定義したアクション(関数)を定義して、  
そのアクションで何をしたいのかを実装していきます。  

追加したルーティングは、homeアクションとhelpアクションですね。  
そのアクションを関数名として実装します。  

#### File: web/controllers/static_pages_controller.ex

```elixir
defmodule SampleApp.StaticPagesController do
  use SampleApp.Web, :controller

  def home(conn, _params) do
    render conn, "home.html"
  end

  def help(conn, _params) do
    render conn, "help.html"
  end
end
```

## Create view & template
Webサイトにレンダリングされるビューとテンプレートの作成を行っていきます。  
実際に人が見る画面の部分ですね。  

まずは、ビューから作成していきましょう。  
ビューで実装した関数は、テンプレートで利用することができます。  

今回は、特に何もすることがないのでビューを作成するだけになります。  

#### File: web/views/static_pages_view.ex

```elixir
defmodule SampleApp.StaticPagesView do
  use SampleApp.Web, :view
end
```

#### Note:
ビューはレンダリングをする際、必ず必要になります。  
テンプレートに対応したビューがない場合、レンダリングできませんので注意して下さい。  

#### Directory: web/templates/static_pages
"static_pages"と言う名称でディレクトリを作成して下さい。  

間違えないように注意して下さい。  
テンプレートのディレクトリ名はコントローラの先頭名と合わせる必要があります。  

Phoenix-Frameworkでは、デフォルトでEExというテンプレートが使えます。  
(どちらかと言うと、Elixirに実装されている機能になりますが...)  
Ruby on Railsで使えるERBのようなものと思っておけば大丈夫です。  

実際に非常によく似ています。  

テンプレートを作成を作成していきましょう。  

#### File: web/templates/static_pages/home.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages Home!</h2>
</div>
```

#### File: web/templates/static_pages/help.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages Help!</h2>
</div>
```

EExの機能は、次のページ追加で使っていきます。  

## Let's run!
サーバを起動して作成したページを見てみましょう。  

#### Example:

```cmd
>mix phoenix.server
```

以下のアドレスへアクセスして下さい。  

#### URL: http://localhost:4000/home
#### URL: http://localhost:4000/help

手動でファイルやディレクトリの追加をしていくのは、中々面倒ですよね。  
しかし、これが基本の手順になります。是非、覚えておいて下さい。  

続いて、Aboutページを追加してみましょう。  

## Add about page
Aboutページを追加します。  

先の手順に倣い、ルーティングから追加します。  

#### File: web/router.ex

```elixir
scope "/", SampleApp do
  pipe_through :browser # Use the default browser stack

  ...
  get "/about", StaticPagesController, :about
end
```

先ほどコントローラは用意していますので、aboutアクション関数を追加するだけになります。  

#### File: web/controllers/static_pages_controller.ex

```elixir
defmodule SampleApp.StaticPagesController do
  ...

  def about(conn, _params) do
    render conn, "about.html"
  end
end
```

ビューも用意済みなので、aboutテンプレートを追加するだけになります。  

#### File: web/templates/static_pages/about.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages About!</h2>
</div>
```

サーバを起動して作成したページを見てみましょう。  

##### Example:

```cmd
>mix phoenix.server
```

以下のアドレスへアクセスして下さい。  

#### URL: http://localhost:4000/about

## Little dynamic
少しだけ動的に動くページに改造してみましょう。  

作成した3つのテンプレートで以下の部分が、ある一言を除き同じですね。  

```html
<h2>Welcome to Static Pages Home!</h2>

<h2>Welcome to Static Pages Help!</h2>

<h2>Welcome to Static Pages About!</h2>
```

この異なる部分を動的に指定できるようにしていきましょう。  

StaticPagesコントローラの各アクション関数を以下のように変更して下さい。  

#### File: web/controllers/static_pages_controller.ex

```elixir
def home(conn, _params) do
  render conn, "home.html", message: "Home"
end
```

```elixir
def help(conn, _params) do
  render conn, "help.html", message: "Help"
end
```

```elixir
def about(conn, _params) do
  render conn, "about.html", message: "About"
end
```

レンダリングするテンプレートへ変数を送っています。  

- message ・・・ テンプレート内での名称 (変数名)
- "About" ・・・ 値

次は、この変数をテンプレートで使うように変更します。  

#### File: web/templates/static_pages/home.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages <%= @message %>!</h2>
</div>
```

#### File: web/templates/static_pages/help.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages <%= @message %>!</h2>
</div>
```

#### File: web/templates/static_pages/about.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages <%= @message %>!</h2>
</div>
```

テンプレート内では以下のように記述すると、  
コントローラやビュー側から送った値を参照できます。  

```html
<%= @name %>
```

もう少し踏み込んでみます。  
上記の記述はElixirコードの埋め込みを行っています。  
変数以外にもif記述、for記述や関数の実行などが行えます。  

今回はここまでとなります。  
これで、ページを追加していく方法は分かりましたね。  

## Before the end
ソースコードをマージします。  

```cmd
>git add .
>git commit -am "Finish static_pages."
>git checkout master
>git merge static_pages
```

#Speaking to oneself
Phoenix-Frameworkで新しくページを追加する方法を学びました。  
何を追加すればいいか分かれば、難しくはありませんね。  

次の章では、Phoenix-Frameworkのレイアウトについて学んで行きます。  

# Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/static-pages?version=4.0#top)  