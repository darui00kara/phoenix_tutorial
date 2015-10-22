# Goal
ユーザのモデルを実装する。  

# Wait a minute
ユーザのモデルを実装していきます。  

今回から、必要がない限りはサーバ起動を促すことはしません。  
適宜実行してみて下さい。  

実行できなくても、この段階では実行できない、何かが間違っているなど、  
得る情報があると思います。  

そういった勘を養うためにも、ご自分で実行のタイミングを取って下さい。  

ちょっとしたアドバイスです。  
おそらく、大体の方が分かっていると思いますが、  
なるべく小さく実行していった方が良いですね。  

作成 --> 実行 --> 修正 --> 実行...といったように、  
少しずつ小さく実行を繰り返していくことが、大量のエラーに悩まされない方法です。  

# Index
Modeling users  
|> Preparation  
|> User data model  
|> User  
|> Verify  
|> Add password colum  
|> Encrypted password  
|> Additional verification  
|> Before the end  

## Preparation
ブランチを切ります。  

#### Example:

```cmd
>cd path/to/sample_app
>git checkout -b modeling_users
```

ライブラリの準備をします。  
利用するライブラリは以下のものになります。  
#### Github: [safetybox](https://github.com/aforward/safetybox)  

#### File: mix.exs

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

#### Example:

```cmd
>mix deps.get
```

## User data model
ユーザのデータモデルの提示と実装を行います。  

ユーザの最初のデータモデルは以下のようになります。  

- ユーザのデータモデル
  * モデル名: User
  * テーブル名: users
  * 生成カラム(カラム名:型): name:string, email:string
  * 自動生成カラム(カラム名:型): id:integer, inserted_at:timestamp, updated_at:timestamp
  * インデックス(対象カラム名): name, email

データモデルを把握したところで、モデルの作成に移りたいと思います。  
今回、使うコマンドは、"mix phoenix.gen.html"ではありません。  

"mix phoenix.gen.model"と言うコマンドを使います。  
生成したファイルの一覧を見ればどういった、コマンドなのか分かると思います。  

#### Example:

```cmd
>mix phoenix.gen.model User users name:string email:string
Generated sample_app app
* creating priv/repo/migrations/[timestamp]_create_user.exs
* creating web/models/user.ex
* creating test/models/user_test.exs
```

以下の三つのファイルが生成されていますね。  

- [timestamp]_create_user.exs
- user.ex
- user_test.exs

"mix phoenix.gen.model"コマンドは、  
(上から)マイグレーションファイル、モデルファイル、モデルのテストファイルを生成します。  

このコマンドは、コントローラやビューなどが不要の場合に利用すると良いですね。  

マイグレーションファイルの確認と編集を行います。  
マイグレーションファイルを開き、インデックスの作成を追加します。  

#### File: priv/repo/[timestamp]_create_user.exs

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

マイグレーションファイルの内容はEctoの機能が使われています。  
Ectoは、DBとの仲介をしてくれる便利なライブラリです。  

Webサイトを作成する上でDBは切っても切り離せません。  
しかし、DBとのやり取りが難しいと開発の効率が落ちてしまいますね。  

WebサイトとDBの間を仲介してくれる便利な機能があれば、  
難しい部分は考えなくてもよくなります。  
そのために、Ectoがあります。  

テーブルとカラムを作成する記述方法を見てみましょう。  

#### Example:

```txt
create table(テーブル名 do
  add カラム名, 型
  add カラム名, 型
  ...

  timestamps
end
```

大体は、見たままですね。  
"create table"でテーブルを作成、  
テーブル内の"add"でカラムを追加しています。  

timestampsは、inserted_atとupdated_atになります。  
自動で付与されるidは、特に記述はありません。  

次は、インデックスについて見てみましょう。  

#### Example:

```txt
create index(:users, [:name], unique: true, concurrently: true)
create index(:users, [:email], unique: true, concurrently: true)
```

インデックスの引数は、左から順番に...テーブル名、カラム名(複数可)、オプションと言った順番になっています。  
(カラムの複数指定は別のテーブルを作成する時に行っていきます。)  

uniqueオプションは、値に対して一意性を強制するものです。  

concurrentlyオプションは、  
対象テーブルに対する同時挿入、更新、削除を防止するようなロックを獲得せずにインデックスを作成するオプションです。  

#### Example:

```txt
@disable_ddl_transaction true
```

@disable_ddl_transaction属性は、  
トランザクションの外部で実行するように強制できる属性です。  

この属性がないと以下のようなエラーが発生します。  
PostgreSQLのログに出力されているメッセージです。  

#### Example:

```log
2015-07-29 14:06:19 JST ERROR:  CREATE INDEX CONCURRENTLYはトランザクションブロックの内側では実行できません
2015-07-29 14:06:19 JST ステートメント:  CREATE INDEX CONCURRENTLY "microposts_user_id_inserted_at_index" ON "microposts" ("user_id", "inserted_at")
```

