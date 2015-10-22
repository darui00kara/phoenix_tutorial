# Goal
サインイン、サインアウト機能を実装する。  

# Wait a minute
セッションを使いサインイン、サインアウト機能を実装していきます。  
また、シンプルな認証(Authentication)についても実装してみましょう。  

# Index
Sign-in and Sign-out  
|> Preparation  
|> Create SessionController  
|> Authentication  
|> Sign-in  
|> Sign-in Form  
|> Sign-in link  
|> How do session?  
|> Use session  
|> Continuation of Sign-in state  
|> Current user  
|> Change links and layout  
|> Sign-out  
|> After registration, sign-in  
|> Before the end  

## Preparation
作業前にブランチを切ります。  

```cmd
>cd path/to/sample_app
>git checkout -b sign_in_out
```

## Create SessionController
セッションを扱うためのコントローラを作成します。  

セッションの使い方の説明は、後に行います。  
まずはルーティングを追加していきます。  

#### ファイル: web/router.ex
セッション用のルーティングを追加します。  

```elixir
scope "/", SampleApp do
  ...
  get "/signin", SessionController, :new
  post "/session", SessionController, :create
  delete "/signout", SessionController, :delete
end
```

追加されたルーティングを確認しましょう。  

```cmd
>mix phoenix.routes
...
session_path  GET     /signin         SampleApp.SessionController.new/2
session_path  POST    /session        SampleApp.SessionController.create/2
session_path  DELETE  /signout        SampleApp.SessionController.delete/2
```

コントローラを作成します。  

#### ファイル: web/controllers/session_controller.ex
Sessionコントローラを以下の通り、作成します。  

```elixir
defmodule SampleApp.SessionController do
  use SampleApp.Web, :controller

  def new(conn, _params) do
    render conn, "signin_form.html"
  end

  def create(conn, _params) do
    redirect(conn, to: static_pages_path(conn, :home))
  end

  def delete(conn, _params) do
    redirect(conn, to: static_pages_path(conn, :home))
  end
end
```

続いて、ビューと仮のテンプレートも作成します。  

#### ファイル: web/views/session_view.ex

```elixir
defmodule SampleApp.SessionView do
  use SampleApp.Web, :view
end
```

#### ファイル: web/templates/session/signin_form.html.eex

```html
<div class="jumbotron">
  <h2>Sign in!!</h2>
</div>
```

このSessionコントローラにセッションやサインイン / サインアウトの処理を追加していきます。  

## Authentication
サインインとは切っても切り離せない認証を作成していきます。  

ここで作成する認証処理は、他のライブラリなどを利用しません。  

実際はライブラリなどを使って、安全性の高い認証を行うべきでしょうが、  
ここでは、DBのパスワードの値と入力されたパスワードが一致するか否かを  
判定するだけの非常にシンプルな処理を作成します。  

それでは、作成していきましょう。  

まず作成しなければいけないのは、EmailでDBからデータ取得する部分です。  

#### ファイル: web/models/user.ex
Emailから取得する関数を作成します。  

```elixir
def find_user_from_email(email) do
  SampleApp.Repo.get_by(SampleApp.User, email: email)
end
```

認証を扱うモジュールを作成します。  

#### ファイル: lib/authentication.ex

```elixir
defmodule SampleApp.Authentication do
  def authentication(user, password) do
    case user do
      nil -> false
        _ ->
          password == SampleApp.Encryption.decrypt(user.password_digest)
    end
  end
end
```

## Sign-in
サインインを扱うモジュールも作成してしまいましょう。  

#### ファイル: lib/sign_in.ex

```elixir
defmodule SampleApp.Signin do
  import SampleApp.Authentication
  
  def sign_in(email, password) do
    user = SampleApp.User.find_user_from_email(email)
    case authentication(user, password) do
      true -> {:ok, user}
         _ -> :error
    end
  end
end
```

先ほど、作成した認証のモジュールを使用しています。  
認証に成功すればサインインができます。  

Sessionコントローラのcreateアクションにサインインの処理を作成しましょう。  

