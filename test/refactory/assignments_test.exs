defmodule Refactory.AssignmentsTest do
  use Refactory.Test.DataCase

  defmodule Factories do
    use Refactory, repo: Refactory.Test.Repo

    def trait(List, :default) do
      %{
        title: Enum.random(~w[Learning Professional Travel])
      }
    end

    def trait(List, :with_user) do
      %{
        created_by: %{}
      }
    end

    def trait(ListTag, :default) do
      %{
        name: Enum.random(~w[easy medium hard]),
        list: %{
          created_by: %{}
        }
      }
    end

    def trait(User, :default) do
      %{
        email: "default@email.org"
      }
    end
  end

  test "builds record with nested belongs_to association" do
    list = Factories.build(List, :with_user)

    assert %List{created_by: %User{email: "default@email.org"}} = list
    assert list.title in ~w[Learning Professional Travel]
    refute list.id
  end

  test "creates record with nested belongs_to association" do
    list = Factories.create(List, :with_user)

    assert %List{created_by: %User{email: "default@email.org"}} = list
    assert list.title in ~w[Learning Professional Travel]
    assert list.id
    assert list.created_by.id
  end

  test "builds record with belongs_to association override" do
    list = Factories.build(List, {:with_user, %{created_by: %{last_name: "Vega"}}})

    assert %List{created_by: %User{email: "default@email.org", last_name: "Vega"}} = list
    assert list.title in ~w[Learning Professional Travel]
    refute list.id
  end

  test "creates record with belongs_to association override" do
    list = Factories.create(List, {:with_user, %{created_by: %{last_name: "Vega"}}})

    assert %List{created_by: %User{email: "default@email.org", last_name: "Vega"}} = list
    assert list.title in ~w[Learning Professional Travel]
    assert list.id
    assert list.created_by.id
  end

  test "builds record with deeply nested belongs_to association" do
    list_tag = Factories.build(ListTag)

    assert %ListTag{list: %List{created_by: %User{email: "default@email.org"}}} = list_tag
    assert list_tag.name in ~w[easy medium hard]
    assert list_tag.list.title in ~w[Learning Professional Travel]
    refute list_tag.id
  end

  test "creates record with deeply nested belongs_to association" do
    list_tag = Factories.create(ListTag)

    assert %ListTag{list: %List{created_by: %User{email: "default@email.org"}}} = list_tag
    assert list_tag.name in ~w[easy medium hard]
    assert list_tag.list.title in ~w[Learning Professional Travel]
    assert list_tag.id
    assert list_tag.list.id
    assert list_tag.list.created_by.id
  end
end
