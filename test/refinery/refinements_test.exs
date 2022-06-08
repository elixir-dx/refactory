defmodule Test.Support.RefinementsTest do
  use Refinery.Test.DataCase, async: true

  defmodule Refinements do
    use Refinery, repo: Refinery.Test.Repo

    def refinement(List, :default) do
      %{
        title: Enum.random(~w[Learning Professional Travel])
      }
    end

    def refinement(ListTag, :default) do
      %{
        name: Enum.random(~w[easy medium hard])
      }
    end

    def refinement(User, :default) do
      %{
        email: "default@email.org",
        last_name: "Medina"
      }
    end

    def refinement(User, :refined) do
      %{
        email: "refined@email.org"
      }
    end
  end

  test "works with normal overrides" do
    now = DateTime.utc_now()
    list = Refinements.build(List, %{archived_at: now})

    assert %List{
             archived_at: ^now,
             from_template: %Ecto.Association.NotLoaded{}
           } = list
  end

  test "works with nested overrides" do
    list_tag = Refinements.build(ListTag, %{list: %{created_by: %{last_name: "Vega"}}})

    assert %ListTag{
             list: %List{
               created_by: %User{
                 last_name: "Vega"
               }
             }
           } = list_tag
  end

  test "works with struct override" do
    user = Refinements.build(User)

    record = Refinements.build(ListTag, %{list: %{created_by: user}})

    assert %ListTag{
             list: %List{
               created_by: ^user
             }
           } = record
  end

  test "raises on invalid struct override" do
    user = Refinements.build(User)

    assert_raise ArgumentError, fn ->
      Refinements.build(ListTag, %{list: user})
    end
  end

  test "works with simple refinement" do
    list_tag = Refinements.build(ListTag, %{list: %{created_by: :refined}})

    assert %ListTag{
             list: %List{
               created_by: %User{
                 email: "refined@email.org",
                 last_name: "Medina"
               }
             }
           } = list_tag
  end

  test "raises on unknown refinement" do
    assert_raise ArgumentError, fn ->
      Refinements.build(List, %{created_by: :unknown})
    end
  end

  test "works with refinement + override" do
    record =
      Refinements.build(
        ListTag,
        %{
          list: %{
            created_by: {:refined, %{last_name: "Vega"}}
          }
        }
      )

    assert %ListTag{
             list: %List{
               created_by: %User{
                 email: "refined@email.org",
                 last_name: "Vega"
               }
             }
           } = record
  end
end
