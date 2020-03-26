defmodule Todex.TodosTest do
  use Todex.DataCase
  use Todex.Fixtures, [:user, :project, :task]

  alias Todex.Todos

  describe "projects" do
    alias Todex.Todos.Project

    test "list_projects/1 returns all projects that belongs to an user" do
      user = user_fixture(username: "user 1")
      project = project_fixture(%{name: "belongs user 1", user_id: user.id})

      user2 = user_fixture(username: "user 2")
      project_fixture(%{name: "belongs user 2", user_id: user2.id})

      assert Todos.list_projects(user.id) == [project]
    end

    test "get_project!/1 returns the project with given id" do
      user = user_fixture()
      project = project_fixture(user_id: user.id)
      assert Todos.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      user = user_fixture()
      attrs = Map.put(@valid_project_attrs, :user_id, user.id)
      assert {:ok, %Project{} = project} = Todos.create_project(attrs)
      assert project.description == "some description"
      assert project.name == "some name"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_project(@invalid_project_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      user = user_fixture()
      project = project_fixture(user_id: user.id)
      assert {:ok, %Project{} = project} = Todos.update_project(project, @update_project_attrs)
      assert project.description == "some updated description"
      assert project.name == "some updated name"
    end

    test "update_project/2 with invalid data returns error changeset" do
      user = user_fixture()
      project = project_fixture(user_id: user.id)
      assert {:error, %Ecto.Changeset{}} = Todos.update_project(project, @invalid_project_attrs)
      assert project == Todos.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      user = user_fixture()
      project = project_fixture(user_id: user.id)
      assert {:ok, %Project{}} = Todos.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      user = user_fixture()
      project = project_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Todos.change_project(project)
    end
  end

  describe "tasks" do
    alias Todex.Todos.Task

    test "list_tasks/2 returns all tasks that belongs to an user" do
      user = user_fixture()
      task = task_fixture(user_id: user.id)
      assert Todos.list_tasks(user.id) == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Todos.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      assert {:ok, %Task{} = task} = Todos.create_task(@valid_task_attrs)
      assert task.conclusion_date == ~N[2010-04-17 14:00:00]
      assert task.description == "some description"
      assert task.is_concluded == true
      assert task.title == "some title"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_task(@invalid_task_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, %Task{} = task} = Todos.update_task(task, @update_project_attrs)
      assert task.conclusion_date == ~N[2011-05-18 15:01:01]
      assert task.description == "some updated description"
      assert task.is_concluded == false
      assert task.title == "some updated title"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Todos.update_task(task, @invalid_task_attrs)
      assert task == Todos.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Todos.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Todos.change_task(task)
    end
  end
end
