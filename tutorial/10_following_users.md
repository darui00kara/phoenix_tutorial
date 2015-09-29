# Goal
ユーザ間のフォロー機能を実装する。  

# Wait a minute
長くお付き合い頂きましたが、本章で最後となります。  

本章の内容はフォロー機能の実装となります。  
このチュートリアルにおける最後の山場です。  

最後のひと踏ん張り頑張っていきましょう。  

# Index
Following users  
|> Preparation  
|> Relationship data model  
|> User and Relationship of association
|> Validation  
|> Utility Methods  
|> Following / Followers User List  
|> Follow / Unfollow Button  
|> Relationship Controller  
|> Following user microposts  
|> Before the end  

## Preparation
作業前にブランチを切ります。  

```cmd
>cd path/to/sample_app
>git checkout -b following_users
```

## Relationship data model
モデルを作成しますので、いつものようにデータモデルの提示をします。  

リレーションシップのデータモデルは以下になります。  

- リレーションシップのデータモデル
  * モデル名: Relationship
  * テーブル名: relationships
  * 生成カラム(カラム名:型): follower_id:integer, followed_id:integer
  * 自動生成カラム(カラム名:型): id:integer, inserted_at:timestamp, updated_at:timestamp
  * インデックス(対象カラム名): follower_id, followed_id, follower_idとfollowed_idでの複合インデックス(ユニーク)

データモデルを把握したところで、早速実装に取り掛かりましょう。  

モデルとマイグレーションファイルの生成をします。  

#### Example:

```cmd
>mix phoenix.gen.model Relationship relationships follower_id:integer followed_id:integer
```

マイグレーションファイルを編集します。  

#### ファイル: priv/repo/[timestamp]_create_relationship.exs

```elixir
defmodule SampleApp.Repo.Migrations.CreateRelationship do
  use Ecto.Migration
  @disable_ddl_transaction true

  def change do
    create table(:relationships) do
      add :follower_id, :integer
      add :followed_id, :integer

      timestamps
    end

    create index(:relationships, [:follower_id], concurrently: true)
    create index(:relationships, [:followed_id], concurrently: true)
    create index(:relationships, [:follower_id, :followed_id], unique: true, concurrently: true)
  end
end
```

複合インデックスでユニークを指定している理由ですが、  
フォローしているのに、再度フォローができたらおかしいですね。  
それを防止するためにユニークを指定しています。  

マイグレーションを実行します。  

#### Example:

```cmd
>mix ecto.migrate
```

## User and Relationship of association
UserモデルとRelationshipモデルの多対多の関連付けを行います。  
この項目は、理解が中々難しいので冗長になっても説明を多めにします。  
大目に見て下さい(笑)  

構築したい関連は以下のような形になります。  

#### Example:

```txt
+----+       +------------+       +----+
|User| 1---n |Relationship| n---1 |User|
+----+       +------------+       +----+
```

テーブルとしてみるとこのような形にしたいわけです。  

```txt
users table
+----+-------+
| id | name  |
+----+-------+
| 1  | user1 |
+----+-------+
| 2  | user2 |
+----+-------+

relationships table
+-------------+-------------+
| followed_id | follower_id |
+-------------+-------------+
| 1           | 2           |
+-------------+-------------+
| 2           | 1           |
+-------------+-------------+
```

user1とuser2が相互フォローしている状態になります。  

まず、自分がフォローしているユーザの関連付けを行います。  
"自分 -> 他ユーザ"を表現するための関連付けです。  

Userモデルのスキーマへ以下を追加する。  

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

    has_many :followed_users, SampleApp.Relationship, foreign_key: :follower_id
    has_many :relationships, through: [:followed_users, :followed_user]

    timestamps
  end

  ...