DB関連でエラーが出たら、  
利用しているDBのログも確認した方が良いです。  

ようかくですが、初めてのマイグレーションを実行してみましょう。

#### Example:

```cmd
>mix ecto.migrate

22:38:04.343 [info]  == Running SampleApp.Repo.Migrations.CreateUser.change/0 forward

22:38:04.343 [info]  create table users

22:38:04.379 [info]  create index users_name_index

22:38:04.388 [info]  create index users_email_index

22:38:04.398 [info]  == Migrated in 0.4s
```

マイグレーションが無事終わったら、DBの方でも確認してみて下さい。  

## User
Userのコントローラ、ビューを作成します。
また、サインアップのためのルーティングの追加とUserのnewテンプレートを作成します。

サインアップのルーティングを追加します。  

#### File: web/router.ex

```elixir
scope "/", SampleApp do
  pipe_through :browser # Use the default browser stack

  ...
  get "/signup", UserController, :new
end
```

Userコントローラを作成します。  
また、newアクションの関数も作成します。  

#### File: web/controllers/user_controller.ex

```elixir
defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end
end
```

続いて、Userビューを作成します。  

#### File: web/views/user_view.ex

```elixir
defmodule SampleApp.UserView do
  use SampleApp.Web, :view
end
```

Userのテンプレートを格納するディレクトリを作成します。  
userと言うディレクトリを作成して下さい。  

#### Directory: web/templates/user

Userのnewテンプレートを作成します。  

#### File: web/templates/user/new.html.eex

```elixir
<div class="jumbotron">
  <h1>Sign up</h1>
  <p>Find me in web/templates/user/new.html.eex</p>
</div>
```

"Filling in Layout"で追加しておいた、リンクを修正します。  

#### File: web/templates/static_pages/home.html.eex

```html
<div class="jumbotron">
  <h1>Welcom to the Sample App</h1>

  ...

  <%= link "Sign up now!", to: user_path(@conn, :new), class: "btn btn-large btn-primary" %>
</div>
```

これでUserを扱うために、最低限必要なものが実装できました。  

今回、"mix phoenix.gen.html"を利用しなかったのは、理由があります。  
確かにコマンドを使えば楽なのですが、一から手を動かしていかなければ覚えられないためです。  

少し手間でしょうが、一から学んで行きましょう！！  

#### Note:

```txt
補足として知っておいて欲しいのですが、  
マイグレーションファイルの記述方法は、通常のElixirの記述方法ではありません。  

この記述が可能なのは、Elixirの機能であるマクロを利用しているからです。  
マクロを使えば、独自の記述ができるDSL(Domain-Specific Language)を実装できます。  

勿論ですが、限界や制限はあります。  
それでも有用な機能ですので、いずれ使う時が来た時のために、  
こういったことも可能なのだと知識の一つとして持っておいて損はありません。  
```

## Verify
モデルのデータをDBに格納する前には、検証を行うのが一般的ですね。  
Userモデルのデータも例外ではないです。Userモデルへ検証を追加していきます。  

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

検証を行うための機能ですが...実は既にEctoに実装されています。  
Ectoにある機能では足りない場合、自分で検証用の機能を実装します。  

UserモデルへEcto.Changesetの検証関数を追加します。  

#### File: web/models/user.ex

```elixir
defmodule SampleApp.User do
  ...

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    |> unique_constraint(:name)
    |> unique_constraint(:email)
    |> validate_length(:name, min: 1)
    |> validate_length(:name, max: 50)
  end
end
```

各関数の機能は、以下のようになっています。  

- validate_format/4: フォーマットの検証
- unique_constraint/3: 一意性の検証
- validate_length/3: 文字数の検証

この他にも多くの検証用関数が用意されていますので、  
一度、Ecto.Changesetのドキュメントに目を通した方が良いと思います。  

さてここで、困ったことが起きました。  

存在性を検証してくれる関数が存在しません。  
そのため、自分で実装しなければいけません。  

存在性が存在しないとはこれいかに...  

lib配下に、helpersと言うディレクトリを作成して下さい。  

#### Directory: lib/helpers

検証を補助するモジュールを作成します。  

#### File: lib/helpers/validate_helper.ex

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

changesetと検証したいフィールド名を引数に取り、  
そのフィールドの値が、nilか空文字でないことを確認しています。  

作成した存在性の検証を追加します。  

モデル全体で使いたいので、SampleApp.Web.model/0で  
SampleApp.Helpers.ValidateHelperのimportを追加します。  

#### File: web/web.ex

```elixir
def model do
  quote do
    use Ecto.Model

    import Ecto.Changeset
    import Ecto.Query, only: [from: 1, from: 2]

    import SampleApp.Helpers.ValidateHelper
  end
end
```

このSampleApp.Webでは、  
各モデル、ビュー、コントローラ、ルータで必ず使うモジュールのuseやimportなどを行っています。  
全てのモデルで使うモジュールがあるといった場合は、ここで追加してあげましょう。  
勿論、モデル以外でも問題ありません。  

