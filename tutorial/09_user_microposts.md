# Goal
ユーザの投稿機能を実装する。  

# Wait a minute
ようやっと、Userモデル以外のモデルが出てきます。  

ユーザが投稿できるマイクロポストを実装します。  
Userモデルとの関連付け(1対多、1対1)もこの章で実施します。  

ここまでお付き合い頂いた皆さんなら、本章は特に難しいところはありません。  

寧ろ拍子抜けしてしまうかもしれません。  
皆さんが成長した証拠です！！  

# Index
User microposts  
|> Preparation  
|> Micropost data model  
|> User has many Micropost, Also Micropost belongs to User  
|> Interlocking Delete  
|> Validation  
|> Microposts List  
|> Microposts pagination  
|> Micropost controller  
|> Sign-in required  
|> Micropost Posts  
|> Delete Micropost  
|> Shared view  
|> Before the end  

## Preparation
作業前にブランチを切ります。  

#### Example:

```cmd
>cd path/to/sample_app
>git checkout -b user_microposts
```

## Micropost data model
マイクロポストのデータモデルの提示と実装を行います。  

- マイクロポストのデータモデル
  * モデル名: Micropost
  * テーブル名: microposts
  * 生成カラム(カラム名:型): content:string, user_id:integer
  * 自動生成カラム(カラム名:型): id:integer, inserted_at:timestamp, updated_at:timestamp
  * インデックス(対象カラム名): user_idとinserted_atの複合インデックス

データモデルを把握したところで、早速実装に取り掛かりましょう。  

Userモデルを生成した時のようにモデルファイルとマイグレーションファイルを生成します。  

#### Example:

```cmd
>mix phoenix.gen.model Micropost microposts content:string user_id:integer
```

マイグレーションファイルを編集します。  

#### File: priv/repo/migrations/[timestamp]_create_micropost.exs

```elixir
defmodule SampleApp.Repo.Migrations.CreateMicropost do
  use Ecto.Migration
  @disable_ddl_transaction true

  def change do
    create table(:microposts) do
      add :content, :string
      add :user_id, :integer

      timestamps
    end

    create index(:microposts, [:user_id, :inserted_at], concurrently: true)
  end
end
```

以前、Userモデルを作成する時にもインデックスを作成しました。  
今回は、複数インデックスを作成します。  

複合インデックスを作成する場合は、リストで複数カラムを指定するだけです。  
単一カラムをインデックスにする場合と比べても難しくありませんね。  

マイグレーションを実行します。  

#### Example:

```cmd
>mix ecto.migrate
```

これで、Micropostモデルの作成ができました。  

## User has many Micropost, Also Micropost belongs to User
ユーザは複数のマイクロポストを持ち、マイクロポストはユーザに属する関連付けを行いましょう。  
作成したMicropostモデルと、既に作成しているUserモデルを紐づけます。  

Ectoにある以下の機能を利用します。  

- Ecto.Schema.has_many/3
- Ecto.Schema.belongs_to/3

1対多の関連をUserモデルに定義します。  

#### File: web/models/user.ex

```elixir
defmodule SampleApp.User do
  ...

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_digest, :string
    field :password, :string, virtual: true

    has_many :microposts, SampleApp.Micropost

    timestamps
  end

  ...
end
```

ユーザのスキーマでhas_manyを使い、マイクロポストを指定しています。  

ユーザは複数の投稿を持ちますが、  
一つのマイクロポストは一人のユーザに結びついています。  

なので、1対1の関連をMicropostモデルに定義します。  

#### File: web/models/micropost.ex

```elixir
defmodule SampleApp.Micropost do
  ...

  schema "microposts" do
    field :content, :string

    belongs_to :user, SampleApp.User, foreign_key: :user_id

    timestamps
  end

  ...
end
```

マイクロポストのスキーマでbelongs_toを使い、ユーザを指定しています。  
ちょっと注意です。user_idは、belongs_toの外部キーに指定しています。  