end
```

今まで使ったことがない、throughと言うオプションが出てきました。  
これは、多対多を構築する時によく使うものです。  

2つのモデルの間に3つ目のモデルを介在させるためのものです。  

今回の場合で言えば、自分は複数のフォローをしている。  
また、自分をフォローしているユーザも複数のフォローを持っている。  
なので、2つのモデルはどちらもUserモデルです。  
そして、3つ目のモデルがRelationshipモデルになります。  

では、3つ目のモデルであるRelationshipモデルでの関連付けをしましょう。  
マイクロポストの関連付けを作成した時と同じですね。  

#### ファイル: web/models/relationship.ex

```elixir
defmodule SampleApp.Relationship do
  ...

  schema "relationships" do
    belongs_to :followed_user, SampleApp.User, foreign_key: :follower_id

    timestamps
  end

  ...
end
```

続いて、自分をフォローしているフォロワーを表現する関連付けを行います。  

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

    has_many :followed_users, SampleApp.Relationship, foreign_key: :follower_id
    has_many :relationships, through: [:followed_users, :followed_user]

    has_many :followers, SampleApp.Relationship, foreign_key: :followed_id
    has_many :reverse_relationships, through: [:followers, :follower]

    timestamps
  end

  ...
end
```

Relationshipモデルにも関連を追加して下さい。  

#### ファイル: web/models/relationship.ex

```elixir
defmodule SampleApp.Relationship do
  ...

  schema "relationships" do
    belongs_to :followed_user, SampleApp.User, foreign_key: :follower_id
    belongs_to :follower, SampleApp.User, foreign_key: :followed_id

    timestamps
  end

  ...
end
```

面白いのは、外部キーを変えているだけだと言うことです。  
これだけで、フォローとフォロワーへの関連付けが実現できています。  

テーブルが反転しているので、少し理解し辛いと思いますが、  
このようにrelationshipsテーブルを反転させるような利用ができています。  

## Validation
Relationshipモデルへ検証を追加します。  

#### ファイル: web/models/relationship.ex

```elixir
defmodule SampleApp.Relationship do
  ...

  schema "relationships" do
    belongs_to :followed_user, SampleApp.User, foreign_key: :follower_id
    belongs_to :follower, SampleApp.User, foreign_key: :followed_id

    timestamps
  end

  @required_fields ~w(follower_id followed_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_presence(:followed_user)
    |> validate_presence(:follower)
  end

  ...
end
```

## Utility Methods
フォローしたり、フォローを解除を補助するための関数を用意します。  

#### ファイル: web/models/relationship.ex

フォローするための関数です。  

```elixir
def follow!(signed_id, follow_user_id) do
  changeset = SampleApp.Relationship.changeset(
    %SampleApp.Relationship{}, %{follower_id: signed_id, followed_id: follow_user_id})

  if changeset.valid? do
    SampleApp.Repo.insert!(changeset)
  end
end
```

フォローしているか確認するための関数です。  

```elixir
def following?(signed_id, follow_user_id) do
  relationship = SampleApp.Repo.all(
    from(r in SampleApp.Relationship,
      where: r.follower_id == ^signed_id and r.followed_id == ^follow_user_id, limit: 1))

  !Enum.empty?(relationship)
end
```

フォローを解除するための関数です。  

```elixir
def unfollow!(signed_id, follow_user_id) do
  [relationship] = SampleApp.Repo.all(
    from(r in SampleApp.Relationship,
      where: r.follower_id == ^signed_id and r.followed_id == ^follow_user_id, limit: 1))

  SampleApp.Repo.delete!(relationship)
end
```

## Following / Followers User List
フォローしているユーザの一覧とフォロワーユーザの一覧を表示できるようにしましょう。  

#### ファイル: web/router.ex

```elixir
scope "/", SampleApp do
  pipe_through :browser # Use the default browser stack

  ...
  get "user/:id/following", UserController, :following
  get "user/:id/followers", UserController, :followers
end
```

ユーザデータの取得時にpreloadを追加します。  

#### ファイル: web/controllers/user_controller.ex

```elixir
def show(conn, params) do
    ...
    user = Repo.get(SampleApp.User, id) |> Repo.preload(:relationships) |> Repo.preload(:reverse_relationships)
    ...
end
```

フォロー数、フォロワー数を表示します。  
また、一覧へのリンクとします。  

