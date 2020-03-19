defmodule TodexWeb.TaskController do
  use TodexWeb, :controller

  alias Todex.Todos
  alias Todex.Todos.Task
  alias Todex.Accounts

  plug :check_auth

  def index(conn, _params) do
    tasks = Todos.list_tasks()
    render(conn, "index.html", tasks: tasks)
  end

  def new(conn, _params) do
    changeset = %Task{} 
                |> Todos.preload_projects() 
                |> Todos.change_task()
    #changeset = Todos.change_task(%Task{})
    categories = Todos.list_categories()

    current_user = conn.assigns.current_user
    projects = Todos.list_projects(current_user.id)

    render(conn, "new.html", changeset: changeset, categories: categories, projects: projects)
  end

  def create(conn, %{"task" => task_params}) do
    #TODO Is this the best way to set user_id? What about 
    #changeset put_assoc?
    current_user = conn.assigns.current_user
    task_params = Map.put(task_params, "user_id", current_user.id)

    selected_projects = Todos.list_projects_id_in(task_params["project_ids"])
    task_params = Map.put(task_params, "projects", selected_projects)

    case Todos.create_task(task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task created successfully.")
        |> redirect(to: Routes.task_path(conn, :show, task))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
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
    projects = logged_user_projects(conn)

    render(conn, "edit.html", task: task, changeset: changeset, categories: categories, projects: projects)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Todos.get_task!(id)

    selected_projects = Todos.list_projects_id_in(task_params["project_ids"])
    task_params = Map.put(task_params, "projects", selected_projects)

    case Todos.update_task(task, task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task updated successfully.")
        |> redirect(to: Routes.task_path(conn, :show, task))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", task: task, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Todos.get_task!(id)
    {:ok, _task} = Todos.delete_task(task)

    conn
    |> put_flash(:info, "Task deleted successfully.")
    |> redirect(to: Routes.task_path(conn, :index))
  end

  #FIXME duplicated TodexWeb.ProjectController
  defp check_auth(conn, _args) do
    if user_id = get_session(conn, :current_user_id) do
      current_user = Accounts.get_user!(user_id)

      conn 
      |> assign(:current_user, current_user)
    else
      conn
      |> put_flash(:error, "You need to be signed")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  defp logged_user_projects(conn) do
    current_user = conn.assigns.current_user
    Todos.list_projects(current_user.id)
  end
end
