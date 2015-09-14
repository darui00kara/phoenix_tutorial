#Goal
ユーザのモデルを実装する。  

#Wait a minute
ユーザのモデルを実装します。  

#Index
Modeling users  
|> Preparation  
|> User data model  
|> Verify  
|> Add password colum  
|> Encrypted password
|> Additional verification  
|> User authentication  

##Preparation  
ブランチを切ります。  

```cmd
>cd path/to/sample_app
>git checkout -b modeling_users
```

ライブラリの準備をします。  
利用するライブラリは以下のものになります。  
Github: [safetybox](https://github.com/aforward/safetybox)  

```elixir
defmodule SampleApp.Mixfile do
  ...
  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [...
     {:safetybox, "~> 0.1"}]
  end
end
```

依存関係の解決を行います。  

```cmd
>mix deps.get
```

##User data model
ユーザのデータモデルの提示と実装を行います。  

ユーザの最初のデータモデルは以下のようになります。  

- ユーザのデータモデル
  * モデル名: User
  * テーブル名: users
  * 生成カラム(カラム名:型): name:string, email:string
  * 自動生成カラム(カラム名:型): id:integer, inserted_at:timestamp, updated_at:timestamp

データモデルを把握したところで、モデルの作成に移りたいと思います。  
今回、利用しているコマンドは、"mix phoenix.gen.html"ではありません。  

"mix phoenix.gen.model"と言うコマンドを使います。  
生成したファイルの一覧を見ればどういった、コマンドなのか分かると思います。  

```cmd
>mix phoenix.gen.model User users name:string email:string
Generated sample_app app
* creating priv/repo/migrations/[timestamp]_create_user.exs
* creating web/models/user.ex
* creating test/models/user_test.exs
```

####Description
以下の三つのファイルが生成されていますね。  

- [timestamp]_create_user.exs
- user.ex
- user_test.exs

"mix phoenix.gen.model"コマンドは、  
(上から)マイグレーションファイル、モデルファイル、モデルのテストファイルを生成します。  

コントローラなどが不要の場合に利用すると良いかと思います。  

####ファイル: priv/repo/[timestamp]_create_user.exs
マイグレーションファイルを開き、インデックスの作成を追加します。

```elixir
defmodule SampleApp.Repo.Migrations.CreateUser do
  use Ecto.Migration
  @disable_ddl_transaction true

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string

      timestamps
    end

    create index(:users, [:name], unique: true, concurrently: true)
    create index(:users, [:email], unique: true, concurrently: true)
  end
end
```

それでは、マイグレーションを実行します。  

```cmd
>mix ecto.migrate
```

マイグレーションまで終わったら、必要なファイルを作成していきます。  

####ファイル: web/router.ex
サインアップするためのルーティングを追加します。  

```elixir
scope "/", SampleApp do
  pipe_through :browser # Use the default browser stack

  ...
  get "/signup", UserController, :new
end
```

####ファイル: web/controllers/user_controller.ex
ユーザのコントローラを作成します。  

```elixir
defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end
end
```

####ファイル: web/views/user_view.ex
続いて、ユーザのビューを作成します。  

```elixir
defmodule SampleApp.UserView do
  use SampleApp.Web, :view
end
```

ユーザのテンプレートと格納用のディレクトリを作成します。  

####ディレクトリ: web/templates/user
userと言うディレクトリを作成して下さい。  

####ファイル: web/templates/user/new.html.eex
テンプレートファイルを作成します。  

```elixir
<div class="jumbotron">
  <h1>Sign up</h1>
  <p>Find me in web/templates/user/new.html.eex</p>
</div>
```

####ファイル: web/templates/static_pages/home.html.eex
最後に、リンクを作成します。  

```html
<div class="jumbotron">
  <h1>Welcom to the Sample App</h1>

  <h2>
    This application is
    <a href="http://railstutorial.jp/">Ruby on Rails Tutorial</a>
    for Phoenix sample application.
  </h2>

  <a href="<%= user_path(@conn, :new) %>" class="btn btn-large btn-primary">Sign up now!</a>
</div>
```

これでユーザのモデルが実装できました。  

今回、"mix phoenix.gen.html"を利用しなかったのは、理由があります。  
確かにコマンドを使えば楽なのですが、一から手を動かしていかなければ覚えられないためです。  

少し手間でしょうが、一から学んで行きましょう！！  

##Verify
モデルのデータをDBに格納する前には、検証が付き物ですね。  
検証を追加していきます。  

今あるカラムは、nameとemailですね。  
さて、必要な検証は何でしょうか？  

簡単にまとめてみました。  

- nameの検証内容
  * 存在性
  * 一意性
  * 文字数

- emailの検証内容
  * 存在性
  * 一意性
  * フォーマット

とりあえずは、こんなところでしょう。  
さて、検証項目が分かったところで実装していきましょう。  

####ファイル: web/models/user.ex
検証関数を追加します。  

```elixir
def changeset(model, params \\ :empty) do
  model
  |> cast(params, @required_fields, @optional_fields)
  |> validate_format(:email, ~r/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
  |> unique_constraint(:name)
  |> unique_constraint(:email)
  |> validate_length(:name, min: 1)
  |> validate_length(:name, max: 50)
end
```

存在性を検証してくれる関数が存在しないため、自分で作ります。  
存在性が存在しないとはこれいかに(笑)  

####ファイル: lib/helpers/validate_helper.ex
lib配下に存在性の検証を行う、自作の検証用モジュールを作成します。  

```elixir
defmodule SampleApp.Helpers.ValidateHelper do
  def validate_presence(changeset, field_name) do
    field_data = Ecto.Changeset.get_field(changeset, field_name)

    cond do
      field_data == nil ->
        Ecto.Changeset.add_error changeset, field_name, "#{field_name} is nil"
      field_data == "" ->
        Ecto.Changeset.add_error changeset, field_name, "No #{field_name}"
      true ->
        changeset
    end
  end
end
```

####ファイル: web/models/user.ex
先ほど作成した、存在性の検証を追加します。  

```elixir
def changeset(model, params \\ :empty) do
  model
  |> cast(params, @required_fields, @optional_fields)
  |> validate_presence(:name)
  |> validate_presence(:email)
  ...
end
```

##Add password colum
パスワードのカラムを、ユーザのデータモデルに追加します。  

本来であれば、一度のマイグレーションで行えば良いのですが、  
再マイグレーションする練習として丁度良いので、パスワードは別で追加しています。  

- 追加のデータモデル
  * 対象モデル名: User
  * 対象テーブル名: users
  * 追加カラム(カラム名:型(オプション)): password:string(virtual)、password_digest:string

####Description
virtual属性とは・・・フィールドが正しいとき、データベースまで持続させない属性です。  

ユーザ入力とデータ検証は生の文字列のまま行いたいですが、  
DBへ格納するデータとしては暗号化されていて欲しいわけです。  
そうなると、passwordカラムは生の文字列のままなので、DBまで持続させたくないのです。  

passwordカラムで入力と検証を行った後、正しければ暗号化してpassword_digestへ入れると言うことですね。  
そして、passwordカラムの値はDBまで持続しないと言ったことができる。  
そういった場合に役に立つのが、virtual属性と言うものです。  

- password: 生の文字列
- password_digest: 暗号化した文字列

それでは、パスワードカラムの追加を行います。  

```cmd
>mix ecto.gen.migration add_password_to_users
```

####Description
"mix ecto.gen.migration"コマンドを使えば、  
マイグレーションファイルだけ生成できます。  

####ファイル: priv/repo/[timestamp]_add_password_to_users.exs
マイグレーションファイルを以下のように編集します。  

```elixir
defmodule SampleApp.Repo.Migrations.AddPasswordToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password, :string
      add :password_digest, :string
    end
  end
end
```

マイグレーションを実行します。  

```cmd
>mix ecto.migrate
```

####ファイル: web/models/user.ex
ユーザモデルのスキーマへパスワードのフィールドを追加して下さい。  
また、required_fieldsにも追加して下さい。  
(virtual属性は、ここで付加します)  

```elixir
schema "users" do
  field :name, :string
  field :email, :string
  field :password_digest, :string
  field :password, :string, virtual: true

  timestamps
end

@required_fields ~w(name email password)
@optional_fields ~w()
```

##Encrypted password
パスワードを暗号化します。

暗号化を扱うためのモジュールを作成します。

####ファイル: lib/encryption.ex

```elixir
defmodule SampleApp.Encryption do
  def decrypt(password) do
    Safetybox.decrypt(password)
  end

  def encrypt(password) do
    Safetybox.encrypt(password, :default)
  end
end
```

入力、検証後のパスワードを暗号化して、
password_digestで使うにはコールバック関数を利用します。

####ファイル: web/models/user.ex
以下のように、Callbacksのuseとbefore_insertを追加して下さい。

```elixr
defmodule SampleApp.User do
  use SampleApp.Web, :model
  use Ecto.Model.Callbacks

  before_insert :set_password_digest

  ...
```

関数を追加します。

```elixir
def set_password_digest(changeset) do
  password = Ecto.Changeset.get_field(changeset, :password)
  change(changeset, %{password_digest: SampleApp.Encryption.encrypt(password)})
end
```

####Description
before_insertで指定した名前と同じ関数名ですね。

コールバックには関数名を指定します。
その関数名で実装すれば動作の前後に動いてくれます。

今回利用している、before_insertは、DBへの挿入処理の前に実行するものです。
他にも色々なコールバックがありますので、用途に応じて使い分けができます。

##Additional verification
パスワードにも検証が必要ですね。  
検証の追加を行います。  

- passwordの検証内容
  * 存在性
  * 文字数

####ファイル: web/models/user.ex
以下のように検証を追加して下さい。  

```elixir
def changeset(model, params \\ :empty) do
  model
  |> cast(params, @required_fields, @optional_fields)
  ...
  |> validate_presence(:password)
  |> validate_length(:password, min: 8)
  |> validate_length(:password, max: 100)
end
```

#Speaking to oneself
ユーザのモデルが実装できました。
次は、このモデルを使ってユーザの登録を実装します。

#Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/modeling-users?version=4.0#top)  
[hexdoxs - Ecto.Changeset](http://hexdocs.pm/ecto/Ecto.Changeset.html#content)  
[hexdoxs - Ecto.Model.Callbacks](http://hexdocs.pm/ecto/Ecto.Model.Callbacks.html#content)  