#### ファイル: web/controllers/session_controller.ex

```elixir
def create(conn, %{"signin_params" => %{"email" => email, "password" => password}}) do
  case sign_in(email, password) do
    {:ok, user} ->
      conn
      |> put_flash(:info, "User sign-in is success!!")
      |> redirect(to: static_pages_path(conn, :home))
    :error ->
      conn
      |> put_flash(:error, "User sign-in is failed!! email or password is incorrect.")
      |> redirect(to: session_path(conn, :new))
  end
end
```

## Sign-in Form
サインインを行うための入力フォームを作成します。  

#### ファイル: web/templates/session/signin_form.html.eex
サインインのフォームは以下のようになります。  

```html
<h1>Sign in!!</h1>

<%= form_for @conn, session_path(@conn, :create), [name: :signin_params], fn f -> %>
  <%= if f.errors != [] do %>
    <div class="alert alert-danger">
      <p>Oops, something went wrong! Please check the errors below:</p>
      <ul>
        <%= for {attr, message} <- f.errors do %>
          <li><%= humanize(attr) %> <%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-group">
    <label>Email</label>
    <%= email_input f, :email, class: "form-control" %>
  </div>

  <div class="form-group">
    <label>Password</label>
    <%= password_input f, :password, class: "form-control" %>
  </div>

  <div class="form-group">
    <%= submit "Sign-in!", class: "btn btn-primary" %>
  </div>
<% end %>
```

どこかで見たことあるような内容だと思いませんか？  
そう、サインアップの入力フォームと似ていますね。  

フォームを使う時は、このような形になることが多いと思います。  

## Sign-in link
レイアウトヘッダにあるサインインのリンクを修正します。  

#### ファイル: web/templates/layout/header.html.eex

```html
<header class="navbar navbar-inverse">
  <div class="navbar-inner">
    <div class="container">
      <a class="logo" href="<%= page_path(@conn, :index) %>"></a>
      <nav>
        <ul class="nav nav-pills pull-right">
          <li><%= link "Home", to: static_pages_path(@conn, :home) %></li>
          <li><%= link "Help", to: static_pages_path(@conn, :help) %></li>
          <li><%= link "Sign-in", to: session_path(@conn, :new) %></li>
        </ul>
      </nav>
    </div> <!-- container -->
  </div> <!-- navbar-inner -->
</header>
```

## How do session?
Phoenix-Frameworkでは、特に設定を行わなくてもセッションを使うことができます。  
しかし、どこで設定しているか知るために、セッションの設定をしているソースコードを見てみます。  

#### ファイル: config/config.exs
各クッキーに署名するために、secret_key_baseの値を利用しています。  

```elixir
config :sample_app, SampleApp.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "****",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: SampleApp.PubSub,
           adapter: Phoenix.PubSub.PG2]
```

#### ファイル: lib/sample_app/endpoint.ex
Endpointでデフォルトのセッションを設定しています。  

```elixir
defmodule SampleApp.Endpoint do
  use Phoenix.Endpoint, otp_app: :sample_app

  ...

  plug Plug.Session,
    store: :cookie,
    key: "_sample_app_key",
    signing_salt: "abcwc8CM"

  ...
end
```

見ての通り、Phoenix-Frameworkでのセッションは、  
Plug.Sessionを利用しています。  

セッションを使った簡単な例。  

#### Example:

```elixir
defmodule SampleApp.PageController do
  use Phoenix.Controller

  def index(conn, _params) do
    conn = put_session(conn, :message, "hoge")
    message = get_session(conn, :message)

    text conn, message
  end
end
```

#### Note:

- put_session/2: セッションへ値を格納する。
- get_session/2: セッションの値を取り出す。

## Use session
Sessionコントローラへセッションの処理を追加します。  

#### ファイル: web/controllers/session_controller.ex
サインインモジュールのインポートを追加します。  

```elixir
import SampleApp.Signin
```

セッションに値を格納するための処理を追加します。  

