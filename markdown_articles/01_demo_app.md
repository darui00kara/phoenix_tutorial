#Goal
デモアプリを作成する。

#Dev-Environment
OS: Windows8.1

Erlang: Eshell V6.4, OTP-Version 17.5

Elixir: v1.0.4

Phoenix Framework: v0.13.1

PostgreSQL: postgres (PostgreSQL) 9.4.4

Safetybox: v0.1.2

Scrivener: v0.11.0

#Wait a minute
最初の事始めとして、デモアプリの作成を行います。

作成するデモアプリは、
ユーザと(短い)マイクロポストのみをサポートするマイクロブログです。

ほとんどを自動生成コマンドで行いますので、
Phoenix-Frameworkを体験してみる程度の心構えで結構です。

大丈夫です。
詳しいことは、後の章で説明していきます。

Phoenix-Frameworkを使ってみることに集中しましょう！！

#Index
Let's play a phoenix!
|> Preparation
|> Data model
|> Create users resource
|> Create microposts resource
|> Associate with has_many

##Preparation
早速、不死鳥と遊ぼうと思いますが・・・少し水を差します。

Phoenixを動かす前にプロジェクトが必要ですね。
プロジェクトの作成を行います。

Phoenix-Frameworkのインストールで
新規にプロジェクトを作成するためのコマンドが既にmixにあります。

以下のコマンドで作成することができます。

```cmd
>mix phoenix.new project_name
```

では、実際に作成してみましょう。

```cmd
>cd path/to/workspace
>mix phoenix.new demo_app
```

ディレクトリを確認すると、
demo_appが作成されていますね。

次は、サーバを起動してみましょう。

```cmd
>cd demo_app
>mix phoenix.server
```

####Description:
Ctrl+Cでサーバを終了できます。

####Caution:
最新バージョン(v0.17.0)では、以下のような形になります。

```cmd
>cd demo_app
>mix ecto.create
>mix phoenix.server
```

以下のアドレスへアクセスして下さい。

####アドレス: http://localhost:4000
Phoenixのページが表示されましたね。

ようこそ！Phoenix-Frameworkへ！！

##Data model
早くプログラムをしたいですね！
しかし、プログラムに取り掛かる前にやることがあります。

データモデルの把握です。

余り楽しい内容ではないですが、時間は掛けません。
今回作成するデータモデルについて把握しましょう。

- ユーザのデータモデル
  * モデル名: User
  * テーブル名: users
  * 生成カラム(カラム名:型): name:string, email:string
  * 自動生成カラム(カラム名:型): id:integer, inserted_at:timestamp, updated_at:timestamp

このユーザモデルとWebインターフェース(データモデルをWebで取り扱えるようにしたもの)を
合わせたものをユーザリソースと呼びます。

今回は、もう一つデータモデルが存在します。

- マイクロポストのデータモデル
  * モデル名: Micropost
  * テーブル名: microposts
  * 生成カラム(カラム名:型): content:string, user_id:integer
  * 自動生成カラム(カラム名:型): id:integer, inserted_at:timestamp, updated_at:timestamp

さて、同じ項目(自動生成カラム)がありますね。
これは、自動生成されるカラムになります。

詳しいことは、別の章にて説明する機会があります。
それまで、期待を膨らませて待っていて下さい。

##Create users resource
いよいよ、コードを作成していきます！

Phoenix-Frameworkには、幾つかコマンド(カスタムタスク)があります。
確認してみましょう。

プロジェクトのディレクトリで以下のように実行して下さい。

```cmd
>mix help | grep phoenix
mix phoenix.digest      # Digests and compress static files
mix phoenix.gen.channel # Generates a Phoenix channel
mix phoenix.gen.html    # Generates controller, model and views for an HTML-based resource
mix phoenix.gen.json    # Generates a controller and model for an JSON-based resource
mix phoenix.gen.model   # Generates an Ecto model
mix phoenix.new         # Create a new Phoenix v0.17.0 application
mix phoenix.routes      # Prints all routes
mix phoenix.server      # Starts applications and their servers
```

