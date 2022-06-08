defmodule Refinery.Test.Schema.ListTag do
  use Ecto.Schema

  alias Refinery.Test.Schema.List

  schema "list_tags" do
    belongs_to(:list, List)
    field(:name, :string)
  end
end
