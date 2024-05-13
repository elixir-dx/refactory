import Config

config :refactory, Refactory.Test.Repo,
  hostname: "localhost",
  username: "postgres",
  password: "postgres",
  database: "refinery_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/schema"

config :refactory,
  ecto_repos: [Refactory.Test.Repo],
  repo: Refactory.Test.Repo

config :logger, level: :warn