```elixir
def create(conn, %{"signin_params" => %{"email" => email, "password" => password}}) do
  case sign_in(email, password) do
    {:ok, user} ->
      conn
      |> put_flash(:info, "User sign-in is success!!")
      |> put_session(:user_id, user.id)
      |> redirect(to: static_pages_path(conn, :home))
    :error ->
      conn
      |> put_flash(:error, "User sign-in is failed!! email or password is incorrect.")
      |> redirect(to: session_path(conn, :new))
  end
end
```

追加は一行だけですが、これでセッションに値を格納しています。  
ユーザを識別するためのIDを格納しています。  

## Continuation of Sign-in state
今のままではサインイン後、別のページに移動するとサインインした状態が継続されません。  
サインインを継続させるために状態維持の機能を実装します。  

どうやって実現するかですが、自作のプラグを作成して各コントローラで実行するようにします。  

#### ファイル: lib/plugs/check_authentication.ex

```elixir
defmodule SampleApp.Plugs.CheckAuthentication do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _) do
    user_id = get_session(conn, :user_id)
    if session_present?(user_id) do
      assign(conn, :current_user, SampleApp.Repo.get(SampleApp.User, user_id))
    else
      conn
    end
  end

  defp session_present?(user_id) do
    case user_id do
      nil -> false
      _   -> true
    end
  end
end
```

セッションからユーザIDを取得し、IDが存在すればConnのassignにユーザデータを格納しています。  
このassignに値が存在するか否かでサインインの状態を判断します。  

また後にやりますが、現在のサインインしているユーザを取得する際にも利用します。  

各コントローラに今回使っているCheckAuthenticationを追加して下さい。  
例としてSessionコントローラにプラグを追加します。  

#### ファイル: web/controllers/session_controller.ex

```elixir
defmodule SampleApp.SessionController do
  use SampleApp.Web, :controller

  import SampleApp.Signin

  plug SampleApp.Plugs.CheckAuthentication

  ...
end
```

## Current user
サインインしている現在のユーザを取得してデバッグ表示に追加しましょう。  

ビューをサポートするためのヘルパーモジュールを作成します。  

####ファイル: lib/helpers/view_helper.ex
先ほど、Connのassignに値を格納していたと思う。  
その値をここで取り出して利用する。  

```elixir
defmodule SampleApp.Helpers.ViewHelper do
  def current_user(conn) do
    conn.assigns[:current_user]
  end
end
```

####ファイル: web/web.ex
上記のヘルパーモジュールへimportを追加します。  

```elixir
def view do
  quote do
    ...

    # My view helper
    import SampleApp.Helpers.ViewHelper
  end
end
```

####ファイル: web/templates/layout/debug.html.eex
デバッグ用のテンプレートへユーザ名とIDの表示を追加する。  

```elixir
<div class="debug_dump">
  <p>Controller: <%= get_controller_name @conn %></p>
  <p>Action: <%= get_action_name @conn %></p>
  <%= if current_user(@conn) do %>
    <p>User (ID): <%= current_user(@conn).name %> (<%= current_user(@conn).id %>)</p>
  <% end %>
</div>
```

現在のユーザが存在するか否かで処理を切り替えている。  
これにより、サインインしていない状態だとユーザは表示されない。  

## Change links and layout
サインインした状態としていない状態で表示されるテンプレートの内容を切り替えます。  
サインインをしたのに、サインインのボタンやリンクが表示されているのはおかしいですからね。  

皆さん予想が付いている気がしますが、if記述を使って処理を分けます。  

#### Example:

```html
<%= if current_user(@conn) do %>
  ログインしている時の処理...
<% else %>
  ログインしていない時の処理...
<% end %>
```

また、少し動的な表示を行えるように、bootstrapのドロップダウンを使います。  
それでは実装しましょう！  

#### ファイル: web/templates/layout/header.html.eex

