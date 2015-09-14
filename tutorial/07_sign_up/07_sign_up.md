#Goal
ユーザのサインアップ機能を実装する。  

#Wait a minute
ようやっとWebサイト作成らしい内容がやってきました。  
ユーザのサインアップ機能(ユーザ登録)を実装していきます。  

#Index
Sign up  
|> Preparation  
|> Show user  
|> Gravatar image  
|> Sidebar  
|> User sign-up  
|> Extra  

##Preparation
作業前にブランチを切ります。  

```cmd
>cd path/to/sample_app
>git checkout -b sign_up
```

##Show user
最初にユーザを表示する部分を作成します。  
ユーザが表示できないと、サインアップしたユーザの確認ができませんね。  

###Add routing
ルーティングを追加します。  

####ファイル: web/router.ex
resources記述を使い、RESTfulなルーティングを追加します。  

```elixir
scope "/", SampleApp do
  ...
  resources "/user", UserController, except: [:new]
end
```

ルーティングを確認してみましょう。  

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

さて、前に追加したことがあるresources記述と少し違いますね。  
"except: [:new]"と言うオプションが付いています。  

これは、特定のルーティングを追加しないオプションになります。  
今回の場合で言えば、newアクションは除外すると言うことになりますね。  

newアクションだけ除外している理由は、  
前回のmodeling_usersで以下のルーティングを追加しているからです。  

```cmd
get "/signup", UserController, :new

>mix phoenix.routes
user_path  GET     /signup              SampleApp.UserController :new
```

逆に言えば、特定のアクションのみ追加するオプションもあります。  
その内出てきますので、今は除外するオプションを覚えて下さい。  

####Note:
Phoniex-Frameworkのresourcesで追加されるアクションは、  
new、index、edit、show、crate、update、deleteになります。  

この中のアクションであれば、オプションで指定できます。  

###Add show action
Userコントローラへshowアクションの関数を追加します。  

####ファイル: web/controllers/user_controller.ex
以下のアクション関数を追加して下さい。  

```elixir
def show(conn, %{"id" => id}) do
  user = Repo.get(SampleApp.User, id)
  render(conn, "show.html", user: user)
end
```

ユーザidからユーザを取得してテンプレートへ渡しているだけですね。  

###Create show template
showテンプレート作成します。  

####ファイル: web/templates/user/show.html.eex
ユーザ名とEmailを表示するだけの簡素なテンプレートを作成します。  

```html
<div class="jumbotron">
  <strong>Name:</strong><%= @user.name %>
  <strong>Email:</strong><%= @user.email %>
</div>
```

###Add user from iex
ページができているのか確認したいですが、  
今のままだと、ユーザが一人もいません。  

仮データとしてユーザをiex上から作成します。  
(ここで行っている方法がそのままサインアップ機能の実装になります。)  

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

作成した画面でユーザの情報が表示されているか確認してみましょう。  

##Gravatar image
このままでは、画面が少し寂しいですね。  
画像を出しましょう！  

ユーザのプロフィール画像としてGravatarを利用します。  
Gravatarを扱うためのモジュールを作成します。  

