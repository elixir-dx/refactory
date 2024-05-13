if System.get_env("WARNINGS_AS_ERRORS") == "true" do
  Code.compiler_options(warnings_as_errors: true)
end

{:ok, _} = Refactory.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Refactory.Test.Repo, :manual)

ExUnit.start()
