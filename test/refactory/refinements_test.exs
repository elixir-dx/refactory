defmodule Test.Support.RefinementsTest do
  use Refactory.Test.DataCase, async: true

  defmodule Traits do
    use Refactory, repo: Refactory.Test.Repo

    def trait(List, :default) do
      %{
        title: Enum.random(~w[Learning Professional Travel])
      }
    end

    def trait(ListTag, :default) do
      %{
        name: Enum.random(~w[easy medium hard])
      }
    end

    def trait(User, :default) do
      %{
        email: "default@email.org",
        last_name: "Medina"
      }
    end

    def trait(User, :refined) do
      %{
        email: "refined@email.org"
      }
    end
  end

  test "works with normal overrides" do
    now = DateTime.utc_now()
    list = Traits.build(List, %{archived_at: now})

    assert %List{
             archived_at: ^now,
             from_template: %Ecto.Association.NotLoaded{}
           } = list
  end

  test "works with nested overrides" do
    list_tag = Traits.build(ListTag, %{list: %{created_by: %{last_name: "Vega"}}})

    assert %ListTag{
             list: %List{
               created_by: %User{
                 last_name: "Vega"
               }
             }
           } = list_tag
  end

  test "works with struct override" do
    user = Traits.build(User)

    record = Traits.build(ListTag, %{list: %{created_by: user}})

    assert %ListTag{
             list: %List{
               created_by: ^user
             }
           } = record
  end

  test "raises on invalid struct override" do
    user = Traits.build(User)

    assert_raise ArgumentError, fn ->
      Traits.build(ListTag, %{list: user})
    end
  end

  test "works with simple trait" do
    list_tag = Traits.build(ListTag, %{list: %{created_by: :refined}})

    assert %ListTag{
             list: %List{
               created_by: %User{
                 email: "refined@email.org",
                 last_name: "Medina"
               }
             }
           } = list_tag
  end

  #   test "works with database lookup trait 1" do
  #     department = get_dept_by(name: "Construction")

  #     record =
  #       Traits.build(
  #         Timecards.TimecardData,
  #         %{timecard: %{offer: {:department_name, "Construction"}}}
  #       )

  #     assert %Timecards.TimecardData{
  #              timecard: %Timecards.Timecard{
  #                offer: %Production.Offer{
  #                  department: ^department
  #                }
  #              }
  #            } = record
  #   end

  #   test "works with database lookup trait 2" do
  #     department = get_dept_by(name: "Construction")

  #     record =
  #       Traits.build(
  #         Timecards.TimecardData,
  #         %{timecard: %{offer: %{department: {:name, "Construction"}}}}
  #       )

  #     assert %Timecards.TimecardData{
  #              timecard: %Timecards.Timecard{
  #                offer: %Production.Offer{
  #                  department: ^department
  #                }
  #              }
  #            } = record
  #   end

  test "raises on unknown trait" do
    assert_raise ArgumentError, fn ->
      Traits.build(List, %{created_by: :unknown})
    end
  end

  test "works with trait + override" do
    record =
      Traits.build(
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