そのため、フィールドとして記述していません。  

せっかくなので、関連の機能をiexから試してみましょう。  

#### Example:

```cmd
iex> alias SampleApp.User
nil
iex> alias SampleApp.Micropost
nil
iex> alias SampleApp.Repo
nil
iex> user_param = %{name: "hoge", email: "hoge@test.com", password: "hogehoge"}
...
iex> Repo.insert!(User.changeset(%User{}, user_param))
...
iex> micropost_param = %{content: "hogehoge", user_id: 1}
...
iex> Repo.insert!(Micropost.changeset(%Micropost{}, micropost_param))
...
```

ユーザに関連するマイクロポストを取得しています。  

```cmd
iex> user = Repo.get(User, 1) |> Repo.preload(:microposts)
%SampleApp.User{__meta__: #Ecto.Schema.Metadata<:loaded>,
 email: "hoge@test.com", id: 1,
 inserted_at: #Ecto.DateTime<2015-10-26T06:59:05Z>,
 microposts: [%SampleApp.Micropost{__meta__: #Ecto.Schema.Metadata<:loaded>,
   content: "hogehoge", id: 1,
   inserted_at: #Ecto.DateTime<2015-10-26T07:01:21Z>,
   updated_at: #Ecto.DateTime<2015-10-26T07:01:21Z>,
   user: #Ecto.Association.NotLoaded<association :user is not loaded>,
   user_id: 1}], name: "hoge", password: nil,
 password_digest: "****",
 updated_at: #Ecto.DateTime<2015-10-26T06:59:05Z>}

iex> user.microposts
[%SampleApp.Micropost{__meta__: #Ecto.Schema.Metadata<:loaded>,
  content: "hogehoge", id: 1, inserted_at: #Ecto.DateTime<2015-10-26T07:01:21Z>,
  updated_at: #Ecto.DateTime<2015-10-26T07:01:21Z>,
  user: #Ecto.Association.NotLoaded<association :user is not loaded>,
  user_id: 1}]
```

マイクロポストを投稿したユーザを取得しています。

```cmd
iex> micropost = Repo.get(Micropost, 1) |> Repo.preload(:user)
%SampleApp.Micropost{__meta__: #Ecto.Schema.Metadata<:loaded>,
 content: "hogehoge", id: 1, inserted_at: #Ecto.DateTime<2015-10-26T07:01:21Z>,
 updated_at: #Ecto.DateTime<2015-10-26T07:01:21Z>,
 user: %SampleApp.User{__meta__: #Ecto.Schema.Metadata<:loaded>,
  email: "hoge@test.com", id: 1,
  inserted_at: #Ecto.DateTime<2015-10-26T06:59:05Z>,
  microposts: #Ecto.Association.NotLoaded<association :microposts is not loaded>,
  name: "hoge", password: nil,
  password_digest: "****",
  updated_at: #Ecto.DateTime<2015-10-26T06:59:05Z>}, user_id: 1}

iex> microposts.user
%SampleApp.User{__meta__: #Ecto.Schema.Metadata<:loaded>,
 email: "hoge@test.com", id: 1,
 inserted_at: #Ecto.DateTime<2015-10-26T06:59:05Z>,
 microposts: #Ecto.Association.NotLoaded<association :microposts is not loaded>,
 name: "hoge", password: nil,
 password_digest: "****",
 updated_at: #Ecto.DateTime<2015-10-26T06:59:05Z>}
iex> microposts.user.name
"hoge"
```

preloadを使えば、関連のあるモデルのデータも取得することができます。  
またpreloadで取得する際、さらにクエリを指定することもできます。  

## Interlocking Delete
連動した削除を行いましょう！  

ユーザが削除されたら、そのユーザのマイクロポストも削除します。  
そうでなくては、ユーザの登録が消えているのに、マイクロポストだけが残ってしまいますね。  

