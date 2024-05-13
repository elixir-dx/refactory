defmodule Refactory.PlainTest do
  use Refactory.Test.DataCase

  defmodule Factories do
    use Refactory, repo: Refactory.Test.Repo
  end

  test "builds simple record" do
    user = Factories.build(User, %{email: "test@email.org"})

    assert %User{email: "test@email.org"} = user
    refute user.id
  end

  test "creates simple record" do
    user = Factories.create(User, %{email: "test@email.org"})

    assert %User{email: "test@email.org"} = user
    assert user.id
  end

  test "builds record with nested belongs_to association" do
    list =
      Factories.build(List, %{
        title: "Refined List",
        created_by: %{email: "test@email.org"}
      })

    assert %List{title: "Refined List", created_by: %User{email: "test@email.org"}} = list
    refute list.id
  end

  test "creates record with nested belongs_to association" do
    list =
      Factories.create(List, %{
        title: "Refined List",
        created_by: %{email: "test@email.org"}
      })

    assert %List{
             title: "Refined List",
             created_by: %User{email: "test@email.org"}
           } = list

    assert list.id
    assert list.created_by.id
  end

  test "builds record with assigned belongs_to association" do
    user = Factories.build(User, %{email: "test@email.org"})

    list =
      Factories.build(List, %{
        title: "Refined List",
        created_by: user
      })

    assert %List{title: "Refined List", created_by: %User{email: "test@email.org"}} = list
    refute list.id
  end

  test "creates record with assigned belongs_to association" do
    user = Factories.create(User, %{email: "test@email.org"})

    list =
      Factories.create(List, %{
        title: "Refined List",
        created_by: user
      })

    assert %List{
             title: "Refined List",
             created_by: %User{email: "test@email.org"}
           } = list

    assert list.id
    assert list.created_by == user
  end

  test "builds record with deeply nested belongs_to association" do
    list_tag =
      Factories.build(ListTag, %{
        list: %{
          title: "Refined List",
          created_by: %{email: "test@email.org"}
        }
      })

    assert %ListTag{
             list: %List{
               title: "Refined List",
               created_by: %User{email: "test@email.org"}
             }
           } = list_tag

    refute list_tag.id
  end

  test "creates record with deeply nested belongs_to association" do
    list_tag =
      Factories.create(ListTag, %{
        name: "easy",
        list: %{
          title: "Refined List",
          created_by: %{email: "test@email.org"}
        }
      })

    assert %ListTag{
             list: %List{
               title: "Refined List",
               created_by: %User{email: "test@email.org"}
             }
           } = list_tag

    assert list_tag.id
    assert list_tag.list.id
    assert list_tag.list.created_by.id
  end
end