####Caution:
phoenix.newのバージョンに差異がありますが見逃して下さい！！

詳しい説明は、Phoenix-Frameworkを使っていく過程で説明するとして、
何はともあれ使ってみましょう。

今回使うのは、以下のコマンドです。

```cmd
mix phoenix.gen.html    # Generates controller, model and views for an HTML-based resource
```

このコマンドは、
コントローラ、モデル、ビュー、テンプレートを一気に生成してくれる非常に便利なコマンドです。

まずは、ユーザから作成していきます。
プロジェクトのディレクトリで以下のように実行して下さい。

```cmd
>mix phoenix.gen.html User users name:string email:string
* creating priv/repo/migrations/20150620043753_create_user.exs
* creating web/models/user.ex
* creating test/models/user_test.exs
* creating web/controllers/user_controller.ex
* creating web/templates/user/edit.html.eex
* creating web/templates/user/form.html.eex
* creating web/templates/user/index.html.eex
* creating web/templates/user/new.html.eex
* creating web/templates/user/show.html.eex
* creating web/views/user_view.ex
* creating test/controllers/user_controller_test.exs

Add the resource to the proper scope in web/router.ex:

    resources "/users", UserController

and then update your repository by running migrations:

    $ mix ecto.migrate

```

色々と生成されましたね。

生成した後にやることがあります。
ルーティングの追加とマイグレーションの実行です。

まずはルーティングの追加から実施します。

####ファイル: web/router.ex
コメントにAdditional linesと書いてある行を追加して下さい。

```elixir
scope "/", DemoApp do
  pipe_through :browser # Use the default browser stack

  get "/", PageController, :index
  resources "/users", UserController # Additional lines
end
```

ルーティングが追加されたか確認してみましょう。

```cmd
>mix phoenix.routes
page_path  GET     /                DemoApp.PageController.index/2
user_path  GET     /users           DemoApp.UserController.index/2
user_path  GET     /users/:id/edit  DemoApp.UserController.edit/2
user_path  GET     /users/new       DemoApp.UserController.new/2
user_path  GET     /users/:id       DemoApp.UserController.show/2
user_path  POST    /users           DemoApp.UserController.create/2
user_path  PATCH   /users/:id       DemoApp.UserController.update/2
           PUT     /users/:id       DemoApp.UserController.update/2
user_path  DELETE  /users/:id       DemoApp.UserController.delete/2
```

####Description:
resourcesを使ってルーティングを作成すると、
RESTfulなルーティングを作成してくれます。

次は、マイグレーションを実行します。
マイグレーションに使うコマンドは、また別のものになります。
Phoenix-FrameworkではEctoと呼ばれるライブラリを使っています。

DBとの接続を楽にしてくれる素晴らしいライブラリです。
(RailsにおけるActive Recordのような存在です)

Ectoのコマンドを見てみます。

```cmd
>mix help | grep ecto
mix ecto.create         # Create the storage for the repo
mix ecto.drop           # Drop the storage for the repo
mix ecto.gen.migration  # Generate a new migration for the repo
mix ecto.gen.repo       # Generate a new repository
mix ecto.migrate        # Run migrations up on a repo
mix ecto.rollback       # Rollback migrations from a repo
```

以下のコマンドを使ってマイグレーションを実行します。

```cmd
mix ecto.migrate        # Run migrations up on a repo
```

実際にやっていきましょう。

