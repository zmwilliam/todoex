defmodule TodexWeb.TaskController do
  use TodexWeb, :controller

  alias Todex.Todos
  alias Todex.Todos.Task
  alias TodexWeb.Helpers.Auth

  plug :check_auth

  def index(conn, params) do
    current_user = Auth.current_user(conn)
    tasks = Todos.list_tasks(current_user.id, params)
    render(conn, "index.html", tasks: tasks)
  end

  def new(conn, _params) do
    changeset =
      %Task{}
      |> Todos.preload_projects()
      |> Todos.change_task()

    categories = Todos.list_categories()

    current_user = Auth.current_user(conn)
    projects = Todos.list_projects(current_user.id)

    render(conn, "new.html", changeset: changeset, categories: categories, projects: projects)
  end

  def create(conn, %{"task" => task_params}) do
    current_user = Auth.current_user(conn)
    task_params = Map.put(task_params, "user_id", current_user.id)

    selected_projects =
      task_params
      |> Map.get("project_ids", [])
      |> Todos.list_projects_id_in()

    task_params = Map.put(task_params, "projects", selected_projects)

    case Todos.create_task(task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task created successfully.")
        |> redirect(to: Routes.task_path(conn, :show, task))

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Todos.list_categories()
        projects = Todos.list_projects(current_user.id)
        data = Todos.preload_projects(changeset.data)

        render(conn, "new.html",
          changeset: %{changeset | data: data},
          categories: categories,
          projects: projects
        )
    end
  end

  def show(conn, %{"id" => id}) do
    task = Todos.get_task!(id)
    render(conn, "show.html", task: task)
  end

  def edit(conn, %{"id" => id}) do
    task = Todos.get_task!(id)
    changeset = Todos.change_task(task)
    categories = Todos.list_categories()
    projects = current_user_projects(conn)

    render(conn, "edit.html",
      task: task,
      changeset: changeset,
      categories: categories,
      projects: projects
    )
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Todos.get_task!(id)

    selected_projects =
      task_params
      |> Map.get("project_ids", [])
      |> Todos.list_projects_id_in()

    task_params = Map.put(task_params, "projects", selected_projects)

    case Todos.update_task(task, task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task updated successfully.")
        |> redirect(to: Routes.task_path(conn, :show, task))

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Todos.list_categories()
        projects = current_user_projects(conn)

        render(conn, "edit.html",
          task: task,
          changeset: changeset,
          categories: categories,
          projects: projects
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Todos.get_task!(id)
    {:ok, _task} = Todos.delete_task(task)

    conn
    |> put_flash(:info, "Task deleted successfully.")
    |> redirect(to: Routes.task_path(conn, :index))
  end

  def done(conn, %{"task_id" => _id}) do
    conn
    |> put_flash(:info, "not implemented yet")
    |> redirect(to: Routes.task_path(conn, :index))
  end

  def undone(conn, %{"task_id" => _id}) do
    conn
    |> put_flash(:info, "not implemented yet")
    |> redirect(to: Routes.task_path(conn, :index))
  end

  defp current_user_projects(conn) do
    current_user = Auth.current_user(conn)
    Todos.list_projects(current_user.id)
  end

  defp check_auth(conn, _args) do
    unless Auth.signed_in?(conn) do
      conn
      |> put_flash(:error, "You need to be signed")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    else
      conn
    end
  end
end
