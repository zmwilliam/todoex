defmodule Todex.Todos.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Todex.Accounts.User
  alias Todex.Todos.Category
  alias Todex.Todos.Project

  schema "tasks" do
    field :conclusion_date, :naive_datetime
    field :description, :string
    field :is_concluded, :boolean, default: false
    field :title, :string

    belongs_to :user, User
    belongs_to :category, Category

    many_to_many :projects,
                 Project,
                 join_through: "task_projects",
                 on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :conclusion_date, :is_concluded, :category_id, :user_id])
    |> maybe_put_projects(attrs)
    |> validate_required([:title])
  end

  defp maybe_put_projects(changeset, %{projects: projects}), do: put_projects(changeset, projects)

  defp maybe_put_projects(changeset, %{"projects": projects}), do: put_projects(changeset, projects)

  defp maybe_put_projects(changeset, _), do: changeset

  defp put_projects(changeset, projects), do: Ecto.Changeset.put_assoc(changeset, :projects, projects)

end
