defmodule Phoenanza.ETSCacheTest do
  use ExUnit.Case
  require Logger

  alias Phoenanza.Players.User
  alias Phoenanza.Repo.ETSCache
  
  describe "Cache" do

    @valid_attrs %{id: 1, name: "some name"}
    @update_attrs %{id: 1, name: "some updated name"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} = 
        attrs 
        |> Enum.into(@valid_attrs)
        |> create_user
        |> ETSCache.insert
      user
    end

    setup do 
      :ets.delete_all_objects(User)
      :ok
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert ETSCache.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert ETSCache.get_user!(user.id) == user
    end

    test "update_user/2 with valid data updates the user" do
      newUser = create_user(@update_attrs)
      assert {:ok, newUser} = ETSCache.update_user(newUser)
      assert %User{} = newUser
      assert newUser.name == "some updated name"
    end


    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = ETSCache.delete_user(user)
      assert_raise CaseClauseError, fn -> ETSCache.get_user!(user.id) end
    end
  end

  
  defp create_user(changesMap) do
    Map.merge(%User{}, changesMap)
  end
end
