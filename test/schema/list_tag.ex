defmodule Refactory.Test.Schema.ListTag do
  use Ecto.Schema

  alias Refactory.Test.Schema.List

  schema "list_tags" do
    belongs_to(:list, List)
    field(:name, :string)
  end
end
