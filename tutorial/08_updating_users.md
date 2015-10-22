# Goal
ユーザーの更新、一覧表示、削除を実装する。  

# Wait a minute
本章では、ユーザデータの更新、一覧の表示とページネーション、削除を実装していきます。  

この中で難易度が高いのはページネーションです。  
理解するのに苦労をするかもしれません。  
ですが、Webページで使われる一般的な機能なので今後の役に立つと思います。  

# Index
Updating users  
|> Preparation  
|> Edit action  
|> Create edit form template  
|> Settings link  
|> Update action  
|> Sharing user form template  
|> The difference of authentication and authorization  
|> Signed in user?  
|> Correct user?  
|> All users  
|> All users link  
|> Pagination  
|> Pagination view and template  
|> Is able to paginate?  
|> Delete user  
|> Delete link  
|> Before the end  

## Preparation
作業前にブランチを切ります。  

#### Example:

```cmd
>cd path/to/sample_app
>git checkout -b updating_users
```

ライブラリを利用する準備をします。  
#### Github: [drewolson/scrivener](https://github.com/drewolson/scrivener)  

このライブラリはページネーションの機能を提供してくれるライブラリです。  
Ectoのクエリをページ分割でき、そのためのpaginate関数を提供してくれます。  
そして、結果としてページの総数、現在ページ、現在ページのエントリと有用な情報を提供してくれます。  

大事なのは、Phoenixと上手く動作してくれる点ですね。  
今のところページネーションを扱うライブラリは、これ一択ではないでしょうか？  

同作者による、ビューの機能を提供してくれるライブラリもありますが、  
せっかくなのでビューの部分は自分で作っていきます。  

利用するための準備に移ります。  
依存関係に、scrivenerを追加します。  

#### File: mix.exs

```elixir
defp deps do
  [...
   {:scrivener, "~> 1.0.0"}]
end
```

依存関係の解消します。  

#### Example:

```cmd
>mix deps.get
```

ライブラリを利用するには、Repoにてuseします。  

#### File: lib/pagination_sample/repo.ex

```elixir
defmodule SampleApp.Repo do
  use Ecto.Repo, otp_app: :sample_app
  use Scrivener, page_size: 10
end
```

これで準備は完了です。  

## Edit action
ユーザの更新から実装していきましょう。  
更新を実装するために、まず入力部分を作成しないといけませんね。  

Userコントローラへeditアクションを追加します。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def edit(conn, %{"id" => id}) do
    user = Repo.get(SampleApp.User, id)
    user = Map.put(user, :password, SampleApp.Encryption.decrypt(user.password_digest))
    changeset = SampleApp.User.changeset(user)

    render(conn, "edit.html", user: user, changeset: changeset)
  end
end
```

DBに格納されているパスワードの値(password_digest)は暗号化されています。  
パスワードの可視化はしていませんが、復号化してあげないと意味不明な文字の羅列が表示されてしまいます。  

## Create edit form template
更新データを入力するためのテンプレート作成しましょう。  

編集の入力フォームは以下のようになります。

#### File: web/templates/user/edit.html.eex

```html
<%= form_for @changeset, user_path(@conn, :update, @user), fn f -> %>
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

どこかで見たような内容ですね。  
そう、ユーザのサインアップを実装した時にも同じ内容を作成しました。  

これならば、テンプレートを一つにまとめ共通で利用することができます。  
更新を実装したら、テンプレートの共通化を行います。  

## Settings link
更新ページへのリンクを作成します。  

showテンプレートへ更新のリンクを追加します。  

#### File: web/templates/user/show.html.eex

```html
<div class="row">
  <aside class="span4">
    <section>
      <h1>
        <img src="<%= get_gravatar_url(@user) %>" class="gravatar">
        <%= @user.name %>
      </h1>
    </section>
    <section>
      <%= link "Edit", to: user_path(@conn, :edit, @user), class: "btn btn-default btn-xs" %>
    </section>
  </aside>
</div>
```

## Update action
入力した内容で更新をするための、UpdateアクションをUserコントローラへ追加します。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get(SampleApp.User, id)
    changeset = SampleApp.User.changeset(user, user_params)

    if changeset.valid? do
      case Repo.update(changeset) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "User updated successfully!!")
          |> redirect(to: user_path(conn, :show, user.id))
        {:error, result} ->
          render(conn, "edit.html", user: user.id, changeset: result)
      end
    else
      render(conn, "edit.html", user: user.id, changeset: changeset)
    end
  end