#### ファイル: web/templates/user/show.html.eex

```html
<h2>User profile</h2>

<div class="row">
  <aside class="col-md-4">
    <section>
      <%= render SampleApp.SharedView, "user_info.html", conn: @conn, user: @user %>
    </section>
    <section>
      <%= render SampleApp.SharedView, "stats.html", conn: @conn, user: @user %>
    </section>
    <%= if current_user?(@conn, @user) do %>
      <section>
        <%= link "Edit", to: user_path(@conn, :edit, @user), class: "btn btn-default btn-xs" %>
        <%= link "Delete", to: user_path(@conn, :delete, @user), method: :delete, class: "btn btn-danger btn-xs" %>
      </section>
    <% end %>
    <section>
      <%= render "micropost_form.html", conn: @conn, changeset: @changeset, user: @user %>
    </section>
  </aside>

  ...

</div>
```

フォロー、フォロワー数の表示とリンクは別テンプレートへ分けます。  

#### ファイル: web/templates/shared/stats.html.eex

```html
<div class="stats">
  <a href="<%= user_path(@conn, :following, @user) %>">
    <strong id="following" class="stat">
      (<%= Enum.count(@user.followed_users) %>)
    </strong>
    following
  </a>
  <a href="<%= user_path(@conn, :followers, @user) %>">
    <strong id="followers" class="stat">
      (<%= Enum.count(@user.followers) %>)
    </strong>
    followers
  </a>
</div>
```

CSSの追加を行います。  

#### ファイル: priv/static/css/custom.css

```elixir
.stats {
  overflow: auto;
}

.stats a {
  float: left;
  padding: 0 10px;
  border-left: 1px solid #eeeeee;
  color: gray;
}

.stats a:first-child {
  padding-left: 0;
  border: 0;
}

.stats a:hover {
  text-decoration: none;
  color: #3677a3;
}

.stats strong {
  display: block;
}
```

followingとfollowersのアクション関数を作成します。  

#### ファイル: web/controllers/user_controller.ex

認可へアクションを追加します。  

```elixir
plug SampleApp.Plugs.SignedInUser when action in [:index, :show, :edit, :update, :delete, :following, :followers]
```

フォロー一覧を表示するため、followingアクションを実装します。  

```elixir
def following(conn, params) do
  select_page = params["select_page"]
  id = params["id"]

  user = Repo.get(SampleApp.User, id) |> Repo.preload(:relationships) |> Repo.preload(:reverse_relationships)
  page = SampleApp.User.show_follow_paginate(
    select_page, list_map_to_value_list(user.followed_users, :followed_id))

  if page do
    render(conn, "following.html",
           user: user,
           users: page.entries,
           current_page: page.page_number,
           total_pages: page.total_pages,
           page_list: Range.new(1, page.total_pages))
  else
    conn
    |> put_flash(:error, "Invalid page number!!")
    |> render("following.html", user: user, users: [])
  end
end
```

フォロワー一覧を表示するため、followersアクションを実装します。  

```elixir
def followers(conn, params) do
  select_page = params["select_page"]
  id = params["id"]

  user = Repo.get(SampleApp.User, id) |> Repo.preload(:relationships) |> Repo.preload(:reverse_relationships)
  page = SampleApp.User.show_follow_paginate(
    select_page, list_map_to_value_list(user.followers, :follower_id))

  if page do
    render(conn, "followers.html",
           user: user,
           users: page.entries,
           current_page: page.page_number,
           total_pages: page.total_pages,
           page_list: Range.new(1, page.total_pages))
  else
    conn
    |> put_flash(:error, "Invalid page number!!")
    |> render("followers.html", user: user, users: [])
  end
end
```

取得したいユーザのID一覧をリスト化しています。  

```elixir
defp list_map_to_value_list(repo_result, key) do
  for map <- repo_result do Map.get(map, key) end
end
```

フォロー、フォロワーのユーザ一覧をページネーションするための関数を追加します。  

#### ファイル: web/models/user.ex

