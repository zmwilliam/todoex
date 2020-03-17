defmodule Todex.Todos.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :conclusion_date, :naive_datetime
    field :description, :string
    field :is_concluded, :boolean, default: false
    field :title, :string

    belongs_to :user, Todex.Accounts.User
    belongs_to :category, Todex.Todos.Category

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :conclusion_date, :is_concluded, :category_id, :user_id])
    |> validate_required([:title])
  end
end
