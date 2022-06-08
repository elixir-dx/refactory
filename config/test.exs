import Config

config :refinery, Refinery.Test.Repo,
  hostname: "localhost",
  username: "postgres",
  password: "postgres",
  database: "refinery_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/schema"

config :refinery,
  ecto_repos: [Refinery.Test.Repo],
  repo: Refinery.Test.Repo

config :logger, level: :warn
