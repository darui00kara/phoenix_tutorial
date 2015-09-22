defmodule SampleApp.UserController do
  use SampleApp.Web, :controller

  plug SampleApp.Plugs.CheckAuthentication
  plug SampleApp.Plugs.SignedInUser when action in [:index, :show, :edit, :update, :delete, :following, :followers]
  plug :correct_user? when action in [:edit, :update, :delete]

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

  def new(conn, _params) do
    render(conn, "new.html", changeset: SampleApp.User.new)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = SampleApp.User.changeset(%SampleApp.User{}, user_params)

    if changeset.valid? do
      case Repo.insert(changeset) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "User registration successfully!!")
          |> put_session(:user_id, user.id)
          |> redirect(to: static_pages_path(conn, :home))
        {:error, changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, params) do
    select_page = params["select_page"]
    id = params["id"]

    user = Repo.get(SampleApp.User, id) |> Repo.preload(:relationships) |> Repo.preload(:reverse_relationships)
    page = SampleApp.Micropost.paginate(
      user.id, select_page, list_map_to_value_list(user.followed_users, :followed_id))
    changeset = SampleApp.Micropost.new_changeset(
      %SampleApp.Micropost{}, %{content: "", user_id: user.id})

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

  def edit(conn, %{"id" => id}) do
    user = Repo.get(SampleApp.User, id)
    user = Map.put(user, :password, SampleApp.Encryption.decrypt(user.password_digest))
    changeset = SampleApp.User.changeset(user)

    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get(SampleApp.User, id)
    changeset = SampleApp.User.changeset(user, user_params)

    if changeset.valid? do
      Repo.update(changeset)

      conn
      |> put_flash(:info, "User updated successfully!!")
      |> redirect(to: user_path(conn, :show, id))
    else
      conn
      |> put_flash(:error, "UserProfile updated is failed!! name or email or password is incorrect.")
      |> redirect(to: user_path(conn, :edit, id))
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get(SampleApp.User, id)
    from(m in SampleApp.Micropost, where: m.user_id == ^user.id) |> Repo.delete_all
    Repo.delete(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: static_pages_path(conn, :home))
  end

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

  defp list_map_to_value_list(repo_result, key) do
    for map <- repo_result do Map.get(map, key) end
  end

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