Gravatar: [http://gravatar.com/](http://gravatar.com/)

###Create gravatar module
Gravatarは、md5で暗号化されたemailをidとして取得します。  
また、md5では大文字小文字が区別されるので、暗号化される前にemailの小文字化(downcase)が必要です。  

まずは、上記の機能を実装しましょう。  

####ファイル: lib/gravatar.ex
Gravatarモジュールを作成し、  
md5に暗号化するemail_crypt_md5/1関数と  
emailを小文字化するemail_downcase/1関数を作成します。  

```elixir
defmodule SampleApp.Gravatar do
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

####ファイル: lib/gravatar.ex
emailをidに変換するemail_to_gravator_id/1関数と  
Gravatarから画像を取得するget_gravatar_url/2関数を作成します。  

```elixir
defmodule SampleApp.Gravatar do

  def get_gravatar_url(email, size) do
    gravatar_id = email_to_gravator_id(email)
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end

  defp email_to_gravator_id(email) do
    email |> email_downcase |> email_crypt_md5
  end

  ...
end
```

実際に使う際には、Viewモジュールから使います。  
今のところ利用するのはUserだけですので、UserViewへ関数を作成します。  

####ファイル: web/views/user_view.ex
gravatarを取得するget_gravatar_url/1関数を追加します。

```elixir
defmodule SampleApp.UserView do
  use SampleApp.Web, :view

  def get_gravatar_url(%SampleApp.User{email: email}) do
    SampleApp.Gravatar.get_gravatar_url(email, 50)
  end
end
```

showテンプレートを変更します。  

####ファイル: web/templates/user/show.html.eex
gravatarを使うように変更しています。

```html
<h1>
  <img src="<%= get_gravatar_url(@user) %>" class="gravatar">
  <%= @user.name %>
</h1>
```

Gravatarを表示するための、CSSを追加します。  

####ファイル: priv/static/css/custom.css
gravatar用のCSSを追加します。

```css
.gravatar {
  float: left;
  margin-right: 10px;
}
```

実行してGravatar画像を確認してみましょう。  

##Sidebar
Gravatar画像とユーザ名が画面の真ん中に出ていますね。  
しかし、左右どちらかに寄せて表示をしたいです。  

サイドバーを実装して、左寄せに表示させます。  

####ファイル: web/templates/user/show.html.eex
showテンプレートを以下のように変更します。  

```html
<div class="row">
  <aside class="span4">
    <section>
      <h1>
        <img src="<%= get_gravatar_url(@user) %>" class="gravatar">
        <%= @user.name %>
      </h1>
    </section>
  </aside>
</div>
```

####ファイル: priv/static/css/custom.css
サイドバー用のCSSを追加します。  

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

##User sign-up
とうとうやってきました。サインアップ機能の実装をします。  

DBへ作成しているusersテーブルには現在、以下のカラムがありますね。  

- name
- email
- password
- password_digest

この内、password_digestはpasswordが暗号化された内容が入るだけですから、  
入力項目は上記の上3つ(name、email、password)となります。  

###User registration form
サインアップするためのフォームを作成します。  

####ファイル: web/templates/user/new.html.eex
新しくテンプレートを作成し、以下のように編集して下さい。  

```html
<%= form_for @changeset, user_path(@conn, :create), fn f -> %>
  <div class="form-group">
    <label>Name</label>
    <%= text_input f, :name, class: "form-control" %>
  </div>

  <div class="form-group">
    <label>Email</label>
    <%= text_input f, :email, class: "form-control" %>
  </div>

  <div class="form-group">
    <label>Password</label>
    <%= text_input f, :password, class: "form-control" %>
  </div>

  <div class="form-group">
    <%= submit "Submit", class: "btn btn-primary" %>
  </div>
<% end %>
```

####ファイル: web/controllers/user_controller.ex
Userコントローラのnewアクションを修正します。  

```elixir
defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  def new(conn, _params) do
    render(conn, "new.html", changeset: SampleApp.User.new)
  end

  ...
end
```

####ファイル: web/models/user.ex
空のUserのChangesetを取得する関数を追加します。  

```elixir
defmodule SampleApp.User do
  ...

  def new do
    %SampleApp.User{} |> cast(:empty, @required_fields, @optional_fields)
  end

  ...
end
```

###Registration action
入力画面は作成できました。  
入力した値を処理するためのアクションはまだ実装していません。  

サインアップ処理を実行する、createアクションを作成します。  

####ファイル: web/controllers/user_controller.ex
最初の実装は以下のようになります。  

```elixir
def create(conn, %{"user" => user_params}) do
  changeset = SampleApp.User.changeset(%SampleApp.User{}, user_params)
  Repo.insert(changeset)

  conn
  |> put_flash(:info, "User registration is success!!")
  |> redirect(to: static_pages_path(conn, :home))
end
```

さて、上記のプログラム問題があります。何が足りないのでしょうか？  

そう、検証の結果に問題がないか確認をしていませんね。  
実際このままでは、不正な値があっても止まることなくDBへデータが挿入されてしまいます。  

###Error handling
検証に問題がある時の処理を追加しましょう。  

####ファイル: web/controllers/user_controller.ex
検証の結果によって、処理を分岐するようにしました。  

```elixir
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
```

さて、最後にもう一つだけ仕事をしましょう。  
現在のままだとサインアップに失敗した時、再びサインアップ画面が出てくるだけで何が悪いのか分かりません。  

どの値に問題があったのか、エラーメッセージを表示します。  

####ファイル: web/templates/user/new.html.eex

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
  
  <div class="form-group">
    <label>Name</label>
    <%= text_input f, :name, class: "form-control" %>
  </div>

  <div class="form-group">
    <label>Email</label>
    <%= text_input f, :email, class: "form-control" %>
  </div>

  <div class="form-group">
    <label>Password</label>
    <%= text_input f, :password, class: "form-control" %>
  </div>

  <div class="form-group">
    <%= submit "Submit", class: "btn btn-primary" %>
  </div>
<% end %>
```

これで完璧です！  

####Note:
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

##Extra
デバッグ表示を追加してみようと思います。  

####ファイル: web/web.ex
インポートする関数を追加しています。(action_name/1、controller_module/1)  

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

####ファイル: web/templates/layout/app.html.eex
レイアウトテンプレートへデバッグを表示するテンプレートを追加します。  

```html
<!DOCTYPE html>
<html lang="en">
  ...

  <body>
    ...

    <div class="container">
      <%= render "debug.html", conn: @conn %>
    </div>

    ...
  </body>
</html>
```

####ファイル: web/views/layout_view.ex
実行したアクション名とコントローラ名を取得する関数を追加しています。  

```txt
defmodule SampleApp.LayoutView do
  use SampleApp.Web, :view

  def get_controller_name(conn), do: controller_module(conn)
  def get_action_name(conn), do: action_name(conn)
end
```

####ファイル: web/templates/layout/debug.html.eex
デバッグ内容を出力する新しいテンプレートを作成します。  

```html
<div class="debug_dump">
  <p>Controller: <%= get_controller_name @conn %></p>
  <p>Action: <%= get_action_name @conn %></p>
</div>
```

####ファイル: priv/static/css/custom.css
デバッグを出力するためのCSSを作成します。  

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

#Speaking to oneself
ユーザのサインアップが行えるようになりました。  

しかし、セキュアな登録と言うわけではありません。  
セキュリティ的には、非常に甘いと言える状態でしょう。  

このTutorialでは、そこまでやりませんが、  
正式なWebサイトを運営もしくは作成するのであれば、  
必要になりますので、必要なのだと言う意識だけ持っていて下さい。  

次の章では、サインインとサインアウトを扱います。  
認証と言われる処理を行います。  

このTutorialでは、昨今よく使われる認証は行いません。  
認証と言われる処理自体を学ぶため、シンプルな認証を行います。  

#Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/sign-up?version=4.0#top)  
[Gravatar - Image Requests](https://ja.gravatar.com/site/implement/images/)  
[Gist - 10nin / Crypto.ex](https://gist.github.com/10nin/5713366)  
[hexdocs - Phoenix.HTML (v2.2.0) - Phoenix.HTML.Form.form_for/4](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html#form_for/4)