end
```

内容的には、ほぼcreateアクションの動作と変わりません。  

ならば、before_insertコールバックのように更新時も、  
password_digestの値を設定するために同じことをする必要がありますね。  

それと同じことをするために、更新時のコールバックであるbefore_updateを定義します。  
そうしなければ更新すると、パスワードが消えてしまいます。  

#### File: web/models/user.ex

```elixir
defmodule SampleApp.User do
  ...

  before_insert :set_password_digest
  before_update :set_password_digest

  ...
end
```

コールバックは別ですが、  
同じ関数を利用できるのでbefore_insertと同じ関数を指定しています。  

## Sharing user form template
共通で利用できるテンプレート作成しましょう。  

newテンプレートとeditテンプレートの内容がほぼ同一です。  
なので、差異点を引数に取りフォームの部分を共通で使えるようにします。  

#### File: web/templates/user/form.html.eex

```html
<%= form_for @changeset, @action, fn f -> %>
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
    <%= submit "Submit", class: "btn btn-primary" %>
  </div>
<% end %>
```

このテンプレートをnewのテンプレートとeditのテンプレートで呼び出すように修正します。  

#### ファイル: web/templates/user/new.html.eex

```html
<h1>Sign up</h1>

<%= render "form.html", changeset: @changeset,
                        action: user_path(@conn, :create) %>
```

#### ファイル: web/templates/user/edit.html.eex

```html
<h2>Edit Profile</h2>

<%= render "form.html", changeset: @changeset,
                        action: user_path(@conn, :update, @user) %>
```

二つのテンプレートが大分すっきりしましたね。  

共通で利用したい、別で定義したい部分だけを切り出して、  
別のテンプレートを作成するのは、よくある手法です。  

## The difference of authentication and authorization
認可処理を実装します。  

サインイン処理を行う時、認証と言う処理を実装しましたね。  
それとは違うものなんでしょうか？認証と認可は何が違うのでしょうか？  

二つの定義的なことをまとめると以下のようになります。  

認証: 本人を識別するIDなどで間違いなく本人だと見なすこと。一言で言えば本人確認。  
認可: 何かを利用したり、アクセスすることに対して許可を与えること。(認証済みであること)  

認可がどういったことをやるものなのか、少しは想像が付きました。  
では、edit、updateアクションに対して認可を行うようにしましょう。  

どういった認可を行う必要があるでしょうか？  
edit、updateアクションを実行できるのはどういったユーザであるかを考えれば出てきますね。  

- サインインしている状態であること
- ユーザは"自分"だけ更新できる

この二つの認可を実装します。  

## Signed in user?
まずは、サインインしているか否かの認可を実装します。  

このアプリケーションにおけるサインインしている状態とは、どういう状態でしょうか？  
我々は、既に答えを知っています。  

セッションを管理した時、サインインしていれば値を格納していましたね。  
このアプリケーションでは、assignに値が格納されていればサインインしていると判断します。  

サインインユーザであることを確認するためのモジュールプラグを作成します。  

#### File: lib/plugs/signed_in_user.ex

```elixir
defmodule SampleApp.Plugs.SignedInUser do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import SampleApp.Router.Helpers, only: [session_path: 2]

  def init(options) do
    options
  end

  def call(conn, _) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:info, "Please sign-in.")
      |> redirect(to: session_path(conn, :new))
      |> halt
    end
  end
end
```

サインインをしていなければ、  
サインインを促すメッセージの表示とサインインページへのリダイレクトを行います。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug SampleApp.Plugs.SignedInUser

  ...
end
```

おっと、このままではサインインしていなくても表示できる全てのページが、  
サインインしていなければ表示できなくなってしまいます。  

ユーザの作成ページがサインインしていなければ表示されないとは、何の冗談なのでしょうか？  
(プラグはアクションを指定しなければ、全てのアクションで動作します。)  

特定のアクションでのみ動作するように修正します。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug SampleApp.Plugs.SignedInUser when action in [:show, :edit, :update]

  ...
