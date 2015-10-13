# Goal
�قڐÓI�ȃy�[�W���쐬����B  

# Wait a minute
�����ō쐬���Ă����̂͐ÓI�y�[�W�ł��B  
��ԍŏ��̊�{���̊�{�ł��ˁB  

���āA����ł̓T���v���A�v���P�[�V�����̑����𓥂ݏo���܂��傤�I  

# Index
Static pages  
|> Preparation  
|> Add route  
|> Create controller  
|> Create view & template  
|> Let's run!  
|> Add about page  
|> Little dynamic  
|> Before the end  

## Preparation
�쐬����ɂ��Ă��A�܂��T���v���A�v���P�[�V�����p�̃v���W�F�N�g���쐬���Ă��܂���ˁB  
�v���W�F�N�g�̍쐬���s���܂��B  

#### Example:

```cmd
>cd path/to/project
>mix phoenix.new sample_app
>cd sample_app
>mix ecto.create
>mix phoenix.server
>Ctrl+C
```

git���g���u�����`��؂�܂��B  

#### Example:

```cmd
>git checkout -b static_pages
>git branch
  master
* static_pages
```

git init�����Ă��Ȃ����́A���������s���ĉ������B  

���̍�Ƃ͏͂̎n�܂�ɕK�����{���܂��B
������肪�N�����Ă��A�u�����`��؂�̂Ă邾���ōς݂܂��B

����ŏ����ǂ��B  

����ł́APhoenix-Framework�֐V�����y�[�W��ǉ����Ă����܂��傤�I  
����������Ɋւ��ẮA���������͎g�킸�蓮�Ńt�@�C����ǉ����Ă����܂��B  

���������̗L��݂�������܂��B  
���肪����A���肪����...  

## Add route
�V�����y�[�W��ǉ����邽�߂ɁA�܂��ŏ��ɂ�邱�Ƃ̓��[�e�B���O�̒ǉ��ł��B  

���[�e�B���O�̒ǉ����s���܂��B  

#### File: web/router.ex

```elixir
scope "/", SampleApp do
  ...

  get "/home", StaticPagesController, :home
  get "/help", StaticPagesController, :help
end
```

�ǉ��������[�e�B���O�͈ȉ��̂悤�ɁA
Phoenix-Framework�̃R�}���h���g���Ċm�F���邱�Ƃ��ł��܂��B  

�������ꂽ���[�e�B���O�����Ă݂܂��傤�B  

#### Example:

```cmd
>mix phoenix.routes
...
static_pages_path  GET     /home                SampleApp.StaticPagesController :home
static_pages_path  GET     /help                SampleApp.StaticPagesController :help
```

���̎��A�w�肵���R���g���[�������݂��Ă���K�v�͂���܂���B  

���[�e�B���O�̋L�q���@�ɂ��āA  
Phoenix-Framework�̃��[�e�B���O�͎��̂悤�ȍ\���ɂȂ��Ă��܂��B  

```elixir
get "/home", StaticPagesController, :home
```

��L�𕪉�����ƁA�ȉ��̂悤�ɂȂ��Ă��܂��B  

- get: HTTP���\�b�h (HTTP Method)
- "/home": �p�X (Path)
- StaticPagesController: �R���g���[���� (Controller name)
- :home: �A�N�V������ (Action name)

�ł́A�f���A�v���P�[�V�����Œǉ����Ă������[�e�B���O�͂ǂ��Ȃ��Ă���̂ł��傤���H  

```elixir
resources "/users", UserController
```

HTTP���\�b�h���ł͂Ȃ��Aresources�B  
�܂��A�A�N�V�����ɓ����镔�����L�q����Ă��܂���ˁB  

�����RESTful�ȃ��[�e�B���O�𐶐����Ă����L�q�ł��B  

��L�̋L�q�Ő������ꂽ���[�e�B���O���o���Ă��܂����H  
���̈�s���ȉ��̂悤�ȃ��[�e�B���O�ɂȂ�܂��B  

#### Example:

```cmd
>mix phoenix.routes
...
user_path  GET     /users           DemoApp.UserController.index/2
user_path  GET     /users/:id/edit  DemoApp.UserController.edit/2
user_path  GET     /users/new       DemoApp.UserController.new/2
user_path  GET     /users/:id       DemoApp.UserController.show/2
user_path  POST    /users           DemoApp.UserController.create/2
user_path  PATCH   /users/:id       DemoApp.UserController.update/2
           PUT     /users/:id       DemoApp.UserController.update/2
user_path  DELETE  /users/:id       DemoApp.UserController.delete/2
```

���������ł����A��L�ɉ����ĕ\�������...  

- resources: HTTP���\�b�h
- "users": �p�X
- UserController: �R���g���[��
- �A�N�V��������: RESTful�̃A�N�V�����S��

�ƌ������悤�ɂȂ�܂��B  

����̒i�K�ł́Aresources���g���Έ�C�Ƀ��[�e�B���O������Ă����ƌ����F���Ō��\�ł��B  
���v�ł��B�`���[�g���A�����I���鍠�ɂ́A�D���ȃ��[�e�B���O������悤�ɂȂ��Ă��邱�Ƃł��傤�B  

#### Note:

```txt
Phoenix-Framework�̑啔���́AElixir�̋@�\�ł���}�N���ō���Ă��܂��B  
���[�e�B���O�̋@�\���}�N���Ŏ�������Ă��܂��B  
�`���[�g���A���ł͐G��܂��񂪁A����������΃}�N�����Ƃ����^�v���O���~���O�ɐG���Ă݂�Ɩʔ����Ǝv���܂��B  
```

## Create Controller
���́A�R���g���[���̍쐬���s���Ă����܂��B  

�R���g���[���ł́A���[�e�B���O�Œ�`�����A�N�V����(�֐�)���`���āA  
���̃A�N�V�����ŉ����������̂����������Ă����܂��B  

�ǉ��������[�e�B���O�́Ahome�A�N�V������help�A�N�V�����ł��ˁB  
���̃A�N�V�������֐����Ƃ��Ď������܂��B  

#### File: web/controllers/static_pages_controller.ex

```elixir
defmodule SampleApp.StaticPagesController do
  use SampleApp.Web, :controller

  def home(conn, _params) do
    render conn, "home.html"
  end

  def help(conn, _params) do
    render conn, "help.html"
  end
end
```

## Create view & template
Web�T�C�g�Ƀ����_�����O�����r���[�ƃe���v���[�g�̍쐬���s���Ă����܂��B  
���ۂɐl�������ʂ̕����ł��ˁB  

�܂��́A�r���[����쐬���Ă����܂��傤�B  
�r���[�Ŏ��������֐��́A�e���v���[�g�ŗ��p���邱�Ƃ��ł��܂��B  

����́A���ɉ������邱�Ƃ��Ȃ��̂Ńr���[���쐬���邾���ɂȂ�܂��B  

#### File: web/views/static_pages_view.ex

```elixir
defmodule SampleApp.StaticPagesView do
  use SampleApp.Web, :view
end
```

#### Note:

```txt
�r���[�̓����_�����O������ہA�K���K�v�ɂȂ�܂��B  
�e���v���[�g�ɑΉ������r���[���Ȃ��ꍇ�A�����_�����O�ł��܂���̂Œ��ӂ��ĉ������B  
```

"static_pages"�ƌ������̂Ńf�B���N�g�����쐬���ĉ������B  
#### Directory: web/templates/static_pages

�ԈႦ�Ȃ��悤�ɒ��ӂ��ĉ������B  
�e���v���[�g�̃f�B���N�g�����̓R���g���[���̐擪���ƍ��킹��K�v������܂��B  

Phoenix-Framework�ł́A�f�t�H���g��EEx�Ƃ����e���v���[�g���g���܂��B  
(�ǂ��炩�ƌ����ƁAElixir�Ɏ�������Ă���@�\�ɂȂ�܂���...)  
Ruby on Rails�Ŏg����ERB�̂悤�Ȃ��̂Ǝv���Ă����Α��v�ł��B  

���ۂɔ��ɂ悭���Ă��܂��B  

home��help�̃e���v���[�g���쐬���쐬���Ă����܂��傤�B  

#### File: web/templates/static_pages/home.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages Home!</h2>
</div>
```

#### File: web/templates/static_pages/help.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages Help!</h2>
</div>
```

EEx�̋@�\�́A���̃y�[�W�ǉ��Ŏg���Ă����܂��B  

## Let's run!
�T�[�o���N�����č쐬�����y�[�W�����Ă݂܂��傤�B  

#### Example:

```cmd
>mix phoenix.server
```

�ȉ��̃A�h���X�փA�N�Z�X���ĉ������B  

#### URL: http://localhost:4000/home
#### URL: http://localhost:4000/help

�蓮�Ńt�@�C����f�B���N�g���̒ǉ������Ă����̂́A���X�ʓ|�ł���ˁB  
�������A���ꂪ��{�̎菇�ɂȂ�܂��B����A�o���Ă����ĉ������B  

�����āAAbout�y�[�W��ǉ����Ă݂܂��傤�B  

## Add about page
About�y�[�W��ǉ����܂��B  

��̎菇�ɕ킢�A���[�e�B���O����ǉ����܂��B  

#### File: web/router.ex

```elixir
scope "/", SampleApp do
  pipe_through :browser # Use the default browser stack

  ...
  get "/about", StaticPagesController, :about
end
```

��قǃR���g���[���͗p�ӂ��Ă��܂��̂ŁAabout�A�N�V�����֐���ǉ����邾���ɂȂ�܂��B  

#### File: web/controllers/static_pages_controller.ex

```elixir
defmodule SampleApp.StaticPagesController do
  ...

  def about(conn, _params) do
    render conn, "about.html"
  end
end
```

�r���[���p�Ӎς݂Ȃ̂ŁAabout�e���v���[�g��ǉ����邾���ɂȂ�܂��B  

#### File: web/templates/static_pages/about.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages About!</h2>
</div>
```

�T�[�o���N�����č쐬�����y�[�W�����Ă݂܂��傤�B  

##### Example:

```cmd
>mix phoenix.server
```

�ȉ��̃A�h���X�փA�N�Z�X���ĉ������B  

#### URL: http://localhost:4000/about

## Little dynamic
�����������I�ɓ����y�[�W�ɉ������Ă݂܂��傤�B  

�쐬����3�̃e���v���[�g�ňȉ��̕������A����ꌾ�����������ł��ˁB  

```html
<h2>Welcome to Static Pages Home!</h2>

<h2>Welcome to Static Pages Help!</h2>

<h2>Welcome to Static Pages About!</h2>
```

���̈قȂ镔���𓮓I�Ɏw��ł���悤�ɂ��Ă����܂��傤�B  

StaticPages�R���g���[���̊e�A�N�V�����֐����ȉ��̂悤�ɕύX���ĉ������B  

#### File: web/controllers/static_pages_controller.ex

```elixir
def home(conn, _params) do
  render conn, "home.html", message: "Home"
end
```

```elixir
def help(conn, _params) do
  render conn, "help.html", message: "Help"
end
```

```elixir
def about(conn, _params) do
  render conn, "about.html", message: "About"
end
```

�����_�����O����e���v���[�g�֕ϐ��𑗂��Ă��܂��B  

- message �E�E�E �e���v���[�g���ł̖��� (�ϐ���)
- "About" �E�E�E �l

���́A���̕ϐ����e���v���[�g�Ŏg���悤�ɕύX���܂��B  

#### File: web/templates/static_pages/home.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages <%= @message %>!</h2>
</div>
```

#### File: web/templates/static_pages/help.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages <%= @message %>!</h2>
</div>
```

#### File: web/templates/static_pages/about.html.eex

```html
<div class="jumbotron">
  <h2>Welcome to Static Pages <%= @message %>!</h2>
</div>
```

�e�y�[�W�̕\�����ς��Ȃ����Ƃ��m�F���܂��B

##### Example:

```cmd
>mix phoenix.server
```

�ȉ��̃A�h���X�փA�N�Z�X���ĉ������B  

#### URL: http://localhost:4000/home
#### URL: http://localhost:4000/help
#### URL: http://localhost:4000/about

�e���v���[�g���ł͈ȉ��̂悤�ɋL�q����ƁA  
�R���g���[����r���[�����瑗�����l���Q�Ƃł��܂��B  

```html
<%= @name %>
```

�����������ݍ���ł݂܂��B  
��L�̋L�q��Elixir�R�[�h�̖��ߍ��݂��s���Ă��܂��B  
�ϐ��ȊO�ɂ�if�L�q�Afor�L�q��֐��̎��s�Ȃǂ��s���܂��B  

����͂����܂łƂȂ�܂��B  
����ŁA�y�[�W��ǉ����Ă������@�͕�����܂����ˁB  

## Before the end
�\�[�X�R�[�h���}�[�W���܂��B  

```cmd
>git add .
>git commit -am "Finish static_pages."
>git checkout master
>git merge static_pages
```

#Speaking to oneself
Phoenix-Framework�ŐV�����y�[�W��ǉ�������@���w�т܂����B  
����ǉ�����΂�����������΁A����͂���܂���ˁB  

���̏͂ł́APhoenix-Framework�̃��C�A�E�g�ɂ��Ċw��ōs���܂��B  

# Bibliography
[Ruby on Rails Tutorial](http://railstutorial.jp/chapters/static-pages?version=4.0#top)  