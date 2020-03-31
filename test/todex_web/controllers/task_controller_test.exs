defmodule TodexWeb.TaskControllerTest do
  use TodexWeb.ConnCase
  use Todex.Fixtures, [:user, :project, :task]
  use Plug.Test

  @create_attrs %{
    conclusion_date: ~N[2010-04-17 14:00:00],
    description: "some description",
    is_concluded: true,
    title: "some title"
  }
  @update_attrs %{
    conclusion_date: ~N[2011-05-18 15:01:01],
    description: "some updated description",
    is_concluded: false,
    title: "some updated title"
  }
  @invalid_attrs %{conclusion_date: nil, description: nil, is_concluded: nil, title: nil}

  describe "index" do
    setup [:auth_user]

    test "lists all tasks", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tasks"
    end
  end

  describe "new task" do
    setup [:auth_user]

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :new))
      assert html_response(conn, 200) =~ "New Task"
    end
  end

  describe "create task" do
    setup [:auth_user]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :create), task: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.task_path(conn, :show, id)

      conn = get(conn, Routes.task_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Task"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :create), task: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Task"
    end
  end

  describe "edit task" do
    setup [:create_task]

    test "renders form for editing chosen task", %{conn: conn, task: task} do
      conn = get(conn, Routes.task_path(conn, :edit, task))
      assert html_response(conn, 200) =~ "Edit Task"
    end
  end

  describe "update task" do
    setup [:create_task]

    test "redirects when data is valid", %{conn: conn, task: task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @update_attrs)
      assert redirected_to(conn) == Routes.task_path(conn, :show, task)

      conn = get(conn, Routes.task_path(conn, :show, task))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, task: task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Task"
    end
  end

  describe "delete task" do
    setup [:create_task]

    test "deletes chosen task", %{conn: conn, task: task} do
      conn = delete(conn, Routes.task_path(conn, :delete, task))
      assert redirected_to(conn) == Routes.task_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.task_path(conn, :show, task))
      end
    end
  end

  defp auth_user(_) do
    user = user_fixture()
    conn = Phoenix.ConnTest.build_conn() |> init_test_session(%{current_user: user})
    {:ok, conn: conn}
  end

  defp create_task(_) do
    user = user_fixture()
    conn = Phoenix.ConnTest.build_conn() |> init_test_session(%{current_user: user})
    task = task_fixture(user_id: user.id)
    {:ok, conn: conn, task: task}
  end
end
