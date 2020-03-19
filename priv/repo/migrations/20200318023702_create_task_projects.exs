defmodule Todex.Repo.Migrations.CreateTaskProjects do
  use Ecto.Migration

  def change do
    create table(:task_projects) do
      add :task_id, references(:tasks, on_delete: :delete_all), primary_key: true
      add :project_id, references(:projects, on_delete: :delete_all), primary_key: true
    end
  end
end