```elixir
def show_follow_paginate(select_page, ids_list) do
  SampleApp.Helpers.PaginationHelper.paginate(
    from(u in SampleApp.User, where: u.id in ^ids_list, order_by: [asc: :name]),
    select_page)
end
```

フォロー一覧を表示するためのテンプレートを作成します。  

#### ファイル: web/templates/user/following.html.eex

```html
<h2>Followed users</h2>

<%= render "show_follow.html", action: user_path(@conn, :following, @user), conn: @conn,
                        user: @user,
                        users: @users,
                        current_page: @current_page,
                        total_pages: @total_pages,
                        page_list: @page_list %>
```

フォロワー一覧を表示するためのテンプレートを作成します。  

#### ファイル: web/templates/user/followers.html.eex

```html
<h2>Follower users</h2>

<%= render "show_follow.html", action: user_path(@conn, :followers, @user), conn: @conn,
                        user: @user,
                        users: @users,
                        current_page: @current_page,
                        total_pages: @total_pages,
                        page_list: @page_list %>
```

フォロー、フォロワー一覧を表示するための共通テンプレートを作成します。  

#### ファイル: web/templates/user/show_follow.html.eex

```html
<div class="row">
  <aside class="col-md-4">
    <section>
      <%= render SampleApp.SharedView, "user_info.html", conn: @conn, user: @user %>
    </section>
    <section>
      <%= render SampleApp.SharedView, "stats.html", conn: @conn, user: @user %>
      <%= if @users do %>
        <div class="user_avatars">
          <%= for follow_user <- @users do %>
            <a href="<%= user_path(@conn, :show, follow_user) %>">
              <img src="<%= get_gravatar_url(follow_user) %>" class="gravatar">
            </a>
          <% end %>
        </div>
      <% end %>
    </section>
  </aside>
  
  <div class="col-md-8">
    <h3>Users</h3>
    <%= if @users do %>
      <ul class="users">
        <%= for follow_user <- @users do %>
          <%= render "user.html", conn: @conn, user: follow_user %>
        <% end %>
      </ul>

      <%= render SampleApp.PaginationView, "pagination.html",
               action: @action,
               current_page: @current_page,
               page_list: @page_list,
               total_pages: @total_pages %>
    <% end %>
  </div>
</div>
```

## Follow / Unfollow Button
フォローとアンフォローのボタンを表示させます。  

#### ファイル: web/templates/user/show.html.eex

```html
<h2>User profile</h2>

<div class="row">
  ...
  
  <div class="col-md-8">
    <%= render "follow_form.html", conn: @conn, user: @user %>

    ...
    <% end %>
  </div>
</div>
```

フォローボタンを表示するためのテンプレートを作成します。  

#### ファイル: web/templates/user/follow_form.html.eex

```html
<%= unless current_user?(@conn, @user) do %>
  <div id="follow_form">
  <%= if following?(@conn, @user.id) do %>
    <%= form_tag(relationship_path(@conn, :delete, current_user(@conn)), method: :delete) %>
      <input type="hidden" name="unfollow_id" value="<%= @user.id %>">
      <%= submit "Unfollow", class: "btn btn-default" %>
    </form>
  <% else %>
    <%= form_tag(relationship_path(@conn, :create), method: :post) %>
      <input type="hidden" name="id" value="<%= current_user(@conn).id %>">
      <input type="hidden" name="follow_id" value="<%= @user.id %>">
      <%= submit "Follow", class: "btn btn-primary" %>
    </form>
  <% end %>
  </div>
<% end %>
```

Userビューへフォローしているか確認するための関数を追加します。  

#### ファイル: web/views/user_view.ex

```elixir
defmodule SampleApp.UserView do
  ...

  def following?(conn, follow_user_id) do
    SampleApp.Relationship.following?(conn.assigns[:current_user].id, follow_user_id)
  end
end
```

ビューを補助するモジュールにサインインしているユーザと表示しているユーザが、  
同一か確認する関数を追加しています。  

#### ファイル: lib/helpers/view_helper.ex

