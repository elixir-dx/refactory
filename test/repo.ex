defmodule Refactory.Test.Repo do
  use Ecto.Repo,
    otp_app: :refactory,
    adapter: Ecto.Adapters.Postgres
end
