defmodule Todex.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :description, :string

      add :user_id, references(:users), null: false

      timestamps()
    end

    create unique_index(:projects, [:name, :user_id])
  end
end
