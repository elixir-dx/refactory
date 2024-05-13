defmodule Refactory.Test.Schema.ListTemplate do
  use Ecto.Schema

  alias Refactory.Test.Schema.List

  schema "list_templates" do
    field(:title, :string)

    field(:hourly_points, :float)

    has_many(:lists, List, foreign_key: :from_template_id)
  end
end
