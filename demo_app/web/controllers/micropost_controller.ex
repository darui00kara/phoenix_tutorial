defmodule DemoApp.MicropostController do
  use DemoApp.Web, :controller

  alias DemoApp.Micropost

  plug :scrub_params, "micropost" when action in [:create, :update]
  plug :action

  def index(conn, _params) do
    microposts = Repo.all(Micropost)
    render(conn, "index.html", microposts: microposts)
  end

  def new(conn, _params) do
    changeset = Micropost.changeset(%Micropost{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"micropost" => micropost_params}) do
    changeset = Micropost.changeset(%Micropost{}, micropost_params)

    if changeset.valid? do
      Repo.insert(changeset)

      conn
      |> put_flash(:info, "Micropost created successfully.")
      |> redirect(to: micropost_path(conn, :index))
    else
      render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    micropost = Repo.get(Micropost, id)
    render(conn, "show.html", micropost: micropost)
  end

  def edit(conn, %{"id" => id}) do
    micropost = Repo.get(Micropost, id)
    changeset = Micropost.changeset(micropost)
    render(conn, "edit.html", micropost: micropost, changeset: changeset)
  end

  def update(conn, %{"id" => id, "micropost" => micropost_params}) do
    micropost = Repo.get(Micropost, id)
    changeset = Micropost.changeset(micropost, micropost_params)

    if changeset.valid? do
      Repo.update(changeset)

      conn
      |> put_flash(:info, "Micropost updated successfully.")
      |> redirect(to: micropost_path(conn, :index))
    else
      render(conn, "edit.html", micropost: micropost, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    micropost = Repo.get(Micropost, id)
    Repo.delete(micropost)

    conn
    |> put_flash(:info, "Micropost deleted successfully.")
    |> redirect(to: micropost_path(conn, :index))
  end
end
