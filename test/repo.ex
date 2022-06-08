defmodule Refinery.Test.Repo do
  use Ecto.Repo,
    otp_app: :refinery,
    adapter: Ecto.Adapters.Postgres
end
