defmodule Refactory.Test.Schema.Task do
  use Ecto.Schema

  alias Refactory.Test.Schema.{List, User}

  schema "tasks" do
    field(:title, :string)
    field(:desc, :string)

    belongs_to(:list, List)
    belongs_to(:created_by, User)

    field(:due_on, :date)
    field(:completed_at, :utc_datetime)
    field(:archived_at, :utc_datetime)
    timestamps()
  end
end
