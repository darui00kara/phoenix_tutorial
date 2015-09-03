#Goal
ほぼ静的なページを作成する。  

#Wait a minute
ここで作成していくのは静的ページです。  
一番最初の基本中の基本ですね。  

さて、それではサンプルアプリケーションの第一歩を踏み出しましょう！  

#Index
Static pages  
|> Preparation  
|> Add route  
|> Create controller  
|> Create view & template  
|> Let's run!  
|> Add page  
|> Little dynamic
|> Before the end  

##Preparation
作成するにしても、まだサンプルアプリケーション用のプロジェクトを作成していませんね。  
プロジェクトの作成を行います。  

```cmd
>cd path/to/project
>mix phoenix.new sample_app
>cd sample_app
>mix ecto.create
>mix phoenix.server
>Ctrl+C
```

gitを使いブランチを切ります。  

```cmd
>git checkout -b static_pages
>git branch
  master
* static_pages
```

####Description:
git initをしていない方は、初期化も行って下さい。  

これで準備良し。  

それでは、Phoenix-Frameworkでページを追加してみましょう！  
しかし今回に関しては、自動生成は使わず手動でファイルを追加していきます。  

自動生成の有難みが分かります。  
ありがたや、ありがたや...  

##Add route
まず最初にやることは、ルーティングの追加です。  

####ファイル: web/router.ex
ルーティングの追加を行います。  

```elixir
scope "/", SampleApp do
  pipe_through :browser # Use the default browser stack

  get "/", PageController, :index
  get "/home", StaticPagesController, :home
  get "/help", StaticPagesController, :help
end
```

生成されたルーティングを見てみましょう。  

```cmd
>mix phoenix.routes
...
static_pages_path  GET     /home                SampleApp.StaticPagesController :home
static_pages_path  GET     /help                SampleApp.StaticPagesController :help
```

ルーティングの記述方法について、  
以下の記述を例に少し説明します。  

```elixir
get "/home", StaticPagesController, :home
```

以下のようになっています。  

- get ・・・ HTTPメソッド
- "/home" ・・・ パス
- StaticPagesController ・・・ コントローラ
- :home ・・・ Action

では、デモアプリケーションで追加していた以下のようなルーティングは？  

```elixir
resources "/users", UserController
```

HTTPメソッド名ではなく、resources。  
また、アクションに当たる部分が記述されていませんね。  

これはRESTfulなルーティングを生成してくれる記述です。  

上記の記述で生成されたルーティングを覚えていますか？  
あの一行が以下のようなルーティングになります。  

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

つまり、無理やり強引に表すと・・・  

- resources ・・・ HTTPメソッド
- "users" ・・・ パス
- UserController ・・・ コントローラ
- アクション部分 ・・・ RESTfulのアクション全部

と言ったようになります。  

現状の段階では、resourcesを使えば一気にルーティングを作ってくれると言う認識で結構です。  
大丈夫です。チュートリアルを終える頃には、好きなルーティングを作れるようになっていることでしょう。  

##Create Controller
コントローラの作成を行っていきます。  

####ファイル: web/controllers/static_pages_controller.ex

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

##Create view & template
ビューとテンプレートの作成を行っていきます。  

####ファイル: web/views/static_pages_view.ex

```elixir
defmodule SampleApp.StaticPagesView do
  use SampleApp.Web, :view
end
```

####ディレクトリ: web/templates/static_pages
static_pagesと言う名称でディレクトリを作成して下さい。  

間違えないように注意して下さい。  
テンプレートのディレクトリ名はコントローラの先頭名と合わせる必要があります。  

Phoenix-Frameworkでは、デフォルトでEExテンプレートが使えます。  
Ruby on Railsにおけるerbのようなものと思っておけば大丈夫です。  

実際に非常に似ています。  

####ファイル: web/templates/static_pages/home.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages Home!</h2>
</div>
```

####ファイル: web/templates/static_pages/help.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages Help!</h2>
</div>
```

##Let's run!
サーバを起動して作成したページを見てみましょう。  

```cmd
>mix phoenix.server
```

以下のアドレスへアクセスして下さい。  

####アクセス: http://localhost:4000/home
####アクセス: http://localhost:4000/help

手動でファイルやディレクトリの追加をしていくのは、中々面倒ですよね。  
しかし、これが基本の手順になります。是非、覚えておいて下さい。  

続いて、新しくページを追加する手順をやっていきましょう。  

##Add about page
Aboutページを追加します。  

####ファイル: web/router.ex
ルーティングを追加します。  

```elixir
scope "/", SampleApp do
  pipe_through :browser # Use the default browser stack

  ...
  get "/about", StaticPagesController, :about
end
```

####ファイル: web/controllers/static_pages_controller.ex
アクション用の関数を追加します。  

```elixir
def about(conn, _params) do
  render conn, "about.html"
end
```

####ファイル: web/templates/static_pages/about.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages About!</h2>
</div>
```

サーバを起動して作成したページを見てみましょう。  

```cmd
>mix phoenix.server
```

以下のアドレスへアクセスして下さい。  

####アクセス: http://localhost:4000/about

##Little dynamic
少しだけ動的に動くようにしてみましょう。  

以下の部分が、ある一言を除き同じです。  

```html
<h2>Welcome to Static Pages Home!</h2>
<h2>Welcome to Static Pages Help!</h2>
<h2>Welcome to Static Pages About!</h2>
```

この異なる部分を動的に指定してみましょう。  

####ファイル: web/controllers/static_pages_controller.ex
以下のようにアクション用の関数を変更して下さい。  

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

これは、レンダリングするテンプレートへ値を送っています。  

- message ・・・ テンプレートでの名称
- "About" ・・・ 値

次は、この値をテンプレートで使うように変更します。  

####ファイル: web/templates/static_pages/home.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages <%= @message %>!</h2>
</div>
```

####ファイル: web/templates/static_pages/help.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages <%= @message %>!</h2>
</div>
```

####ファイル: web/templates/static_pages/about.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages <%= @message %>!</h2>
</div>
```

以下のように記述すると、コントローラ側から送った値を参照できます。  

```html
<%= @~ %>
```

今回はここまでとなります。  
これで、ページを追加していく方法は分かりましたね。  

##Before the end
ソースコードをマージします。  

```cmd
>git add .
>git commit -am "Finish static_pages."
>git checkout master
>git merge static_pages
```

#Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/static-pages?version=4.0#top)  