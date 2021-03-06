defmodule Phoenanza.PlayersTest do
  use Phoenanza.DataCase
  require Logger

  alias Phoenanza.Players
  alias Phoenanza.Players.User
  
  describe "users" do

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

 

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Players.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Players.get_user!(user.id) == user
    end

    test "get_user_by_name/1 returns the user by given name" do
      user = user_fixture()
      assert Players.get_user_by_name("some name") == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Players.create_user(@valid_attrs)
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Players.create_user(@invalid_attrs)
    end

    test "Users are unique" do
      _user = user_fixture()
      assert {:error, %Ecto.Changeset{}} =  %{} 
                                            |> Enum.into(@valid_attrs)
                                            |> Players.create_user()
      
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Players.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Players.update_user(user, @invalid_attrs)
      assert user == Players.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Players.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Players.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Players.change_user(user)
    end
  end

  describe "user cache" do

    setup do
      Players.clear_cache()
      :ok
    end

    test "cache_user/1 adds a new user to cache" do
      user = user_fixture()
      Players.cache_user(user)
      assert Players.list_users_in_cache() == [user]
    end
    
    test "cache_user/1 adds a new user to cache by user name" do
      user = user_fixture()
      Players.cache_user(user.id)
      assert Players.list_users_in_cache() == [user]
    end
    
    test "decache_user/1 removes the user from cache" do
      user = user_fixture()
      Players.cache_user(user)
      assert Players.list_users_in_cache() == [user]
      Players.decache_user(user)
      assert Players.list_users_in_cache() == []
    end
    
  end
  

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs 
      |> Enum.into(@valid_attrs)
      |> Players.create_user()

    user
  end

end