Userコントローラのdeleteアクションに処理を追加します。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def delete(conn, %{"id" => id}) do
    user = Repo.get(SampleApp.User, id)
    Repo.delete_all(from(m in SampleApp.Micropost, where: m.user_id == ^user.id))
    Repo.delete(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> delete_session(:user_id)
    |> redirect(to: static_pages_path(conn, :home))
  end

  ...
end
```

ユーザを削除する前にdelete_all/2関数を使って、  
削除するユーザのIDに一致するマイクロポストを全て削除しています。  

## Validation
マイクロポストに対して、Validationを追加します。  

#### File: web/models/micropost.ex

```elixir
def changeset(model, params \\ :empty) do
  model
  |> cast(params, @required_fields, @optional_fields)
  |> validate_length(:content, min: 1)
  |> validate_length(:content, max: 140)
end
```

某SNSのように、投稿文字数を140文字以内に制限をしています。  

## Microposts List
ユーザのプロファイルページに手を入れて、マイクロポストの一覧を表示できるようにしましょう。  

Userコントローラのshowアクションで、  
ユーザのIDが一致するマイクロポストを取得します。  

#### File: web/controllers/user_controller.ex

```elixir
def show(conn, %{"id" => id}) do
  user = Repo.get(SampleApp.User, id)
  page = Repo.all(from(m in SampleApp.Micropost, where: m.user_id == ^user.id, order_by: [desc: m.inserted_at]))
  render(conn, "show.html", user: user, posts: page)
end
```

ユーザのプロファイルページにマイクロポストの表示を追加します。  

#### File: web/templates/user/show.html.eex

```html
<div class="row">
  <aside class="col-md-4">
    ...
  </aside>

  <div class="col-md-8">
    <%= unless is_empty_list?(@posts) do %>
      <h3>Microposts</h3>
      <ol class="microposts">
        <li>
          <%= for post <- @posts do %>
            <span class="content"><%= post.content %></span>
            <span class="timestamp">
              Posted <%= post.inserted_at %> ago.
            </span>
          <% end %>
        </li>
      </ol>
    <% end %>
  </div>
</div>
```

マイクロポストのCSSを追加します。  

#### File: priv/static/css/custom.css

```css
/* microposts */
.microposts {
  list-style: none;
  margin: 10px 0 0 0;
}

.microposts li {
  padding: 10px 0;
  border-top: 1px solid #e8e8e8;
}

.content {
  display: block;
}

.timestamp {
  color: #777777;
}

.gravatar {
  float: left;
  margin-right: 10px;
}

aside textarea {
  height: 100px;
  margin-bottom: 5px;
}
```

## Microposts pagination
マイクロポストの表示をページネーションで区切って表示できるようにします。  

Micropostモデルにページネーション関数を追加します。  

#### File: web/models/micropost.ex

```elixir
defmodule SampleApp.Micropost do
  ...

  def paginate(user_id, select_page) do
    SampleApp.Helpers.PaginationHelper.paginate(
      from(m in SampleApp.Micropost, where: m.user_id == ^user_id, order_by: [desc: m.inserted_at]),
      select_page)
  end
end
```

Userコントローラのshowアクションを修正します。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def show(conn, %{"id" => id} = params) do
    select_page = params["select_page"]

    user = Repo.get(SampleApp.User, id)
    page = SampleApp.Micropost.paginate(user.id, select_page)

    if page do
      render(conn, "show.html",
             user: user,
             posts: page.entries,
             current_page: page.page_number,
             total_pages: page.total_pages,
             page_list: Range.new(1, page.total_pages))
    else
      conn
      |> put_flash(:error, "Invalid page number!!")
      |> render("show.html", user: user, posts: [])
    end
  end
end
```

showテンプレートにページネーションの表示を追加します。  

#### File: web/templates/user/show.html.eex

```html
<div class="row">
  <aside class="col-md-4">
    ...
  </aside>

  <div class="col-md-8">
    <%= unless is_empty_list?(@posts) do %>
      <h3>Microposts</h3>
      <ol class="microposts">
        <li>
          <%= for post <- @posts do %>
            <span class="content"><%= post.content %></span>
            <span class="timestamp">
              Posted <%= post.inserted_at %> ago.
            </span>
          <% end %>
        </li>
      </ol>

      <%= render SampleApp.PaginationView, "pagination.html",
               action: user_path(@conn, :show, @user),
               current_page: @current_page,
               page_list: @page_list,
               total_pages: @total_pages %>
    <% end %>
  </div>
</div>
```

## Micropost controller
マイクロポストを投稿 / 削除を実装するため、マイクロポストのcreate、deleteアクションが必要です。  
マイクロポストの動作を実装するため、コントローラを作成します。  

ルーティングを追加します。

#### File: web/router.ex

```elixir
scope "/", SampleApp do
    pipe_through :browser # Use the default browser stack

    ...
    resources "/post", MicropostController, only: [:create, :delete]
end
```

onlyオプションを付けて、resourcesを記述すると  
指定したアクションだけルーティングに追加されます。  

#### File: web/controllers/micropost_controller.ex

```elixir
defmodule SampleApp.MicropostController do
  use SampleApp.Web, :controller

  def create(conn, _params) do
    redirect(conn, to: user_path(conn, :show, conn.assigns[:current_user]))
  end

  def delete(conn, _params) do
    redirect(conn, to: user_path(conn, :show, conn.assigns[:current_user]))
  end
end
```

## Sign-in required
アクションの内容を実装する前に、サインインしたユーザだけが他のユーザのプロファイルページを見れるようにしましょう。  
前に作成しているモジュールプラグがあるので、記述を追加するだけですね。  

サインイン状態を判定するプラグを追加します。  

#### File: web/controllers/micropost_controller.ex

```elixir
defmodule SampleApp.MicropostController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.SignedInUser

  ...
end
```

## Micropost Posts
マイクロポストの投稿を実装します。  
Micropostコントローラのcreateアクションを実装します。  

Micropostモデルへ、指定されたユーザIDによってChangesetを生成する関数を追加します。  

#### File: web/models/micropost.ex

```elixir
def new(user_id) do
  %SampleApp.Micropost{}
  |> cast(%{content: "", user_id: user_id}, @required_fields, @optional_fields)
end
```

Userコントローラのshowアクションで、マイクロポストのChangesetを送ります。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  ...

  def show(conn, %{"id" => id} = params) do
    select_page = params["select_page"]

    user = Repo.get(SampleApp.User, id)
    page = SampleApp.Micropost.paginate(user.id, select_page)
    changeset = SampleApp.Micropost.new(user.id)

    if page do
      render(conn, "show.html",
             user: user,
             posts: page.entries,
             current_page: page.page_number,
             total_pages: page.total_pages,
             page_list: Range.new(1, page.total_pages),
             changeset: changeset)
    else
      conn
      |> put_flash(:error, "Invalid page number!!")
      |> render("show.html", user: user, posts: [])
    end
  end
end
```

マイクロポストのビューを作成します。  

#### File: web/view/micropost_view.ex

```elixir
defmodule SampleApp.MicropostView do
  use SampleApp.Web, :view
end
```

マイクロポストのテンプレートを格納するディレクトリを作成します。  
micropostと言うディレクトリを作成して下さい。  

#### Directory: web/templates/micropost

マイクロポストの入力フォームを作成します。  
showテンプレートにそのまま記述すると読み辛くなるので、最初から別テンプレートに分けましょう。  

#### File: web/templates/micropost/form.html.eex

```html
<%= if current_user?(@conn, @user) do %>
  <%= form_for @changeset, micropost_path(@conn, :create), fn f -> %>
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

    <%= hidden_input f, :user_id %>

    <div class="form-group">
      <%= label f, :content, "Content", class: "control-label" %>
      <%= textarea f, :content, class: "form-control" %>
    </div>

    <div class="form-group">
      <%= submit "Post", class: "btn btn-primary" %>
    </div>
  <% end %>
<% end %>
```

user_idは入力する項目ではないため、hiddenで送っています。  
hiddenがない場合、値が失われてしまうので注意して下さい。  

ビューヘルパーへ関数を追加します。  
表示しているプロファイルページのユーザとログインしているユーザが同じか判定する関数です。  

#### File: lib/helpers/view_helper.ex

```elixir
defmodule SampleApp.Helpers.ViewHelper do
  ...

  def current_user?(conn, %SampleApp.User{id: id}) do
    user = SampleApp.Repo.get(SampleApp.User, id)
    conn.assigns[:current_user] == user
  end
end
```

表示しているページが他のユーザのページなのに、  
入力フォームが表示され投稿できたらおかしなことになってしまうので、それを防ぐためです。  
そのため、formテンプレートでもif記述を使って処理を分けています。  

showテンプレートからマイクロポストのformテンプレートを呼び出します。  

#### File: web/templates/user/show.html.eex

```html
<div class="row">
  <aside class="span4">
    ...

    <section>
      <%= render SampleApp.MicropostView, "form.html", conn: @conn, changeset: @changeset, user: @user %>
    </section>
  </aside>

  <div class="col-md-8">
    ...
  </aside>
</div>
```

Micropostコントローラのcreateアクションを実装します。  

#### File: web/controllers/micropost_controller.ex

```elixir
defmodule SampleApp.MicropostController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.SignedInUser
  plug :scrub_params, "micropost" when action in [:create]

  def create(conn, %{"micropost" => micropost_params}) do
    changeset = SampleApp.Micropost.changeset(%SampleApp.Micropost{}, micropost_params)

    if changeset.valid? do
      Repo.insert(changeset)
      conn = put_flash(conn, :info, "Post successfully!!")
    else
      conn = put_flash(conn, :error, "Post failed!!")
    end

    redirect(conn, to: user_path(conn, :show, conn.assigns[:current_user]))
  end

  ...
end
```

これで画面から投稿ができるようになりました。  

## Delete Micropost
マイクロポストの削除機能を実装します。  

Micropostコントローラのdeleteアクションを実装します。  

#### File: web/controllers/micropost_controller.ex

```elixir
defmodule SampleApp.MicropostController do
  ...

  def delete(conn, %{"id" => id}) do
    micropost = Repo.get(SampleApp.Micropost, id)
    Repo.delete(micropost)

    conn
    |> put_flash(:info, "Micropost deleted successfully.")
    |> redirect(to: user_path(conn, :show, conn.assigns[:current_user]))
  end
end
```

テンプレートに投稿の削除リンクを追加します。  

#### File: web/templates/user/show.html.eex

```html
<div class="row">
  ...

  <div class="col-md-8">
    <%= unless is_empty_list?(@posts) do %>
      <h3>Microposts</h3>
      <ol class="microposts">
        <li>
          <%= for post <- @posts do %>
            <span class="content"><%= post.content %></span>
            <span class="timestamp">
              Posted <%= post.inserted_at %> ago.
            </span>
            <%= if @user.id == post.user_id do %>
              <%= link "Delete", to: micropost_path(@conn, :delete, post), method: :delete, class: "btn btn-danger btn-xs" %>
            <% end %>
          <% end %>
        </li>
      </ol>

      <%= render SampleApp.PaginationView, "pagination.html",
               action: user_path(@conn, :show, @user),
               current_page: @current_page,
               page_list: @page_list,
               total_pages: @total_pages %>
    <% end %>
  </div>
</div>
```

## Shared view
共通で使いたいテンプレートを扱うためのSharedビューを作成します。  

#### File: web/views/shared_view.ex

```elixir
defmodule SampleApp.SharedView do
  use SampleApp.Web, :view
end
```

共有テンプレートを格納するディレクトリを作成します。  
sharedと言うディレクトリを作成して下さい。  

#### Directory: web/templates/shared

まずは、ユーザを表示する部分を別テンプレートにします。  

#### File: web/templates/shared/user_info.html.eex

```html
<a href="<%= user_path(@conn, :show, @user) %>">
  <img src="<%= get_gravatar_url(@user) %>" class="gravatar">
</a>
<h1><%= @user.name %></h1>
```

get_gravatar_url/1関数ですが、現在はUserビューに定義されています。  
shared_viewでも利用するためには、ビューヘルパーへ移動しなければいけません。  

#### File: lib/helpers/view_helper.ex

```elixir
defmodule SampleApp.Helpers.ViewHelper do
  alias SampleApp.User
  alias SampleApp.Gravatar

  ...

  def get_gravatar_url(%User{email: email}) do
    Gravatar.get_gravatar_url(email, 50)
  end
end
```

続いて、マイクロポストの表示を別テンプレートに分けます。  

#### File: web/templates/shared/microposts.html.eex

```html
<ol class="microposts">
  <li>
  <%= for post <- @posts do %>
    <span class="content"><%= post.content %></span>
    <span class="timestamp">
      Posted <%= post.inserted_at %> ago.
    </span>
    <%= if @user.id == post.user_id do %>
      <%= link "Delete", to: micropost_path(@conn, :delete, post), method: :delete, class: "btn btn-danger btn-xs" %>
    <% end %>
  <% end %>
  </li>
</ol>
```

showテンプレートを修正します。  

#### ファイル: web/templates/user/show.html.eex

```html
<h2>User profile</h2>

<div class="row">
  <aside class="col-md-4">
    <section>
      <%= render SampleApp.SharedView, "user_info.html", conn: @conn, user: @user %>
    </section>
    ...
  </aside>
  
  <div class="col-md-8">
    <%= unless is_empty_list?(@posts) do %>
      <h3>Microposts</h3>
      <%= render SampleApp.SharedView, "microposts.html", conn: @conn, posts: @posts, user: @user %>

      <%= render SampleApp.PaginationView, "pagination.html",
               action: user_path(@conn, :show, @user),
               current_page: @current_page,
               page_list: @page_list,
               total_pages: @total_pages %>
    <% end %>
  </div>
</div>
```

別のビューでレンダリングする場合の呼び出し方は、上記の記述の通りです。  
renderの第一引数で、そのビューを指定するだけです。  

## Before the end
ソースコードをマージします。  

```cmd
>git add .
>git commit -am "Finish user_microposts."
>git checkout master
>git merge user_microposts
```

# Speaking to oneself
これでマイクロポストの投稿機能は実装終了です。  

次が最後の章です。  
最後の山場になるので、頑張りましょう。  

# Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/user-microposts?version=4.0#top)  
[hexdocs - v0.14.3 Ecto.Migration](http://hexdocs.pm/ecto/0.14.3/Ecto.Migration.html)  
[hexdocs - v0.14.3 Ecto.Migration.index/3](http://hexdocs.pm/ecto/0.14.3/Ecto.Migration.html#index/3)  
[hexdocs - v0.14.3 Ecto.Repo](http://hexdocs.pm/ecto/0.14.3/Ecto.Repo.html)  
[hexdocs - v0.14.3 Ecto.Query](http://hexdocs.pm/ecto/Ecto.Query.html)  
[CREATE INDEX - インデックスの同時作成](https://www.postgresql.jp/document/9.3/html/sql-createindex.html#SQL-CREATEINDEX-CONCURRENTLY)  
[Phoenix - Guide Ecto Models](http://www.phoenixframework.org/v0.13.1/docs/ecto-models)  