```cmd
>mix ecto.migrate
** (exit) exited in: GenServer.call(#PID<0.168.0>, {:query, "SELECT count(1) FROM pg_class c\n  JOIN pg_namespace n ON n.oid = c.relnamespace\n WHERE c.relkind IN ('r','v','m')\n
     AND c.relname = 'schema_migrations'\n       AND n.nspname = ANY (current_schemas(false))\n", []}, :infinity)
    ** (EXIT) %Postgrex.Error{message: nil, postgres: %{code: :invalid_catalog_name, file: "src\\backend\\utils\\init\\postinit.c", line: "794", message: <<131, 102, 129, 91, 131,
94, 131, 120, 129, 91, 131, 88, 34, 100, 101, 109, 111, 95, 97, 112, 112, 95, 100, 101, 118, 34, 130, 205, 145, 182, 141, 221, 130, 181, 130, 220, 130, 185, 130, 241>>, pg_code: "3
D000", routine: "InitPostgres", severity: "FATAL"}}
    (elixir) lib/gen_server.ex:356: GenServer.call/3
    (postgrex) lib/postgrex/connection.ex:87: Postgrex.Connection.query/4
    (ecto) lib/ecto/adapters/postgres/connection.ex:37: Ecto.Adapters.Postgres.Connection.query/4
    (stdlib) timer.erl:194: :timer.tc/3
    (ecto) lib/ecto/adapters/sql.ex:191: anonymous fn/6 in Ecto.Adapters.SQL.pool_query!/5
    (ecto) lib/ecto/adapters/sql.ex:615: Ecto.Adapters.SQL.pool_transaction/4
    (ecto) lib/ecto/adapters/sql.ex:189: Ecto.Adapters.SQL.pool_query!/5
    (ecto) lib/ecto/adapters/postgres.ex:59: Ecto.Adapters.Postgres.ddl_exists?/3
```

わぁお！何かエラーが出てしまいましたね。

マイグレーションするには、そのマイグレーション先がないといけませんね。
まだ、作っていませんでした。(失敬、失敬///)

作成するには以下のコマンドを使います。

```cmd
>mix ecto.create
The database for DemoApp.Repo has been created.
```

####Caution:
最新バージョン(v0.17.0)を使っている方は、
最初に作成しているので上記の操作は不要です。

再度、マイグレーションを実行します。

```cmd
>mix ecto.migrate
[info] == Running DemoApp.Repo.Migrations.CreateUser.change/0 forward
[info] create table users
[info] == Migrated in 0.2s
```

今度は無事マイグレーションできました。

ここまで、実施できたら一度サーバを起動して確認してみましょう。

まだ、何もプログラムしていない？
大丈夫です！先ほどの操作で既にユーザの画面が出来上がっています！！

```cmd
>mix phoenix.server
```

以下のアドレスにアクセスして下さい。

####アドレス: http://localhost:4000/users

ユーザの一覧ページが表示されましたね。

この時点で、ユーザの作成 / 表示 / 更新 / 削除が実装されています。
気になる方は、画面から操作してみて下さい。

各画面における、URLの例は以下のようになります。

- index
例) http://localhost:4000/users
ユーザ一覧を表示するページ。

- new
例) http://localhost:4000/users/new
新規のユーザ登録を行うページ。

- show
例) http://localhost:4000/users/1 
ユーザ個別のプロファイルを表示するページ。
(URL中の数値1はid属性)

- edit
例) http://localhost:4000/users/1/edit
ユーザ情報の更新を行うページ。

Description:
create、update、deleteはメソッドが異なるので割愛します。

##Create microposts resource
続いて、マイクロポストリソースを作成します。

ユーザリソースを作成した時と手順は、
ほぼ同一なので必要な部分のみ記述します。

まずは、自動生成コマンドを使って一通りのものを生成します。

```cmd
>mix phoenix.gen.html Micropost microposts content:string user_id:integer
* creating priv/repo/migrations/20150620055222_create_micropost.exs
* creating web/models/micropost.ex
* creating test/models/micropost_test.exs
* creating web/controllers/micropost_controller.ex
* creating web/templates/micropost/edit.html.eex
* creating web/templates/micropost/form.html.eex
* creating web/templates/micropost/index.html.eex
* creating web/templates/micropost/new.html.eex
* creating web/templates/micropost/show.html.eex
* creating web/views/micropost_view.ex
* creating test/controllers/micropost_controller_test.exs

Add the resource to the proper scope in web/router.ex:

    resources "/microposts", MicropostController

and then update your repository by running migrations:

    $ mix ecto.migrate

```

