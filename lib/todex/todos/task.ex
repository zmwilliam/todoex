defmodule Todex.Todos.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :conclusion_date, :naive_datetime
    field :description, :string
    field :is_concluded, :boolean, default: false
    field :title, :string
    field :category, :id

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :conclusion_date, :is_concluded])
    |> validate_required([:title])
  end
end
