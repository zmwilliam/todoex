defmodule Todex.Repo.Migrations.RenameTaskCategory do
  use Ecto.Migration

  def change do
    rename table("tasks"), :category, to: :category_id
  end
end