ルーティングの追加をします。

####ファイル: web/router.ex
コメントにAdditional linesと書いてある行を追加して下さい。

```elixir
scope "/", DemoApp do
  pipe_through :browser # Use the default browser stack

  get "/", PageController, :index
  resources "/users", UserController
  resources "/microposts", MicropostController # Additional lines
end
```

ルーティングが追加されたか確認する。

他のルーティングも表示されます。
下記の結果では、マイクロポストのみ表示しています。

```cmd
>mix phoenix.routes
...
micropost_path  GET     /microposts           DemoApp.MicropostController.index/2
micropost_path  GET     /microposts/:id/edit  DemoApp.MicropostController.edit/2
micropost_path  GET     /microposts/new       DemoApp.MicropostController.new/2
micropost_path  GET     /microposts/:id       DemoApp.MicropostController.show/2
micropost_path  POST    /microposts           DemoApp.MicropostController.create/2
micropost_path  PATCH   /microposts/:id       DemoApp.MicropostController.update/2
                PUT     /microposts/:id       DemoApp.MicropostController.update/2
micropost_path  DELETE  /microposts/:id       DemoApp.MicropostController.delete/2
```

マイグレーションを実行します。

```cmd
>mix ecto.migrate
[info] == Running DemoApp.Repo.Migrations.CreateMicropost.change/0 forward
[info] create table microposts
[info] == Migrated in 0.1s
```

サーバを起動して、マイクロポストのページを確認にいきます。

```cmd
>mix phoenix.server
```

####アドレス: http://localhost:4000/microposts


折角だから、俺はプログラミングをするぜ！！
そろそろプログラムをしたいので、少しだけソースコードを追加します。

####ファイル: web/models/micropost.ex
changeset/2の関数がありますね。
内容を以下のように編集して下さい。
(Additional linesの部分)

```elixir
def changeset(model, params \\ :empty) do
  model
  |> cast(params, @required_fields, @optional_fields)
  |> validate_length(:content, min: 140) # Additional lines
end
```

何をやったのか？
マイクロポストの投稿において、140文字の制限を加えました。

試しにマイクロポストの作成 / 更新の画面から140文字以上を入力してみて下さい。
画面にエラーを表示してくれるはずです。

##Associate with has_many
もう少しソースコードをいじってみましょう！

ユーザとマイクロポストに関連付けを行ってみます。

####ファイル: web/models/user.ex
schemaの部分を以下のように編集して下さい。

```elixir
schema "users" do
  field :name, :string
  field :email, :string
  has_many :microposts, DemoApp.Micropost

  timestamps
end
```

####ファイル: web/models/micropost.ex
schemaの部分を以下のように編集して下さい。

```elixir
schema "microposts" do
  field :content, :string
  belongs_to :user, DemoApp.User, foreign_key: :user_id

  timestamps
end
```

関連付けができました。
現状では、これで関連付けができると言う認識で大丈夫です。

1対多、多対多の関係性は後の章で出てきます。
なので詳しい説明をここではしません。

#Speaking to oneself
お疲れ様でした。今回はここまでになります。

Phoenix-Frameworkの事始めとしてはどうでしたでしょうか？

Railsを使ったことがある方々は、
どこかで見たことがあるような内容だったと思います。

初めてフレームワーク触れた方々は、
分からない部分はあれど、あまり難しく感じなかったのではないでしょうか？

今回作成したアプリケーションを
もっと本格的に実装していくのがTutorialの内容になります。

最後までお付き合い頂ければ幸いです。

#Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/a-demo-app?version=4.0#top)
[Phoenix Framework - Guides - Mix Tasks](http://www.phoenixframework.org/v0.13.1/docs/mix-tasks)
[Phoenix Framework - Guides - Ecto Models](http://www.phoenixframework.org/v0.13.1/docs/ecto-models)