end
```

Guard句を使って動作させたいアクションを指定することができます。  

## Correct user?
次は、サインインしたユーザが"自分"だけ更新できるようにします。  
所謂、アクセス制御と言われるものですね。  

Aと言うユーザがBと言うユーザのプロファイルを更新できたらおかしいですよね。  

今回はモジュールプラグではなく、機能プラグと言うものを使ってみます。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.SignedInUser when action in [:show, :edit, :update]
  plug :correct_user? when action in [:edit, :update]

  ...

  defp correct_user?(conn, _) do
    user = Repo.get(SampleApp.User, String.to_integer(conn.params["id"]))

    if current_user?(conn, user) do
      conn
    else
      conn
      |> put_flash(:info, "Please sign-in.")
      |> redirect(to: session_path(conn, :new))
      |> halt
    end
  end

  defp current_user?(conn, user) do
    conn.assigns[:current_user] == user
  end
end
```

内容は、単純な実装をしています。  
ユーザIDからDBデータを取得し、サインインしているユーザの構造体同士を比較しています。  

前の章でプラグを作成した時には、プラグの種類について説明していませんでした。  
プラグは関数でも定義できます。  
前の章で作成したモジュールのプラグをモジュールプラグ、今回のプラグは機能(関数)プラグと呼ばれています。  

複数のコントローラを跨いで利用したい場合は、モジュールプラグを利用した方が良いです。  
また、単一のコントローラでしか利用しないのであれば、機能プラグを利用しましょう。  
必要に応じて使い分けてあげましょう。  

#### Note:

```txt
同じユーザをの構造体を比較してみる。  

iex> SampleApp.Repo.get(User, 1) == SampleApp.Repo.get(User, 1)
true
```

## All users
ユーザの一覧を実装します。  

Userコントローラへindexアクションを追加します。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end
end
```

indexアクションをSampleApp.Plugs.SignedInUserプラグへ追加します。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  plug SampleApp.Plugs.SignedInUser when action in [:index, :show, :edit, :update]

  ...
end
```

indexテンプレートを作成します。  

#### File: web/templates/user/index.html.eex

```html
<h1>All users</h1>

<%= if !is_empty_list?(@users) do %>
  <ul class="users">
    <%= for user <- @users do %>
      <%= render "user.html", conn: @conn, user: user %>
    <% end %>
  </ul>
<% end %>
```

ユーザ単体の表示を別のテンプレートで作成します。  

#### ファイル: web/templates/user/user.html.eex

```html
<li>
  <img src="<%= get_gravatar_url(@user) %>" class="gravatar">
  <%= link @user.name, to: user_path(@conn, :show, @user) %>
</li>
```

空リストか判定する関数をUserビューへ追加します。  

#### File: web/views/user_view.ex

```elixir
defmodule SampleApp.UserView do
  ...

  def is_empty_list?(list) when is_list(list) do
    list == []
  end
end
```

ユーザ表示用のCSSを追加します。  

#### File: priv/static/css/custom.css

```css
/* Users index */
.users {
  list-style: none;
  margin: 0;
}

.users li {
  overflow: auto;
  padding: 10px 0;
  border-top: 1px solid #eeeeee;
}

.users li:last-child {
  border-bottom: 1px solid #eeeeee;
}
```

これでユーザの全件が表示されるようになりました。  

しかし、ユーザの数が100や200になったら下までスクロールするのは大変ですね。  
なので、ページを分割するページネーションを実装します。  

## All users link
おっと、忘れる前にユーザ一覧へのリンクを追加してしまいましょう。  

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
              <li><%= link "All Users", to: user_path(@conn, :index) %><li>

              ...
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

## Pagination
さて、本章最大の山場であるページネーションに取り掛かるとしましょう。  

ページネーションとは、あるWebページの情報を区切って表示することです。  
今回で言うならユーザの一覧を区切って表示できるようにするといったところですね。  

まずは、Userモデルにページネーションの情報を取得するための関数を作成します。  

#### File: web/models/user.ex

```elixir
defmodule SampleApp.User do
  ...

  def paginate(select_page) do
    SampleApp.Helpers.PaginationHelper.paginate(
      from(u in SampleApp.User, order_by: [asc: :name]),
      select_page)
  end
end

```

