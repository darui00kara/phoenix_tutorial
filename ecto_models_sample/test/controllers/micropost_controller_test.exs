defmodule EctoModelsSample.MicropostControllerTest do
  use EctoModelsSample.ConnCase

  alias EctoModelsSample.Micropost
  @valid_attrs %{content: "some content", user_id: 42}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, micropost_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing microposts"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, micropost_path(conn, :new)
    assert html_response(conn, 200) =~ "New micropost"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, micropost_path(conn, :create), micropost: @valid_attrs
    assert redirected_to(conn) == micropost_path(conn, :index)
    assert Repo.get_by(Micropost, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, micropost_path(conn, :create), micropost: @invalid_attrs
    assert html_response(conn, 200) =~ "New micropost"
  end

  test "shows chosen resource", %{conn: conn} do
    micropost = Repo.insert %Micropost{}
    conn = get conn, micropost_path(conn, :show, micropost)
    assert html_response(conn, 200) =~ "Show micropost"
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    micropost = Repo.insert %Micropost{}
    conn = get conn, micropost_path(conn, :edit, micropost)
    assert html_response(conn, 200) =~ "Edit micropost"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    micropost = Repo.insert %Micropost{}
    conn = put conn, micropost_path(conn, :update, micropost), micropost: @valid_attrs
    assert redirected_to(conn) == micropost_path(conn, :index)
    assert Repo.get_by(Micropost, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    micropost = Repo.insert %Micropost{}
    conn = put conn, micropost_path(conn, :update, micropost), micropost: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit micropost"
  end

  test "deletes chosen resource", %{conn: conn} do
    micropost = Repo.insert %Micropost{}
    conn = delete conn, micropost_path(conn, :delete, micropost)
    assert redirected_to(conn) == micropost_path(conn, :index)
    refute Repo.get(Micropost, micropost.id)
  end
end