Userモデルへ検証関数を追加します。

#### File: web/models/user.ex

```elixir
defmodule SampleApp.User do
  ...

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_presence(:name)
    |> validate_presence(:email)
    ...
  end
end
```

## Add password colum
パスワードのカラムを、ユーザのデータモデルに追加します。  

本来であれば、一度のマイグレーションで行えば良いのですが、  
再マイグレーションする練習として丁度良いので、パスワードは別で追加しています。  

- 追加のデータモデル
  * 対象モデル名: User
  * 対象テーブル名: users
  * 追加カラム(カラム名:型(オプション)): password:string(virtual)、password_digest:string

virtual属性とは・・・フィールドが正しいとき、データベースまで持続させない属性です。  

ユーザ入力とデータ検証は生の文字列のまま行いたいですが、  
DBへ格納するデータとしては暗号化されていて欲しいです。  

そうなると、passwordカラムは生の文字列のままなので、DBまで値の持続をさせたくありません。  

なので、passwordカラムで入力と検証を行った後、  
正しければ暗号化してpassword_digestカラムへ格納するといった動作をさせたいです。  

そして、passwordカラムの値はDBまで持続させないようにできるのが、virtual属性です。  
そうするとDBのデータ上、passwordカラムは空、password_digestカラムは暗号化した文字列といった状態が作れます。  

- password: 生の文字列
- password_digest: 暗号化した文字列

それでは、パスワードカラムの追加を行います。  
Ectoのコマンドを利用して、マイグレーションファイルだけ生成します。  

#### Example:

```cmd
>mix ecto.gen.migration add_password_to_users
```

"mix ecto.gen.migration"コマンドを使えば、  
マイグレーションファイルだけ生成できます。  

マイグレーションファイルを以下のように編集します。  

#### File: priv/repo/[timestamp]_add_password_to_users.exs

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

今回は新しくテーブルを追加するわけではないです。  
既存のテーブルへカラムを追加するので、  
"alter table(テーブル名(アトム))"を利用しています。  

マイグレーションを実行します。  

#### Example:

```cmd
>mix ecto.migrate
```

Userモデルのスキーマへパスワードのフィールドを追加します。  
また、required_fieldsにも追加します。  
(virtual属性は、ここで付加します)  

#### File: web/models/user.ex

```elixir
defmodule SampleApp.User do
  ...

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_digest, :string
    field :password, :string, virtual: true

    timestamps
  end

  @required_fields ~w(name email password)
  @optional_fields ~w()

  ...
end

```

## Encrypted password
パスワードの暗号化を行えるようにしましょう。  
暗号化と復号化は、Safetyboxを利用して行います。  

せっかくですから、暗号化を扱うためのモジュールを作成してみましょう。  

#### File: lib/encryption.ex

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

入力、検証後にパスワードの暗号化を行い、password_digestへ格納したいです。  
しかし、入力、検証を行った後どうやってpassword_digestへ値を格納すればよいでしょうか？  

何かしらの処理の後にフィールドへ操作を行いたい時は、  
Ectoのコールバック機能を利用します。  

UserモデルへCallbacksのuseとbefore_insertのコールバックを追加して下さい。  
また、before_insertで指定したアトム名と同じ関数を定義して下さい。  

#### File: web/models/user.ex

```elixr
defmodule SampleApp.User do
  use SampleApp.Web, :model
  use Ecto.Model.Callbacks

  before_insert :set_password_digest

  ...

  def set_password_digest(changeset) do
    password = Ecto.Changeset.get_field(changeset, :password)
    change(changeset, %{password_digest: SampleApp.Encryption.encrypt(password)})
  end
end
```

各コールバックには関数名を指定します。  
その関数名で実装すれば各動作の前後に動いてくれます。  

今回利用している、before_insertは、DBへの挿入処理の前に実行するものです。  
他にも色々なコールバックがありますので、用途に応じて使い分けができます。  

## Additional verification
パスワードにも検証が必要ですね。  
検証の追加を行います。  

- passwordの検証内容
  * 存在性
  * 文字数

Userモデルへパスワードの検証を追加して下さい。  

#### File: web/models/user.ex

```elixir
defmodule SampleApp.User do
  ...

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    ...
    |> validate_presence(:password)
    |> validate_length(:password, min: 8)
    |> validate_length(:password, max: 100)
  end

  ...
end
```

## Before the end
ソースコードをマージします。  

```cmd
>git add .
>git commit -am "Finish modeling_users."
>git checkout master
>git merge modeling_users
```

# Speaking to oneself
Userモデルが実装できました。  

次の章では、このUserモデルを使ってサインアップ機能を実装していきます。  

# Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/modeling-users?version=4.0#top)  
[hexdoxs - Ecto.Changeset](http://hexdocs.pm/ecto/Ecto.Changeset.html#content)  
[hexdoxs - Ecto.Model.Callbacks](http://hexdocs.pm/ecto/Ecto.Model.Callbacks.html#content)  