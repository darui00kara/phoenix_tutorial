# Goal
ユーザのサインアップ機能を実装する。  

# Wait a minute
ようやっと、Webサイトの作成らしい内容がやってきました。  
ユーザのサインアップ(ユーザ登録)機能を実装していきます。  

# Index
Sign up  
|> Preparation  
|> Show user  
|> Gravatar image  
|> Sidebar  
|> User sign-up  
|> Extra  
|> Before the end  

## Preparation
作業前にブランチを切ります。  

#### Example:

```cmd
>cd path/to/sample_app
>git checkout -b sign_up
```

## Show user
サインアップを実装する前に、ユーザを表示するプロフィールページを実装します。  
ユーザを見ることができるページがないと、サインアップしたユーザの確認ができませんから。  

ユーザのルーティングを追加します。  
追加するルーティングは、RESTfulなルーティングを追加してくれるresources記述を使います。  
デモアプリ以来の登場ですね。  

#### File: web/router.ex

```elixir
scope "/", SampleApp do
  ...
  resources "/user", UserController, except: [:new]
end
```

デモアプリを作成した時と違い、何やらオプションが付いています。  
オプションの説明をする前に、追加されたルーティングを確認してみましょう。  

#### Example:

```cmd
>mix phoenix.routes
...
user_path  GET     /user                SampleApp.UserController :index
user_path  GET     /user/:id/edit       SampleApp.UserController :edit
user_path  GET     /user/:id            SampleApp.UserController :show
user_path  POST    /user                SampleApp.UserController :create
user_path  PATCH   /user/:id            SampleApp.UserController :update
           PUT     /user/:id            SampleApp.UserController :update
user_path  DELETE  /user/:id            SampleApp.UserController :delete
```

追加されたルーティングに何かが足りないと思いませんか？  
そう！newアクションが追加されていません！！  

これはバグですか？いいえ違います！  
これが先ほどのオプションの効果です。  

今回、記述しているexceptオプションは、特定のルーティングを追加しないオプションです。  
今回の場合で言えば、newアクションは除外すると言うことになります。  

newアクションだけ除外している理由ですが、  
前回のModeling usersで以下のルーティングを追加しているからです。  

##### Example:

```cmd
get "/signup", UserController, :new

>mix phoenix.routes
user_path  GET     /signup              SampleApp.UserController :new
```

逆に言えば、特定のアクションのみ追加するオプションもあります。  
チュートリアルを進めるうちに出てきますが、今は除外するオプションを覚えて下さい。  

#### Note:

```txt
Phoniex-Frameworkのresourcesで追加されるアクションは、  
new、index、edit、show、crate、update、deleteになります。  

この中のアクションであれば、オプションで指定できます。  
```

Userコントローラへshowアクションの関数を追加します。  
以下のアクション関数を追加して下さい。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def show(conn, %{"id" => id}) do
    user = Repo.get(SampleApp.User, id)
    render(conn, "show.html", user: user)
  end
end
```

ユーザのIDからDBを検索し、取得しています。  
その後、取得したデータをテンプレートへ渡しています。  

showテンプレート作成します。  
ユーザ名とEmailを表示するだけの簡素なテンプレートです。  

#### File: web/templates/user/show.html.eex

```html
<div class="jumbotron">
  <strong>Name:</strong><%= @user.name %>
  <strong>Email:</strong><%= @user.email %>