利用しているヘルパーはまだ存在していませんので、  
ページネーションを補助するモジュールを作成します。  

#### File: lib/helpers/pagination_helper.ex

```elixir
defmodule SampleApp.Helpers.PaginationHelper do
  @page_size "2"

  def paginate(query, select_page) do
    query |> SampleApp.Repo.paginate(page: select_page, page_size: @page_size)
  end
end
```

ページサイズは、1つのページに表示する最大表示件数のことです。  
任意の値に変更して構いません。  

先ほど、Userモデルに作成したpaginate/1関数を使うように修正します。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def index(conn, params) do
    select_page = params["select_page"]
    page = SampleApp.User.paginate(select_page)

    if page do
      render(conn, "index.html",
             users: page.entries,
             current_page: page.page_number,
             total_pages: page.total_pages,
             page_list: Range.new(1, page.total_pages))
    else
      conn
      |> put_flash(:error, "Invalid page number!!")
      |> render("index.html", users: [])
    end
  end
end
```

select_pageをパラメータから取得していますが、  
これはテンプレートのリンク作成時にパラメータを指定して送ります。  

また、ページの情報を取得できない場合は、エラーを表示しています。  

## Pagination view and template
ページネーションを表示するためのビューとテンプレートを作成します。  

ページネーション用のビューを作成します。  
このビューには、ページリンクを作成するための関数を実装します。  

#### File: web/views/pagination_view.ex

```elixir
defmodule SampleApp.PaginationView do
  use SampleApp.Web, :view

  def get_previous_page_url(action, current_page) do
    get_page_url(action, current_page - 1)
  end

  def get_next_page_url(action, current_page) do
    get_page_url(action, current_page + 1)
  end

  def get_page_url(action, page_number) do
    "#{action}?select_page=#{page_number}"
  end
end
```

ページネーションのテンプレートを格納するディレクトリを作成します。
paginationと言う名称で作成して下さい。

#### Directory: web/templates/pagination

ページのリンクを表示するテンプレートを作成します。  

#### File: web/templates/pagination/pagination.html.eex

```html
<nav>
  <ul class="pagination">

  <!-- previous link -->
  <%= if @current_page > 1 do %>
    <li>
      <a href="<%= get_previous_page_url(@action, @current_page) %>" aria-label="Previous">
        <span aria-hidden="true">&laquo;</span>
      </a>
    </li>
  <% end %>

  <!-- page link -->
  <%= for page_number <- @page_list do %>
    <%= if page_number == @current_page do %>
      <li class="active">
        <a href="<%= get_page_url(@action, page_number) %>">
          <%= page_number %><span class="sr-only">(current)</span>
        </a>
      </li>
    <% else %>
      <li><a href="<%= get_page_url(@action, page_number) %>"><%= page_number %></a></li>
    <% end %>
  <% end %>

  <!-- next link -->
  <%= if @current_page < @total_pages do %>
    <li>
      <a href="<%= get_next_page_url(@action, @current_page) %>" aria-label="Next">
        <span aria-hidden="true">&raquo;</span>
      </a>
    </li>
  <% end %>

  </ul>
</nav>
```

"previous link"と"next link"の部分は一つ前と次のページを指定できるリンクを作成しています。  
また、一つ前と次が存在しない場合は、リンクを作成しないようにif記述で分岐させています。  

"page link"を作成する部分は、for記述で繰り返しで処理を行っています。  
また、選択中のページ番号はデザインを変更するために、現在ページとそれ以外で処理を分岐させています。  

ユーザ一覧にページネーションの表示を追加します。  

#### File: web/templates/user/index.html.eex

```html
<h1>All users</h1>

<%= if !is_empty_list?(@users) do %>
  <%= render SampleApp.PaginationView, "pagination.html",
             action: user_path(@conn, :index),
             current_page: @current_page,
             page_list: @page_list,
             total_pages: @total_pages %>

  <ul class="users">
    <%= for user <- @users do %>
      <%= render "user.html", conn: @conn, user: user %>
    <% end %>
  </ul>

  <%= render SampleApp.PaginationView, "pagination.html",
             action: user_path(@conn, :index),
             current_page: @current_page,
             page_list: @page_list,
             total_pages: @total_pages %>