```html
<header class="navbar navbar-inverse">
  <div class="navbar-inner">
    <div class="container">
      <a class="logo" href="<%= page_path(@conn, :index) %>"></a>
      <nav>
        <ul class="nav nav-pills pull-right">
          <li><%= link "Home", to: static_pages_path(@conn, :home) %></li>
        <%= if current_user(@conn) do %>
          <li class="dropdown">
            <!-- Dropdown Menu -->
            <a href="#" class="dropdown-toggle" id="account" data-toggle="dropdown">
              User Menu
              <span class="caret"></span>
            </a>
            <!-- Dropdown List -->
            <ul class="dropdown-menu" aria-labelledby="account">
              <li><%= link "Profile", to: user_path(@conn, :show, current_user(@conn)) %><li>
              <li><%= link "Help", to: static_pages_path(@conn, :help) %></li>
              <li class="divider"></li>
              <li><%= link "Sign-out", to: session_path(@conn, :delete) %></li>
            </ul>
          </li>
        <% else %>
          <li><%= link "Sign-in", to: session_path(@conn, :new) %></li>
        <% end %>
      </ul>
      </nav>
    </div> <!-- container -->
  </div> <!-- navbar-inner -->
</header>
```

## Sign-out
ようやっとサインイン機能と対になる、サインアウト機能を実装します。  
サインインほど、難しい処理はしません。  

#### ファイル: web/controllers/session_controller.ex

```elixir
def delete(conn, _params) do
  conn
  |> put_flash(:info, "Sign-out now! See you again!!")
  |> delete_session(:user_id)
  |> redirect(to: static_pages_path(conn, :home))
end
```

サインアウトの旨を知らせるメッセージの表示。  
それと、セッションの削除を行っています。  

## After registration, sign-in
サインアップ後、サインイン処理を行うようにサインアップ時の処理を修正します。  

Userコントローラのcreateアクションを以下のように修正して下さい。  

#### ファイル: web/controllers/user_controller.ex

```elixir
def create(conn, %{"user" => user_params}) do
  changeset = SampleApp.User.changeset(%SampleApp.User{}, user_params)

  if changeset.valid? do
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User registration successfully!!")
        |> put_session(:user_id, user.id)
        |> redirect(to: static_pages_path(conn, :home))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  else
    render(conn, "new.html", changeset: changeset)
  end
end
```

Repo.insert/2の戻り値は、{:ok, model}か{:error, changeset}です。  
なので、データの挿入が成功時はサインインの処理を行い、失敗時は再度入力を促すようにしています。  

## Before the end
ソースコードをマージします。  

```cmd
>git add .
>git commit -am "Finish sign_in_out."
>git checkout master
>git merge sign_in_out
```

#Speaking to oneself
お疲れ様でした。これで第八章は終わりです。
サインイン、サインアウトの実装はどうでしたか？  
結構、色々なことをやったので少し苦労したかもしれません。  

次の第九章は、このチュートリアルにおける最初の山場です。  
ページネーションや認可、残りのユーザの処理を実装します。  

大変でしょうけど、Webサイトには必須の内容なので一緒に頑張りましょう！！  

#Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/sign-in-sign-out?version=4.0#top)  
[Ecto.Query](http://hexdocs.pm/ecto/Ecto.Query.html)  
[Elixir - case, cond and if](http://elixir-lang.org/getting-started/case-cond-and-if.html)  
[Adding user authentication to a Phoenix app](http://nithinbekal.com/posts/phoenix-authentication/)  
[Qiita - クッキーとセッションの違い](http://qiita.com/kiyodori/items/d48f3a92b0b21355155a)  
[Phoenix - Guide Sessions](http://www.phoenixframework.org/docs/sessions)  
[Qiita - Phoenix Framework docs/sessions読んだ。](http://qiita.com/shiwork/items/7d92000ac84d8b2bd278)  
[Github - janjiss/elixir-stream-phoenix](https://github.com/janjiss/elixir-stream-phoenix)  
[hexdocs - Plug.Conn](http://hexdocs.pm/plug/Plug.Conn.html)  
[hexdocs - Plug.Session](http://hexdocs.pm/plug/Plug.Session.html)  
[Phoenix 0.9 to 0.10.0 upgrade instructions](https://gist.github.com/chrismccord/cf51346c6636b5052885)  