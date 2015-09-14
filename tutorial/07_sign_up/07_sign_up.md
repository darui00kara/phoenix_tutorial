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
ユーザが表示できないと、登録したユーザの確認ができませんね。

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
ユーザ名とEmailを表示するだけの簡素なテンプレートを作成します。

####ファイル: web/templates/user/show.html.eex

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

###Create gravatar module

ファイル: lib/gravatar.ex

##User sign-up

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

```elixir
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

#Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/sign-up?version=4.0#top)  