if System.get_env("WARNINGS_AS_ERRORS") == "true" do
  Code.compiler_options(warnings_as_errors: true)
end

{:ok, _} = Refinery.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Refinery.Test.Repo, :manual)

ExUnit.start()