</div>
```

ページができているのか確認したいですが、  
今のままだと、ユーザが一人もいません。  

仮データとしてユーザをiex上から作成します。  

ここで行う処理はサインアップを手動で行っているのと同一です。  
実際にサインアップ機能を実装する時は、下記の処理を行います。  

#### Example:

```cmd
>iex -S mix
...
iex> alias SampleApp.User
nil
```

仮のデータを作成します。  

```cmd
iex> params = %{name: "hoge", email: "hoge@test.com", password: "hogehoge"}
%{email: "hoge@test.com", name: "hoge", password: "hogehoge"}
```

changesetを実行します。  

```cmd
iex> changeset = User.changeset(%User{}, params)
...
```

検証の結果に問題がないか確認します。  

```cmd
iex> changeset.valid?
true
```

DBへデータを挿入します。  

```cmd
iex> SampleApp.Repo.insert(changeset)
...
```

showページへアクセスしてユーザの情報が表示されているか確認してみましょう。  

## Gravatar image
このままでは、showページが少し寂しいですね。  

少し横道に外れますが、プロフィール画像を出してshowページに飾りを追加しましょう！  

ユーザのプロフィール画像としては、Gravatar(サービス)を利用します。  
Gravatarを扱うためのモジュールを作成します。  

#### Gravatarの画像を表示したい場合、予めGravatarへの登録が必要になります。
#### Gravatar: [http://gravatar.com/](http://gravatar.com/)

登録をしなくても、デフォルトの画像が表示されますので必須ではありません。  

Gravatarは、md5で暗号化されたEmailをIDとして取得します。  
また、md5では大文字小文字が区別されるので、暗号化される前にEmailの小文字化(downcase)が必要です。  

まずは、上記の機能を実装しましょう。  

Gravatarモジュールを作成し、モジュールへ4つの関数を追加します  

- Gravatarから画像を取得するget_gravatar_url/2関数
- EmailをIDに変換するemail_to_gravator_id/1関数
- md5に暗号化するemail_crypt_md5/1関数
- Emailを小文字化するemail_downcase/1関数。

#### File: lib/gravatar.ex

```elixir
defmodule SampleApp.Gravatar do
  def get_gravatar_url(email, size) do
    gravatar_id = email_to_gravator_id(email)
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end

  defp email_to_gravator_id(email) do
    email |> email_downcase |> email_crypt_md5
  end
  
  defp email_crypt_md5(email) do
    :erlang.md5(email)
    |> :erlang.bitstring_to_list
    |> Enum.map(&(:io_lib.format("~2.16.0b", [&1])))
    |> List.flatten
    |> :erlang.list_to_bitstring
  end

  defp email_downcase(email) do
    String.downcase(email)
  end
end
```

実際に使う際には、ビューから使います。  
今のところ利用するのはユーザだけですので、Userビューへ関数を作成します。  

Gravatarを取得するget_gravatar_url/1関数を追加します。  

#### File: web/views/user_view.ex

```elixir
defmodule SampleApp.UserView do
  ...

  alias SampleApp.User
  alias SampleApp.Gravatar

  def get_gravatar_url(%User{email: email}) do
    Gravatar.get_gravatar_url(email, 50)
  end
end
```

showテンプレートでGravatarを表示するように変更します。  

#### File: web/templates/user/show.html.eex

```html
<h1>
  <img src="<%= get_gravatar_url(@user) %>" class="gravatar">
  <%= @user.name %>
</h1>
```

Gravatarを表示するための、CSSを追加します。  

#### File: priv/static/css/custom.css

```css
/* gravatar */
.gravatar {
  float: left;
  margin-right: 10px;
}
```

実行してGravatar画像を確認してみましょう。  

## Sidebar
サイドバーを実装して、ユーザのプロフィールを左寄せに表示させます。  

showテンプレートを以下のように変更します。  

#### File: web/templates/user/show.html.eex

```html
<div class="row">
  <aside class="col-md-4">
    <section>
      <h1>
        <img src="<%= get_gravatar_url(@user) %>" class="gravatar">
        <%= @user.name %>
      </h1>
    </section>
  </aside>
</div>
```

サイドバー用のCSSを追加します。  

#### File: priv/static/css/custom.css

```css
/* sidebar */
aside section {
  padding: 10px 0;
  border-top: 1px solid #eeeeee;
}

aside section:first-child {
  border: 0;
  padding-top: 0;
}

aside section span {
  display: block;
  margin-bottom: 3px;
  line-height: 1;
}

