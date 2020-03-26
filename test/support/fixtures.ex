defmodule Todex.Fixtures do
  @moduledoc """
  use Todex.Fixtures, [:user, :project, :task] 
  """
  alias Todex.Repo
  alias Todex.Accounts
  alias Todex.Todos

  def user do
    quote do
      @valid_user_attrs %{encrypted_password: "some encrypted_password", username: "some username"}
      @update_user_attrs %{
        encrypted_password: "some updated encrypted_password",
        username: "some updated username"
      }
      @invalid_user_attrs %{encrypted_password: nil, username: nil}

      def user_fixture(attrs \\ %{}) do
        {:ok, user} =
          attrs
          |> Enum.into(@valid_user_attrs)
          |> Accounts.create_user()

        user
      end
    end
  end
  
  def project do
    quote do
      @valid_project_attrs %{description: "some description", name: "some name"}
      @update_project_attrs %{description: "some updated description", name: "some updated name"}
      @invalid_project_attrs %{description: nil, name: nil}

      def project_fixture(attrs \\ %{}) do
        {:ok, project} =
          attrs
          |> Enum.into(@valid_project_attrs)
          |> Todos.create_project()

        project
      end
    end
  end

  def task do
    quote do
      @valid_task_attrs %{
        conclusion_date: ~N[2010-04-17 14:00:00],
        description: "some description",
        is_concluded: true,
        title: "some title"
      }
      @update_task_attrs %{
        conclusion_date: ~N[2011-05-18 15:01:01],
        description: "some updated description",
        is_concluded: false,
        title: "some updated title"
      }
      @invalid_task_attrs %{conclusion_date: nil, description: nil, is_concluded: nil, title: nil}

      def task_fixture(attrs \\ %{}) do
        {:ok, task} =
          attrs
          |> Enum.into(@valid_task_attrs)
          |> Todos.create_task()

          Repo.preload(task, [:projects])
        task
      end
    end
  end

  @doc """
  Apply the fixtures
  """
  defmacro __using__(fixtures) when is_list(fixtures) do
    for fixture <- fixtures, is_atom(fixture), do: apply(__MODULE__, fixture, [])
  end
end
