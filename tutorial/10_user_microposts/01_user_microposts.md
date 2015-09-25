#Goal
ユーザの投稿機能を実装する。  

#Wait a minute
ようやっと、Userモデル以外のモデルが出てきます。  
ユーザが投稿できるマイクロポストを実装します。  
Userモデルとの関連付け(1対多)もこの章で実施します。  

ここまでお付き合い頂いた皆さんなら、本章は特に難しいところはありません。  

寧ろ拍子抜けしてしまうかもしれません。  
皆さんが成長した証拠です！！  

#Index
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
|> Before the end  

## Preparation
作業前にブランチを切ります。  

```cmd
>cd path/to/sample_app
>git checkout -b user_microposts
```

## Micropost data model
マイクロポストのデータモデルの提示と実装を行います。  

- マイクロポストのデータモデル
  * モデル名: Micropost
  * テーブル名: microposts
  * 生成カラム(カラム名:型): content:string), user_id:integer)
  * 自動生成カラム(カラム名:型): id:integer, inserted_at:timestamp, updated_at:timestamp
  * インデックス(対象カラム名): user_id, 、inserted_at

データモデルを把握したところで、早速実装に取り掛かりましょう。  

Userモデルを生成した時のようにモデルファイルとマイグレーションファイルを生成します。  

#### Example:

```cmd
>mix phoenix.gen.model Micropost microposts content:string user_id:integer
* creating priv/repo/migrations/[timestamp]_create_micropost.exs
* creating web/models/micropost.ex
* creating test/models/micropost_test.exs
```

マイグレーションファイルを編集します。  

#### ファイル: priv/repo/migrations/[timestamp]_create_micropost.exs

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

マイグレーションを実行します。  

#### Example:

```cmd
>mix ecto.migrate

14:20:27.485 [info]  == Running SampleApp.Repo.Migrations.CreateMicropost.change/0 forward

14:20:27.485 [info]  create table microposts

14:20:27.504 [info]  create index microposts_user_id_inserted_at_index

14:20:27.523 [info]  == Migrated in 0.3s
```

これで、Micropostモデルの作成ができました。  

## User has many Micropost, Also Micropost belongs to User
ユーザは複数のマイクロポストを持ち、マイクロポストはユーザに属する関連付けを行いましょう。  
作成したMicropostモデルと、既に作成しているUserモデルを紐づけます。  

Ectoにある以下の機能を利用します。

- Ecto.Schema.has_many/3
- Ecto.Schema.belongs_to/3

1対多の関連をUserモデルに定義します。  

#### ファイル: web/models/user.ex

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

1対1の関連をMicropostモデルに定義します。  

#### ファイル: web/models/micropost.ex

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

せっかくなので、関連の機能をiexから試してみましょう。  

#### Example:

```iex
iex> changeset = SampleApp.Micropost.changeset(%SampleApp.Micropost{}, %{content: "hogehoge", user_id: 1})
...
iex> SampleApp.Repo.insert(changeset)
...
iex> SampleApp.User |> SampleApp.Repo.get(1) |> SampleApp.Repo.preload [:microposts]
...
```

## Interlocking Delete
連動した削除を行いましょう！  

ユーザが削除されたら、そのユーザのマイクロポストも削除します。  
そうでなくては、ユーザの登録が消えているのに、マイクロポストだけが残ってしまいますね。  

Userコントローラのdeleteアクションに処理を追加します。  

#### ファイル: web/controllers/user_controller.ex

```elixir
def delete(conn, %{"id" => id}) do
  user = Repo.get(SampleApp.User, id)
  Repo.delete_all(from(m in SampleApp.Micropost, where: m.user_id == ^user.id))
  Repo.delete(user)

  conn
  |> put_flash(:info, "User deleted successfully.")
  |> redirect(to: static_pages_path(conn, :home))
end
```

ユーザを削除する前に、マイクロポストを全て削除しています。  

## Validation
マイクロポストに対して、Validationを追加します。  

#### ファイル: web/models/micropost.ex

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

Userコントローラのshowアクションで、マイクロポストを取得します。  

#### ファイル: web/controllers/user_controller.ex

```elixir
def show(conn, %{"id" => id}) do
  user = Repo.get(SampleApp.User, id)
  page = Repo.all(from(m in SampleApp.Micropost, where: m.user_id == ^user.id, order_by: [desc: m.inserted_at]))
  render(conn, "show.html", user: user, posts: page)
end
```

ユーザのプロファイルページにマイクロポストの表示を追加します。  

#### ファイル: web/templates/user/show.html.eex

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
          <% end %>
        </li>
      </ol>
    <% end %>
  </div>
</div>
```

マイクロポストのCSSを追加します。  

#### ファイル: priv/static/css/custom.css

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
マイクロポストの表示でページネーションを行うようにします。  

Micropostモデルにページネーション関数を追加します。  

#### ファイル: web/models/micropost.ex

```elixir
def paginate(user_id, select_page) do
  SampleApp.Helpers.PaginationHelper.paginate(
    from(m in SampleApp.Micropost, where: m.user_id == ^user_id, order_by: [desc: m.inserted_at]),
    select_page)