aside section h1 {
  font-size: 1.4em;
  text-align: left;
  letter-spacing: -1px;
  margin-bottom: 3px;
  margin-top: 0px;
}
```

## User sign-up
とうとうやってきました。  
サインアップ機能の実装をします。  

最初にユーザが入力する部分について考えましょう。  
DBへ作成しているusersテーブルには現在、以下のカラムがありますね。  

- name
- email
- password
- password_digest

この内、password_digestはpasswordが暗号化された内容が入るだけですから、  
入力項目は、name、email、passwordの3つとなります。  

サインアップするためのフォームを作成します。  
新しくテンプレートを作成し、以下のように編集して下さい。  

#### File: web/templates/user/new.html.eex

```html
<%= form_for @changeset, user_path(@conn, :create), fn f -> %>
  <div class="form-group">
    <%= label f, :name, "Name", class: "control-label" %>
    <%= text_input f, :name, class: "form-control" %>
  </div>

  <div class="form-group">
    <%= label f, :email, "Email", class: "control-label" %>
    <%= email_input f, :email, class: "form-control" %>
  </div>

  <div class="form-group">
    <%= label f, :password, "Password", class: "control-label" %>
    <%= password_input f, :password, class: "form-control" %>
  </div>

  <div class="form-group">
    <%= submit "Sign-up!", class: "btn btn-primary" %>
  </div>
<% end %>
```

Userコントローラのnewアクションを修正します。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  def new(conn, _params) do
    render(conn, "new.html", changeset: SampleApp.User.new)
  end

  ...
end
```

検証有のchageset/2を使うと必須項目を入力しないとエラーメッセージが入ってしまいます。  
なので、空のCangesetを取得する関数を追加します。  

#### File: web/models/user.ex

```elixir
defmodule SampleApp.User do
  ...

  def new do
    %SampleApp.User{} |> cast(:empty, @required_fields, @optional_fields)
  end
end
```

入力画面は作成できました。  
入力した値を処理するためのアクションはまだ実装していません。  

サインアップ処理を実行する、createアクションを作成します。  

最初の実装は以下のようになります。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def create(conn, %{"user" => user_params}) do
    changeset = SampleApp.User.changeset(%SampleApp.User{}, user_params)
    Repo.insert(changeset)

    conn
    |> put_flash(:info, "User registration is success!!")
    |> redirect(to: static_pages_path(conn, :home))
  end
end
```

単純に入力された値をDBへ挿入しています。  
しかし、上記の実装には問題があります。何が足りないのでしょうか？  

そう、検証の結果に問題がないか確認をしていませんね。  
このままでは不正な値があっても止まることなく、DBへデータが挿入されてしまいます。  

検証に問題がある時の処理を追加しましょう。  
検証の結果によって、処理を分岐するようにします。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def create(conn, %{"user" => user_params}) do
    changeset = SampleApp.User.changeset(%SampleApp.User{}, user_params)

    if changeset.valid? do
      Repo.insert(changeset)

      conn
      |> put_flash(:info, "User registration is success!!")
      |> redirect(to: static_pages_path(conn, :home))
    else
      render(conn, "new.html", changeset: changeset)
    end
  end
end
```

さて、プログラム側では検証の結果により分岐はできました。  
ですが、今のままだとサインアップに失敗した時、  
再びサインアップ画面が出てくるだけで何が悪いのか分かりません。  

どの値(検証)に問題があったのか、newテンプレートでエラーメッセージの表示を行うようにします。  

#### File: web/templates/user/new.html.eex

```html
<h1>Sign up</h1>
<%= form_for @changeset, user_path(@conn, :create), fn f -> %>
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
  
  ...
<% end %>
```

DBへの挿入処理で問題が起こった場合はどうなるでしょうか？  
おそらく、実行時エラーとして落ちますね。  
エラーページの設定がされていれば、500番台のエラーが表示されるでしょう。  