<% end %>
```

## Is able to paginate?
ページネーションで指定されたページ番号が不正でないか確認しましょう。  
今のままでは、マイナスのページ番号や文字列を送られた場合、不具合が起こります。  

その対応を行います。  

#### File: lib/helpers/pagination_helper.ex

```elixir
defmodule SampleApp.Helpers.PaginationHelper do
  @first_page "1"
  @page_size "10"

  defp is_nil_or_empty?(select_page) do
    is_nil(select_page) || select_page == ""
  end

  defp is_valid_value?(select_page) do
    Regex.match?(~r/^[0-9]+$/, select_page)
  end

  defp is_able_to_paginate?(select_page) do
    !is_nil_or_empty?(select_page) && is_valid_value?(select_page)
  end
  
  def paginate(query, select_page) do
    if is_able_to_paginate?(select_page) do
      query |> SampleApp.Repo.paginate(page: select_page, page_size: @page_size)
    else
      query |> SampleApp.Repo.paginate(page: @first_page, page_size: @page_size)
    end
  end
end
```

それぞれ追加した関数は以下の機能を実装しています。

- is_nil_or_empty?/1: ページ番号が存在しているか判定します
- is_valid_value?/1: プラスの半角数字の繰り返しか判定します
- is_able_to_paginate?/1: 上記、二つを組み合わせています

また不正な値を送った場合、最初のページを返すようにpaginate/2を修正しています。  

## Delete user
ユーザを削除できるようにします。  
DBからデータそのものを削除します。  

論理的なフラグを立てる削除ではありません。  
なので、データは元に戻せないので注意して下さい。  

更新や一覧よりは簡単なので、さっさと終わらせてしまいましょう。  

Userコントローラへdeleteアクションを追加します。  
また当然ですが、サインインしていることと、自分自身しか削除できないようにします。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.SignedInUser when action in [:index, :show, :edit, :update, :delete]
  plug :correct_user? when action in [:edit, :update, :delete]

  ...

  def delete(conn, %{"id" => id}) do
    user = Repo.get(SampleApp.User, id)
    Repo.delete(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> delete_session(:user_id)
    |> redirect(to: static_pages_path(conn, :home))
  end

  ...
end
```

## Delete link
削除リンクをプロファイルページに表示します。  

#### File: web/templates/user/show.html.eex

```html
<div class="row">
  <aside class="span4">

    ...

    <section>
      <%= link "Edit", to: user_path(@conn, :edit, @user), class: "btn btn-default btn-xs" %>
      <%= button "Delete", to: user_path(@conn, :delete, @user), method: :delete, class: "btn btn-danger btn-xs" %>
    </section>
  </aside>
</div>
```

## Before the end
ソースコードをマージします。  

#### Example:

```cmd
>git add .
>git commit -am "Finish updating_users."
>git checkout master
>git merge updating_users
```

# Speaking to oneself
機能を3つも実装しました。  

大変長かったと思いますが、一旦休憩を取りましょう。

# Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/updating-showing-and-deleting-users?version=4.0#top)  
[Ruby on Rails Tutorial - 第九章](http://railstutorial.jp/chapters/updating-showing-and-deleting-users?version=4.0#sec-authorization)  
[ITmedia - 認証と認可の違い](http://www.itmedia.co.jp/enterprise/articles/0804/22/news044.html)  
[hexdocs - Plug.Conn.AlreadySentError](http://hexdocs.pm/plug/0.12.1/Plug.Conn.AlreadySentError.html)  
[hexdocs - Plug v0.13.0 Plug.Conn.halt/1](http://hexdocs.pm/plug/Plug.Conn.html#halt/1)  
[Phoenix - Guide Plug](http://www.phoenixframework.org/docs/understanding-plug)  
[PhoenixのPlugについて分かったこと](http://daruiapprentice.blogspot.jp/2015/07/phoenix-plug.html)  
[StackOverflow - Convert Elixir string to integer or float](http://stackoverflow.com/questions/22576658/convert-elixir-string-to-integer-or-float)  
[hexdocs - Ecto.Repo v0.14.2](http://hexdocs.pm/ecto/Ecto.Repo.html)  
[Pagination with rel=“next” and rel=“prev”](http://googlewebmastercentral.blogspot.jp/2011/09/pagination-with-relnext-and-relprev.html)  
