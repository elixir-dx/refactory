defmodule Refactory.Test.Schema.User do
  use Ecto.Schema

  alias Refactory.Test.Schema.List

  schema "users" do
    field(:email, :string)

    field(:first_name, :string)
    field(:last_name, :string)

    has_many(:lists, List, foreign_key: :created_by_id)
  end
end