挿入処理の結果を取得して処理の流れを分岐させます。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def create(conn, %{"user" => user_params}) do
    changeset = SampleApp.User.changeset(%SampleApp.User{}, user_params)

    if changeset.valid? do
      case Repo.insert(changeset) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "User registration successfully!!")
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

Ecto.Repo.insert/2の戻り値ですが、  
成功時は、メッセージとして:okと挿入したモデルのデータが返ってきます。  
また失敗時は、メッセージとして:errorとChangesetの値が返ってきます。  

これで完璧です！  

#### Note:

```txt
form_for/4について...  
これは、Phoenix.HTMLライブラリにある機能です。  

この関数は、formタグの生成を行ってくれるフォームビルダです。  
また、CSRFへの対応も行ってくれます。  

この関数で重要だと思われるのは、フォームデータのマッピングだと思います。  

第一引数に"@changeset"を渡していますね。  
この内容はUserモデルの空のChangesetです。  

UserのChangesetをマッピングして、入力されたデータをパラメータとして渡しています。  
そのため、createアクションでparams引数をUser.changeset/2関数へ渡すことができます。  

フォーム部分を自分でガリガリ書かなくても、上手く抽象化されていますね。  
素晴らしい！！  
```

## Extra
せっかくなので、デバッグ表示を追加してみようと思います。  

インポートする関数を追加しています。(action_name/1、controller_module/1)  

#### File: web/web.ex

```elixir
def view do
  quote do
    ...

    # Import convenience functions from controllers
    import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1,
                                      action_name: 1, controller_module: 1]

    ...
  end
end
```

レイアウトテンプレートへデバッグを表示するテンプレートを追加します。  

#### File: web/templates/layout/app.html.eex

```html
<!DOCTYPE html>
<html lang="en">
  ...

  <body>
    ...

    <div class="container">
      <%= render "debug.html", conn: @conn %>
    </div>

    <script src="<%= static_path(@conn, "/js/app.js") %>"></script>
    <script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
    <script src="<%= static_path(@conn, "/js/bootstrap.js") %>"></script>
  </body>
</html>
```

Layoutビューへ、実行したアクション名とコントローラ名を取得する関数を追加しています。  

#### File: web/views/layout_view.ex

```txt
defmodule SampleApp.LayoutView do
  use SampleApp.Web, :view

  def get_controller_name(conn), do: controller_module(conn)
  def get_action_name(conn), do: action_name(conn)
end
```

デバッグ内容を出力する新しいテンプレートを作成します。  

#### File: web/templates/layout/debug.html.eex

```html
<div class="debug_dump">
  <p>Controller: <%= get_controller_name @conn %></p>
  <p>Action: <%= get_action_name @conn %></p>
</div>
```

デバッグを出力するためのCSSを作成します。  

#### File: priv/static/css/custom.css

```css
/* miscellaneous */
.debug_dump {
  clear: both;
  float: left;
  width: 100%;
  margin-top: 45px;
  color: inherit;
  background-color: #eee;
  -moz-box-sizing: border-box;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
}

.debug_dump p {
  margin-bottom: 1px;
  font-size: 15px;
  font-weight: 200;
}
```

## Before the end
ソースコードをマージします。  

```cmd
>git add .
>git commit -am "Finish sign_up."
>git checkout master
>git merge sign_up
```

# Speaking to oneself
ユーザのサインアップが行えるようになりました。  

次の章では、サインインとサインアウトを扱います。  
認証と言われる処理を行います。  

このTutorialでは、昨今よく使われるOAuthは行いません。  
認証と言われる処理自体を学ぶため、シンプルな認証を行います。  

# Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/sign-up?version=4.0#top)  
[Gravatar - Image Requests](https://ja.gravatar.com/site/implement/images/)  
[Gist - 10nin / Crypto.ex](https://gist.github.com/10nin/5713366)  
[hexdocs - Phoenix.HTML (v2.2.0) - Phoenix.HTML.Form.form_for/4](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html#form_for/4)