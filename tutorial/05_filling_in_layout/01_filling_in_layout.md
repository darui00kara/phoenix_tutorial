#Goal
レイアウトを作成する。  

#Wait a minute
今回はレイアウトを作成します。  
また、カスタムCSSとBootstrapの導入も行います。  

このチュートリアルでは、CSSやBootstrapの機能は利用しますが、  
必要がある場合を除き、説明をする予定はありません。  

#Index
Filling in layout  
|> Preparation  
|> Custom CSS and Bootstrap  
|> Layout template  
|> Link and PathHelper  
|> Rendering chain  
|> You want to add a contact page

##Preparation
毎度の準備です。  

ブランチを切ります。  

```cmd
>cd path/to/sample_app
>git checkout -b filling_in_layout
```

Bootstrapをダウンロードし、解凍しておいて下さい。  
ダウンロード: [Bootstrap - Download](http://getbootstrap.com/getting-started/#download)  

##Custom CSS and Bootstrap
カスタムCSSとBootstrapの導入を行います。  

Bootstrapの配置から行います。  

解凍すると以下のようなディレクトリ構成になっていると思います。  

```txt
Bootstrap  
|-css  
|  |-bootstrap.css  
|  |-bootstrap.css.map  
|  |-bootstrap.min.css  
|  |-bootstrap-theme.css  
|  |-bootstrap-theme.css.map  
|  |-bootstrap-theme.min.css  
|  
|-fonts  
|  |-glyphicons-halflings-regular.eot  
|  |-glyphicons-halflings-regular.svg  
|  |-glyphicons-halflings-regular.ttf  
|  |-glyphicons-halflings-regular.woff  
|  |-glyphicons-halflings-regular.woff2  
|  
|-js  
   |-bootstrap.js  
   |-bootstrap.min.js  
   |-npm.js  
```

配置するファイルと配置先ディレクトリは以下のとおりです。  

- css/bootstrap.css --> priv/static/css/bootstrap.css
- css/bootstrap.css.map --> priv/static/css/bootstrap.css.map
- fonts/glyphicons-halflings-regular.eot --> priv/static/glyphicons-halflings-regular.eot
- fonts/glyphicons-halflings-regular.svg --> priv/static/glyphicons-halflings-regular.svg
- fonts/glyphicons-halflings-regular.ttf --> priv/static/glyphicons-halflings-regular.ttf
- fonts/glyphicons-halflings-regular.woff --> priv/static/glyphicons-halflings-regular.woff
- fonts/glyphicons-halflings-regular.woff2 --> priv/static/glyphicons-halflings-regular.woff2
- js/bootstrap.js --> priv/static/js/bootstrap.js

これで配置完了です。  

続いて、カスタムCSSを作成します。  
(少し長いです)  

####ファイル: priv/static/css/custom.css

```css
@import "boostrap.css";

/* universal */
html {
  overflow-y: scroll;
}

body {
  padding-top: 60px;
}

section {
  overflow: auto;
}

textarea {
  resize: vertical;
}

.center {
  text-align: center;
}

.center h1 {
  margin-bottom: 10px;
}

/* typography */
h1, h2, h3, h4, h5, h6 {
  line-height: 1;
}

h1 {
  font-size: 3em;
  letter-spacing: -2px;
  margin-bottom: 30px;
  text-align: center;
}

h2 {
  font-size: 1.2em;
  letter-spacing: -1px;
  margin-bottom: 30px;
  text-align: center;
  font-weight: normal;
  color: #777777;
}

p {
  font-size: 1.1em;
  line-height: 1.7em;
}
```

読み込むのはこの次に行います。  

##Layout template
デフォルトのレイアウトをカスタマイズします。  

しかし、その前に少しだけ説明を入れさせて下さい。  
Phoenix-Frameworkのレイアウトについてです。  

"mix phoenix.new"で生成したプロジェクトには、既にレイアウトが用意されています。  
全テンプレートにこのレイアウトが適応されます。  

つまり、レイアウトテンプレートを変更すれば全テンプレートのレイアウトが変更されるわけですね。  

レイアウトのファイルは以下になります。  

- web/templates/layout/app.html.eex
- web/views/layout_view.ex

それでは、レイアウトテンプレート変更しましょう。  

####ファイル: web/templates/layout/app.html.eex
以下のように変更して下さい。  

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Sample App!</title>
    <link rel="stylesheet" href="<%= static_path(@conn, "/css/app.css") %>">
    <link rel="stylesheet" href="<%= static_path(@conn, "/css/bootstrap.css") %>">
    <link rel="stylesheet" href="<%= static_path(@conn, "/css/custom.css") %>">

    <!--[if lt IE 9]>
    <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
  </head>

  <body>
    <header class="navbar navbar-inverse">
      <div class="navbar-inner">
        <div class="container">
          <a class="logo" href="<%= page_path(@conn, :index) %>"></a>
          <nav>
            <ul class="nav nav-pills pull-right">
              <li><a href="<%= static_pages_path(@conn, :home) %>">Home</a></li>
              <li><a href="<%= static_pages_path(@conn, :help) %>">Help</a></li>
              <li><a href="<%= static_pages_path(@conn, :about) %>">About</a></li>
              <li><a href=#>Sign in</a></li>
              <li><a href="http://www.phoenixframework.org/docs">Phoenix Get Started</a>
            </ul>
          </nav>
        </div> <!-- container -->
      </div> <!-- navbar-inner -->
    </header>

    <div class="container">

      <h2>
        <p class="alert alert-info" role="alert"><%= get_flash(@conn, :info) %></p>
        <p class="alert alert-danger" role="alert"><%= get_flash(@conn, :error) %></p>
      </h2>

      <%= @inner %>

    </div> <!-- /container -->

    <script src="<%= static_path(@conn, "/js/app.js") %>"></script>
    <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
    <script src="<%= static_path(@conn, "/js/bootstrap.js") %>"></script>
  </body>
</html>
```

一つ一つ説明していきますね。  

CSSの読み込みを追加しています。  

```html
<link rel="stylesheet" href="<%= static_path(@conn, "/css/bootstrap.css") %>">
<link rel="stylesheet" href="<%= static_path(@conn, "/css/custom.css") %>">
```

static_path/2はPathHelperと呼ばれる機能を使ってパスを取得しています。  
このstatic_path/2は静的ファイルへのパスを取得しています。(.../priv/static/)  

IE9未満に対応するために記述しています。  
魔法の言葉のようなものなので、深くは考えなくてよいです。  

```html
<!--[if lt IE 9]>
<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
```

ヘッダー部分になります。  
classに記述している部分は、Bootstrapの機能です。  

```html
<header class="navbar navbar-inverse">
  <div class="navbar-inner">
    <div class="container">
      <a class="logo" href="<%= page_path(@conn, :index) %>"></a>
      <nav>
        <ul class="nav nav-pills pull-right">
          <li><a href="<%= static_pages_path(@conn, :home) %>">Home</a></li>
          <li><a href="<%= static_pages_path(@conn, :help) %>">Help</a></li>
          <li><a href="<%= static_pages_path(@conn, :about) %>">About</a></li>
          <li><a href=#>Sign in</a></li>
          <li><a href="http://www.phoenixframework.org/docs">Phoenix Get Started</a>
        </ul>
      </nav>
    </div> <!-- container -->
  </div> <!-- navbar-inner -->
</header>
```

static_pages_path/2については次に説明します。  

テンプレートの埋め込みを行っている部分です。  

```html
<%= @inner %>
```

先ほど、レイアウトテンプレートの説明をしました。  
全テンプレートに適応される言いましたが、こういうことです。  

レイアウトテンプレートのこの部分に各テンプレートの内容が埋め込まれるため、  
レイアウトテンプレートを変更すると、全テンプレートに適応されます。  

javascriptの読み込みを追加しています。  

```html
<script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
<script src="<%= static_path(@conn, "/js/bootstrap.js") %>"></script>
```

次は、リンクとPathHelperの説明をします。  

##Link and PathHelper
リンクとPathHelperについて説明します。  

先ほどのこの記述についてです。  

```html
<%= static_pages_path(@conn, :home) %>
```

これを説明するには二つの要素を説明する必要があります。  
<%= ~ %>とstatic_pages_path/2です。  

まず、<%= ~ %>について。  
これは、eexテンプレートに対してElixirコードを記述できるようにするものです。  

例えば、eexテンプレートでif文を使いたい時...  

####Example:

```html
<%= if true do %>
  <p>trueだよ</p>
<% else %>
  <p>falseだよ</p>>
<% end %>
```

といったように、Elixirコードを使うことができるわけですね。  
static_pagesで使った<%= @message %>も同じことです。  

static_pages_path/2の説明をします。  
これはPathHelperの機能です。  

ルーティングを設定すると、そのルーティングのパスを取得できる関数を生成しています。(マクロです。)  

以下のように出力するコマンドがありましたね。  

```cmd
>mix phoenix.routes
...
static_pages_path  GET     /home                SampleApp.StaticPagesController :home
static_pages_path  GET     /help                SampleApp.StaticPagesController :help
```

この左側にstatic_pages_pathとありますね。  
これが関数名となっています。  

また引数の要素ですが...  

第一引数の@connは、Plug.Connのことです。毎回指定するので魔法の言葉と思って下さい。  
(Plugの説明をすると、それだけで終わってしまいます。)  

第二引数の:homeは、アクション名です。  

これにより、static_pages_pathの:homeアクションのパスを寄越せ！と書いているわけですね。  

さてさて、以下の記述ですが、  
Phoenix_HTMLライブラリの機能を使って記述することができます。  
(Phoenix-Frameworkは幾つかのライブラリで構成されています。その内の一つです。)  

```html
<li><a href="<%= static_pages_path(@conn, :home) %>">Home</a></li>
```

link/2を使って記述。  

```html
<li><%= link "Home", to: static_pages_path(@conn, :home) %></li>
```

こちらの方が分かりやすいですね。  

##Rendering chain
レイアウトのヘッダー、フッダー、IE9未満の部分を別テンプレートに記述し、  
それを呼び出す形で描画させたいと思います。  

これは、レンダリングチェーンと呼ばれる機能で、テンプレートからテンプレートを呼び出すことができます。  
(Ruby on Railsのパーシャルみたいなもんだと思って下さい。)  

####ファイル: web/templates/layout/app.html.eex
レイアウトテンプレートを以下のように変更して下さい。  

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Sample App!!</title>
    <link rel="stylesheet" href="<%= static_path(@conn, "/css/app.css") %>">
    <link rel="stylesheet" href="<%= static_path(@conn, "/css/bootstrap.css") %>">
    <link rel="stylesheet" href="<%= static_path(@conn, "/css/custom.css") %>">

    <%= render "shim.html" %>
  </head>

  <body>
    <%= render "header.html", conn: @conn %>

    <div class="container">
      <h2>
        <p class="alert alert-info" role="alert" style="text-align: center;"><%= get_flash(@conn, :info) %></p>
        <p class="alert alert-danger" role="alert" style="text-align: center;"><%= get_flash(@conn, :error) %></p>
      </h2>

      <%= @inner %>

      <%= render "footer.html", conn: @conn %>
    </div>

    <script src="<%= static_path(@conn, "/js/app.js") %>"></script>
    <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
    <script src="<%= static_path(@conn, "/js/bootstrap.js") %>"></script>
  </body>
</html>
```

すっきりしましたね。  

別テンプレートを呼び出す方法ですが、以下のようにして呼び出すことができます。  

```html
<%= render "テンプレート名", 引数 %>
```

今回であれば、以下の部分ですね。  

```html
<%= render "shim.html" %>
<%= render "header.html", conn: @conn %>
<%= render "footer.html", conn: @conn %>
```

それでは、各テンプレートを作成していきましょう！  

####ファイル: web/templates/layout/shim.html.eex

```html
<!--[if lt IE 9]>
<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
```

####ファイル: web/templates/layout/header.html.eex

```html
<header class="navbar navbar-inverse">
  <div class="navbar-inner">
    <div class="container">
      <a class="logo" href="<%= page_path(@conn, :index) %>"></a>
      <nav>
        <ul class="nav nav-pills pull-right">
          <li><%= link "Home", to: static_pages_path(@conn, :home) %></li>
          <li><%= link "Help", to: static_pages_path(@conn, :help) %></li>
          <li><a href=#>Sign in</a></li>
        </ul>
      </nav>
    </div> <!-- container -->
  </div> <!-- navbar-inner -->
</header>
```

####ファイル: web/templates/layout/footer.html.eex

```html
<footer class="footer">
  <nav>
    <ul>
      <li><%= link "About", to: static_pages_path(@conn, :about) %></li>
      <li><a href="http://www.phoenixframework.org/docs">Phoenix Get Started</a></li>
    </ul>
  </nav>
</footer>
```

####ファイル: priv/static/css/custom.css
ついでに、カスタムCSSに以下を追加して下さい。  

```css
/* header */
#logo {
  float: left;
  margin-right: 10px;
  font-size: 1.7em;
  color: white;
  text-transform: uppercase;
  letter-spacing: -1px;
  padding-top: 9px;
  font-weight: bold;
  line-height: 1;
}

#logo:hover {
  color: white;
  text-decoration: none;
}

/* footer */
footer {
  margin-top: 45px;
  padding-top: 5px;
  border-top: 1px solid #eaeaea;
  color: #777777;
}

footer a {
  color: #555555;
}

footer a:hover {
  color: #222222;
}

footer small {
  float: left;
}

footer ul {
  float: right;
  list-style: none;
}

footer ul li {
  float: left;
  margin-left: 10px;
}
```

##You want to add a contact page
コンタクトページの追加を行います。  

大した内容でもないので、さくっと終わらせます。  

####ファイル: web/router.ex
ルーティングを追加します。  

```elixir
scope "/", SampleApp do
  pipe_through :browser # Use the default browser stack
  ...

  get "/contact", StaticPagesController, :contact
end
```

####ファイル: web/controllers/static_pages_controller.ex
アクション用の関数を追加します。  

```elixir
def contact(conn, _params) do
  render conn, "contact.html"
end
```

####ファイル: web/templates/static_pages/contact.html.eex
テンプレートの内容は以下の通り。  

```html
<div class="jumbotron">
  <h1>Contact</h1>
</div>
```

####ファイル: web/templates/layout/footer.html.eex
コンタクトページへのリンクを追加します。  

```html
<footer class="footer">
  <nav>
    <ul>
      <li><%= link "About", to: static_pages_path(@conn, :about) %></li>
      <li><%= link "Contact", to: static_pages_path(@conn, :contact) %></li>
      <li><a href="http://www.phoenixframework.org/docs">Phoenix Get Started</a></li>
    </ul>
  </nav>
</footer>
```

##Modify home template
home.html.eexテンプレートを少しだけ変更します。  

####ファイル: web/templates/static_pages/home.html.eex
ユーザ登録のための、ちょっとした仕込みです。  

```html
<div class="jumbotron">
  <h1>Welcom to the Sample App</h1>

  <h2>
    This application is
    <a href="http://railstutorial.jp/">Ruby on Rails Tutorial</a>
    for Phoenix sample application.
  </h2>

  <a href="#" class="btn btn-large btn-primary">Sign up now!</a>
</div>
```

####ファイル: web/controllers/static_pages_controller.ex
@messageはhomeアクションで不要となったので、削除します。  

```elixir
def home(conn, _params) do
  render conn, "home.html"
end
```

#Speaking to oneself
レイアウト、カスタムCSS、Bootstrap、リンク、名前付きルート...etc、色々と新しい内容が出てきましたね。  
頭の中が少し、混乱しますね。  

カスタムCSSは、必要になったら徐々に追記します。  
リンク、名前付きルートはこの後でも頻繁に出てきます。  

混乱してしまっている方は、気にしないで進みましょう。  
足踏みしたり座り込むより、歩きながら走りながら思考しましょう。  

大丈夫、慣れれば特別なことなんて何もありません。  
その内、見直してみると理解できていますよ。(多分)  

#Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/filling-in-the-layout?version=4.0#top)  