```elixir
defmodule SampleApp.Helpers.ViewHelper do
  ...

  def current_user?(conn, %SampleApp.User{id: id}) do
    user = SampleApp.Repo.get(SampleApp.User, id)
    conn.assigns[:current_user] == user
  end
end
```

## Relationship Controller
フォローする、フォロー解除を画面から行えるようにします。  

ルーティングを追加します。  

#### ファイル: web/router.ex

```elixir
scope "/", SampleApp do
  pipe_through :browser # Use the default browser stack

  ...
  resources "/relationship", RelationshipController, only: [:create, :delete]
end
```

Relationshipコントローラの作成をします。  

#### ファイル: web/controllers/relationship_controller.ex

```elixir
defmodule SampleApp.RelationshipController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug SampleApp.Plugs.SignedInUser

  def create(conn, params) do
    SampleApp.Relationship.follow!(params["id"], params["follow_id"])

    conn
    |> put_flash(:info, "Follow successfully!!")
    |> redirect(to: user_path(conn, :show, params["follow_id"]))
  end

  def delete(conn, params) do
    SampleApp.Relationship.unfollow!(params["id"], params["unfollow_id"])

    conn
    |> put_flash(:info, "Unfollow successfully!!")
    |> redirect(to: user_path(conn, :show, params["unfollow_id"]))
  end
end
```

## Following user microposts
フォローしているユーザのマイクロポストをユーザのマイクロポスト一覧に表示させます。  

Micropostモデルにページネーション関数を追加します。  

#### ファイル: web/models/micropost.ex

```elixir
def paginate(user_id, select_page, following_ids) do
  SampleApp.Helpers.PaginationHelper.paginate(
    from(m in SampleApp.Micropost,
      where: m.user_id in ^following_ids or m.user_id == ^user_id,
        order_by: [desc: m.inserted_at]),
    select_page)
end
```

Userコントローラのshowアクションで、
Micropostモデルのページネーション関数を利用するように修正します。  

#### ファイル: web/controllers/user_controller.ex

```elixir
def show(conn, params) do
  select_page = params["select_page"]
  id = params["id"]

  user = Repo.get(SampleApp.User, id) |> Repo.preload(:relationships) |> Repo.preload(:reverse_relationships)
  page = SampleApp.Micropost.paginate(
    user.id, select_page, list_map_to_value_list(user.followed_users, :followed_id))
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

完成！！

## Before the end
ソースコードをマージします。  

```cmd
>git add .
>git commit -am "Finish following_users."
>git checkout master
>git merge following_users
```

# Speaking to oneself
祝！チュートリアル終了！！  
ここまでお付き合い頂きありがとうございました。  

喜びに水を差すようで申し訳ないのですが、  
このチュートリアルでやった内容は全て基礎です。  

なので、応用的を習得するために今後の努力を怠らないようにして下さい。  
それでは、お疲れ様でした。m(\_ \_)m  

# Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/following-users?version=4.0#top)  
[hexdocs - v0.14.3 Ecto.Schema.has_many/3 :through](http://hexdocs.pm/ecto/Ecto.Schema.html#has_many/3)  
[Qiita - Elixir Phoenixのデータベース操作モジュールEcto入門 多対多](http://qiita.com/yoavlt/items/ffbda1f0397839c5db99#%E5%A4%9A%E5%AF%BE%E5%A4%9A)  
[PartyIX - has_many throughで，class_nameとかforeign_keyをちゃんと復習してみる](http://h3poteto.hatenablog.com/entry/2014/06/15/231742)  
[hexdocs - v0.14.3 Ecto.Migration.index/3](http://hexdocs.pm/ecto/0.14.3/Ecto.Migration.html#index/3)  
[hexdocs - v0.15.0 Ecto.Query](http://hexdocs.pm/ecto/Ecto.Query.html)  
[hexdocs - v0.15.0 Ecto.Query.API left in right](http://hexdocs.pm/ecto/Ecto.Query.API.html#in/2)  
[hexdocs - v2.1.0 Phoenix.HTML](https://hexdocs.pm/phoenix_html/)  