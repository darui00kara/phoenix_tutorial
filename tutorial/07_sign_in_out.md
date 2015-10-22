# Goal
サインイン、サインアウト機能を実装する。  

# Wait a minute
セッションを使いサインイン、サインアウト機能を実装していきます。  
また、シンプルな認証(Authentication)についても実装してみましょう。  

# Index
Sign-in and Sign-out  
|> [Preparation](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#preparation)  
|> [Create SessionController](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#create-sessioncontroller)  
|> [Authentication](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#authentication)  
|> [Sign-in](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#sign-in)  
|> [Sign-in Form](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#sign-in-form)  
|> [Sign-in link](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#sign-in-link)  
|> [How do session?](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#how-do-session-)  
|> [Use session](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#use-session)  
|> [Continuation of Sign-in state](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#continuation-of-sign-in-state)  
|> [Current user](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#current-user)  
|> [Change links and layout](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#change-links-and-layout)  
|> [Sign-out](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#sign-out)  
|> [After registration, sign-in](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#after-registration-sign-in)  
|> [Before the end](http://daruiapprentice.blogspot.jp/2015/07/sign-in-sign-out.html#before-the-end)  

## Preparation
作業前にブランチを切ります。  

```cmd
>cd path/to/sample_app
>git checkout -b sign_in_out
```

## Create SessionController
サインインしている状態、していない状態を保存しておくために、  
セッションを扱うためのコントローラを作成します。  

セッションの使い方の説明は、後に行います。  
まずはルーティングを追加していきます。  

セッション用のルーティングを追加します。  

#### File: web/router.ex

```elixir
scope "/", SampleApp do
  ...
  get "/signin", SessionController, :new
  post "/session", SessionController, :create
  delete "/signout", SessionController, :delete
end
```

追加したルーティングは、それぞれ以下のようになっています。  

- new (/signin): サインインするための情報を入力するフォーム画面
- create (/session): サインインの認証を行い、セッションに情報を格納するアクション
- delete (/signout): サインアウトを行うアクション

追加されたルーティングを確認しましょう。  

#### Example:

```cmd
>mix phoenix.routes
...
session_path  GET     /signin         SampleApp.SessionController.new/2
session_path  POST    /session        SampleApp.SessionController.create/2
session_path  DELETE  /signout        SampleApp.SessionController.delete/2
```

コントローラを作成します。  
Sessionコントローラを以下の通り、作成します。  

#### File: web/controllers/session_controller.ex

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

#### File: web/views/session_view.ex

```elixir
defmodule SampleApp.SessionView do
  use SampleApp.Web, :view
end
```

Sessionのテンプレートを格納するディレクトリを作成します。  
sessionと言うディレクトリを作成して下さい。  

#### Directory: web/templates/session

サインインに必要な情報を入力するテンプレートを作成します。  
入力フォームの部分はまだ作成しません。  

#### File: web/templates/session/signin_form.html.eex

```html
<div class="jumbotron">
  <h2>Sign in!!</h2>
</div>
```

Sessionコントローラにセッションやサインイン / サインアウトの処理を追加していきます。  

## Authentication
サインインとは切っても切り離せない認証を作成していきます。  

ここで作成する認証処理は、ライブラリなどを利用しません。  

実際はライブラリなどを使って、安全性の高い認証を行うべきでしょうが、  
ここでは、DBのパスワードの値と入力されたパスワードが一致するか否かを  
判定するだけの非常にシンプルな処理を作成します。  

それでは、作成していきましょう。  

まず作成しなければいけないのは、EmailでDBからデータ取得する部分です。  

UserモデルへEmailからユーザ情報の取得を行う関数を作成します。  

#### File: web/models/user.ex

```elixir
defmodule SampleApp.User do
  ...

  def find_user_from_email(email) do
    SampleApp.Repo.get_by(SampleApp.User, email: email)
  end
end
```

認証を扱うモジュールを作成します。  

#### File: lib/authentication.ex

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

#### File: lib/sign_in.ex

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

Sessionコントローラのcreateアクションを以下のようにサインイン処理を行うように変更しましょう。  

#### File: web/controllers/session_controller.ex

```elixir
defmodule SampleApp.SessionController do
  ...

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

  ...
end
```

## Sign-in Form
サインインを行うための入力フォームを作成します。  

サインインのフォームは以下のようになります。  

#### File: web/templates/session/signin_form.html.eex

```html
<h1>Sign in!!</h1>

<%= form_for @conn, session_path(@conn, :create), [as: :signin_params], fn f -> %>
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
是非、覚えておいて下さい。  

## Sign-in link
レイアウトヘッダにあるサインインのリンクを修正します。  

#### File: web/templates/layout/header.html.eex

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

各クッキーに署名するために、secret_key_baseの値を利用しています。  

#### File: config/config.exs

```elixir
config :sample_app, SampleApp.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "****",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: SampleApp.PubSub,
           adapter: Phoenix.PubSub.PG2]
```

Endpointでデフォルトのセッションを設定しています。  

#### File: lib/sample_app/endpoint.ex

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

セッションへ値を出し入れする関数。

- put_session/2: セッションへ値を格納する。
- get_session/2: セッションの値を取り出す。

## Use session
Sessionコントローラへセッションの処理を追加します。  

先ほど作成した、サインインモジュールのインポートを追加します。  
また、セッションに値を格納するための処理を追加します。  

#### File: web/controllers/session_controller.ex

```elixir
defmodule SampleApp.SessionController do
  use SampleApp.Web, :controller

  import SampleApp.Signin

  ...

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

  ...
end
```

追加はput_session/2の一行だけですが、これでセッションに値を格納できます。  
ユーザを識別するためのIDを格納しています。  

user_idと言うキー名で、ユーザIDを格納しています。

## Continuation of Sign-in state
今のままではサインイン後、別のページに移動するとサインインした状態が継続されません。  
サインインを継続させるために状態維持の機能を実装します。  

どうやって実現するかですが、自作のプラグを作成して各コントローラで実行するようにします。  
プラグを指定しておけば、そのコントローラでアクションが動作する前に動作してくれます。  
また、特定のアクションにのみプラグが動作するような設定もできます。  

まずは、プラグのファイルを格納するためのディレクトリを作成しましょう。  
plugsと言う名前でディレクトリを作成して下さい。  

#### Directory: lib/plugs

認証されているかを確認するためのプラグ(モジュール)を作成します。  

#### File: lib/plugs/check_authentication.ex

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
このユーザIDがセッションに存在するか否かでサインインの状態を判断しています。  

また後にやりますが、現在のサインインしているユーザを取得する際にも利用します。  

このプラグは全コントローラで利用を考えているプラグになります。  
なので、web.exのcontroller/0関数へプラグを追加します。  

#### File: web/web.ex

```elixir
def controller do
  quote do
    ...

    plug SampleApp.Plugs.CheckAuthentication
  end
end
```

これで全てのコントローラで作成したプラグが動作します。  

#### Note:

```txt
セッションに格納しているデータですが、
ここではユーザIDを生のまま格納しています。

分かりやすくするために生のまま格納していますが、
本来であれば暗号化された別の値を格納すべきです。

ユーザID(ただの番号)を格納していることが分かってしまえば、
Cookieの値を改ざんして、別のユーザでログインしているように成りすますことができてしまいます。

公開するWebサイトを運営するのであれば、
セッションに格納する値は別の暗号化されて値を格納するようにしましょう。
(公開して後悔しないために...)
```

## Current user
サインインしている現在のユーザを取得してデバッグ表示に追加しましょう。  

ビューをサポートするためのヘルパーモジュールを作成します。  

先ほど、Connのassignに値を格納していたと思う。  
その値をここで取り出して利用する。  

#### File: lib/helpers/view_helper.ex

```elixir
defmodule SampleApp.Helpers.ViewHelper do
  def current_user(conn) do
    conn.assigns[:current_user]
  end
end
```

上記のヘルパーモジュールを全てのビューで利用できるように、  
web.exのview/0関数へimportを追加します。  

#### File: web/web.ex

```elixir
def view do
  quote do
    ...

    import SampleApp.Helpers.ViewHelper
  end
end
```

デバッグ用のテンプレートへユーザ名とIDの表示を追加する。  

#### File: web/templates/layout/debug.html.eex

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

#### File: web/templates/layout/header.html.eex

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
              <li><%= button "Profile", to: user_path(@conn, :show, current_user(@conn)), method: :get, class: "header-button" %><li>
              <li><%= button "Help", to: static_pages_path(@conn, :help), method: :get, class: "header-button" %></li>
              <li class="divider"></li>
              <li><%= button "Sign-out", to: session_path(@conn, :delete), method: :delete, class: "header-button" %></li>
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

#### File: priv/static/css/custom.css

```css
/* header-button */
.header-button {
  display: inline-block;
  margin-left: 20px;
  border: solid 2px #fff;
  /*border-radius: 3px;*/
  background: rgba(255,255,255,0.2);
  color: #1e90ff;
  text-decoration: none;
  font-weight: bold;
  font-family: Helvetica, Arial, sans-serif;
}
.header-button:hover{
  color: #;
  background: #f0ffff;
}
```

#### Cution:

このヘッダーテンプレートですが、後日修正を行う可能性があります。  

v1.0.3にて、linkタグでdeleteメソッドを指定すると動作をしない現象を確認。  
v1.0.0では動作を確認しているので、比較や検証を行ったが原因は不明。  

そのため、急きょbuttonタグを利用してCSSで調整して表示している。  
お手数をお掛けしますが、ご理解お願い致します。  

## Sign-out
ようやっとサインイン機能と対になる、サインアウト機能を実装します。  
サインインほど、難しい処理はしません。  

Sessionコントローラのdeleteアクションを以下のように変更します。  

#### File: web/controllers/session_controller.ex

```elixir
defmodule SampleApp.SessionController do
  ...

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Sign-out now! See you again!!")
    |> delete_session(:user_id)
    |> redirect(to: static_pages_path(conn, :home))
  end
end
```

サインアウトの旨を知らせるメッセージの表示。  
それと、セッションの削除を行っています。  

サインアウトを行うまで、サインインの状態は維持されます。  

## After registration, sign-in
サインアップ後、サインイン処理を行うようにサインアップ時の処理を修正します。  

Userコントローラのcreateアクションを以下のように修正して下さい。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def create(conn, %{"user" => user_params}) do
    changeset = SampleApp.User.changeset(%SampleApp.User{}, user_params)

    if changeset.valid? do
      case Repo.insert(changeset) do
        {:ok, result_user} ->
          conn
          |> put_flash(:info, "User registration successfully!!")
          |> put_session(:user_id, result_user.id)
          |> redirect(to: static_pages_path(conn, :home))
        {:error, result} ->
          render(conn, "new.html", changeset: result)
      end
    else
      render(conn, "new.html", changeset: changeset)
    end
  end
end
```

Repo.insert/2の戻り値は、{:ok, model}か{:error, changeset}です。  
なので、データの挿入が成功時はサインインの処理を行い、失敗時は再度入力を促すようにしています。  

サインアップでユーザ登録を行えば、  
成功後にセッションへ値を格納し、サインイン状態になります。  

## Before the end
ソースコードをマージします。  

#### Example:

```cmd
>git add .
>git commit -am "Finish sign_in_out."
>git checkout master
>git merge sign_in_out
```

# Speaking to oneself
お疲れ様でした。これで第八章は終わりです。  
サインイン、サインアウトの実装はどうでしたか？  
色々なことをやったので少し苦労したかもしれません。  

次の章は、このチュートリアルにおける最初の山場です。  
ページネーションや認可、残りのユーザの処理を実装します。  

大変でしょうけど、Webサイトには必須の内容なので一緒に頑張りましょう！！  

# Bibliography
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