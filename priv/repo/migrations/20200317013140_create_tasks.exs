defmodule Todex.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :text
      add :conclusion_date, :naive_datetime
      add :is_concluded, :boolean, default: false, null: false
      add :category, references(:categories, on_delete: :nothing)

      timestamps()
    end

    create index(:tasks, [:category])
  end
end