end
```

Userコントローラのshowアクションを修正します。  

#### ファイル: web/controllers/user_controller.ex

```elixir
def show(conn, params) do
  select_page = params["select_page"]
  id = params["id"]

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
```

showテンプレートに「ページネーションの表示を追加します。  

#### ファイル: web/templates/user/show.html.eex

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
マイクロポストを投稿 / 削除を実装するため、create、deleteアクションが必要です。  
マイクロポストの動作を実装するため、コントローラを作成します。  

ルーティングを追加します。

#### ファイル: web/router.ex

```elixir
scope "/", SampleApp do
    pipe_through :browser # Use the default browser stack

    ...
    resources "/post", MicropostController, only: [:create, :delete]
end
```

onlyオプションを付けて、resourcesを記述すると  
指定したアクションのみルーティングに追加されます。  

#### ファイル: web/controllers/micropost_controller.ex

```elixir
defmodule SampleApp.MicropostController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication

  def create(conn, _params) do
    redirect(conn, to: user_path(conn, :show, conn.assigns[:current_user]))
  end

  def delete(conn, _params) do
    redirect(conn, to: user_path(conn, :show, conn.assigns[:current_user]))
  end
end
```

## Sign-in required
アクションの内容を実装する前に...プロファイルページを見れるのはサインインしたユーザのみです。  
なので、サインイン状態を判定するプラグを追加します。  

#### ファイル: web/controllers/micropost_controller.ex

```elixir
defmodule SampleApp.MicropostController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug SampleApp.Plugs.SignedInUser

  def create(conn, _params) do
    redirect(conn, to: user_path(conn, :show, conn.assigns[:current_user]))
  end

  def delete(conn, _params) do
    redirect(conn, to: user_path(conn, :show, conn.assigns[:current_user]))
  end
end
```

## Micropost Posts
マイクロポストの投稿を実装します。  
Micropostコントローラのcreateアクションを実装します。  

Micropostモデルへ新しいChangeset返す関数を追加します。  

#### ファイル: web/models/micropost.ex

```elixir
def new(user_id) do
  %SampleApp.Micropost{}
  |> cast(%{content: "", user_id: user_id}, @required_fields, @optional_fields)
end
```

Userコントローラのshowアクションで、  
ユーザに入力させるためのchangesetを送ります。  

#### ファイル: web/controllers/user_controller.ex

```elixir
def show(conn, params) do
  select_page = params["select_page"]
  id = params["id"]

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
```

マイクロポストの入力フォームを作成します。  
showテンプレートにそのまま記述すると読み辛くなるので、別テンプレートに分けています。  

#### ファイル: web/templates/user/micropost_form.html.eex

```html
<%= if current_user?(@conn, @user) do %>
  <%= form_for @changeset, micropost_path(@conn, :create), fn f -> %>
    <%= hidden_input f, :user_id %>
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
      <label>Content</label>
      <%= textarea f, :content, class: "form-control" %>
      <%= submit "Post", class: "btn btn-primary" %>
    </div>
  <% end %>
<% end %>
```

user_idは入力する項目ではないため、hiddenで送っています。  
hiddenがない場合、値が失われてしまうので注意して下さい。  

showテンプレートから上記のテンプレートを呼び出します。  

#### ファイル: web/templates/user/show.html.eex

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
      <%= link "Delete", to: user_path(@conn, :delete, @user), method: :delete, class: "btn btn-danger btn-xs" %>
    </section>
    <section>
      <%= render "micropost_form.html", conn: @conn, changeset: @changeset, user: @user %>
    </section>
  </aside>
</div>
```

Micropostコントローラのcreateアクションを実装します。  

#### ファイル: web/controllers/micropost_controller.ex

```elixir
defmodule SampleApp.MicropostController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
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

画面から投稿ができるようになりました。  

## Delete Micropost
マイクロポストの削除機能を実装します。  

Micropostコントローラのdeleteアクションを実装します。  

#### ファイル: web/controllers/micropost_controller.ex

```elixir
def delete(conn, %{"id" => id}) do
  micropost = Repo.get(SampleApp.Micropost, id)
  Repo.delete(micropost)

  conn
  |> put_flash(:info, "Micropost deleted successfully.")
  |> redirect(to: user_path(conn, :show, conn.assigns[:current_user]))
end
```

テンプレートに投稿の削除リンクを追加します。  

#### ファイル: web/templates/user/show.html.eex

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

## Before the end
ソースコードをマージします。  

```cmd
>git add .
>git commit -am "Finish user_microposts."
>git checkout master
>git merge user_microposts
```

#Speaking to oneself
これで第10章は終わりです。  

次は最後になる第11章です。  
最後の山場になるので、頑張りましょう。  

#Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/user-microposts?version=4.0#top)  
[hexdocs - v0.14.3 Ecto.Migration](http://hexdocs.pm/ecto/0.14.3/Ecto.Migration.html)  
[hexdocs - v0.14.3 Ecto.Migration.index/3](http://hexdocs.pm/ecto/0.14.3/Ecto.Migration.html#index/3)  
[hexdocs - v0.14.3 Ecto.Repo](http://hexdocs.pm/ecto/0.14.3/Ecto.Repo.html)  
[hexdocs - v0.14.3 Ecto.Query](http://hexdocs.pm/ecto/Ecto.Query.html)  
[CREATE INDEX - インデックスの同時作成](https://www.postgresql.jp/document/9.3/html/sql-createindex.html#SQL-CREATEINDEX-CONCURRENTLY)  
[Phoenix - Guide Ecto Models](http://www.phoenixframework.org/v0.13.1/docs/ecto-models)  