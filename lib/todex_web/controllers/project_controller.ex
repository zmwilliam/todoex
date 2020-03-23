defmodule TodexWeb.ProjectController do
  use TodexWeb, :controller

  alias Todex.Todos
  alias Todex.Todos.Project
  alias Todex.Accounts

  plug :check_auth when action in [:index, :new, :create, :edit, :update, :delete]

  def index(conn, _params) do
    current_user_id = conn.assigns.current_user.id
    projects = Todos.list_projects(current_user_id)
    render(conn, "index.html", projects: projects)
  end

  def new(conn, _params) do
    changeset = Todos.change_project(%Project{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    current_user = conn.assigns.current_user
    project_params = Map.put(project_params, "user_id", current_user.id)

    case Todos.create_project(project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Todos.get_project!(id)
    render(conn, "show.html", project: project)
  end

  def edit(conn, %{"id" => id}) do
    project = Todos.get_project!(id)
    changeset = Todos.change_project(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Todos.get_project!(id)

    case Todos.update_project(project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: Routes.project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Todos.get_project!(id)
    {:ok, _project} = Todos.delete_project(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: Routes.project_path(conn, :index))
  end

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
end
