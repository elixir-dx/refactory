defmodule Refinery do
  @moduledoc """
  Refinery allows generating Ecto records with nested overrides for your tests.

  ## Refinements module

  To start using Refinery, first define a refinements module:

  ```
  defmodule MyApp.Refinements do
    use Refinery, repo: MyApp.Repo
  end
  ```

  ## Usage

  The refinements module has two functions:

  - `build/2` generates an Ecto record with the given refinements applied
  - `create/2` inserts an Ecto record into the database

  ## Refinements

  A refinement can be
  - a `Map` in which each key-value pair is either
    - a field with its value
    - an association with a refinement (for `belongs_to`, `has_one`, and `embeds_one`)
    - _soon:_ an association with a list of refinements (for `has_many` and `embeds_many`)
  - a custom refinement defined in the refinements module (see below)
  - a `Tuple` with multiple refinements to be applied

  ## Basic example

  ```
  defmodule MyApp.Refinements do
    use Refinery, repo: MyApp.Repo
  end

  MyApp.Refinements.build(MyApp.List, %{
    title: "Refined List",
    created_by_user: %{email: "test@email.org"}
  })

  %MyApp.List{
    title: "Refined List",
    created_by_user: %MyApp.User{
      email: "test@email.org"
    }
  }
  ```

  ## Default refinements

  Default refinements can be defined in the refinements module.
  They are always applied first.

  ```
  defmodule MyApp.Refinements do
    use Refinery, repo: MyApp.Repo

    def refinement(MyApp.List, :default) do
      %{
        title: "Default Title"
      }
    end
  end


  MyApp.Refinements.build(MyApp.List)

  %MyApp.List{title: "Default Title"}
  ```

  ## Custom refinements

  Custom refinements can be defined in the refinements module and then used by their name.

  ```
  defmodule MyApp.Refinements do
    use Refinery, repo: MyApp.Repo

    def refinement(MyApp.List, :default) do
      %{
        title: "Default Title"
      }
    end

    def refinement(MyApp.List, :with_admin_user) do
      %{
        created_by_user: %{
          role: :admin
        }
      }
    end
  end


  MyApp.Refinements.build(MyApp.List, :with_admin_user)

  %MyApp.List{title: "Default Title", created_by_user: %MyApp.User{role: :admin}}
  ```
  """

  defmacro __using__(opts) do
    quote location: :keep do
      def refinery_repo() do
        unquote(opts[:repo])
      end

      def create(type, refinements \\ %{}) do
        Refinery.create(__MODULE__, type, refinements)
      end

      def build(type, refinements \\ %{}) do
        Refinery.build(__MODULE__, type, refinements)
      end
    end
  end

  @doc """
  Inserts an Ecto record with the given refinements applied into the database
  """
  def create(module, type, refinements \\ %{}) do
    repo = module.refinery_repo()
    build(module, type, refinements) |> repo.insert!()
  end

  @doc """
  Generates an Ecto record with the given refinements applied
  """
  def build(module, type, refinements \\ %{}) do
    case resolve_refinement(module, type, {:default, refinements}) do
      record = %{__struct__: ^module} ->
        record

      record = %{__struct__: _module} ->
        raise ArgumentError, "Expected a struct of type #{module}. Got #{inspect(record)}"

      attrs ->
        do_build(module, type, attrs)
    end
  end

  defp do_build(module, type, attrs) do
    record = struct!(type, attrs)

    # set associations in record
    Enum.reduce(attrs, record, fn {name, refinements}, record ->
      assoc =
        case ecto_association(type, name) || ecto_embed(type, name) do
          %Ecto.Association.BelongsTo{related: type} -> {:build_one, type}
          %Ecto.Association.Has{cardinality: :one, related: type} -> {:build_one, type}
          %Ecto.Embedded{cardinality: :one, related: type} -> {:build_one, type}
          _ -> :skip
        end

      case {assoc, refinements} do
        {{:build_one, type}, %type{}} ->
          record

        {{:build_one, type}, %other_type{}} ->
          raise ArgumentError,
                "Expected value of type #{type} for #{type}.#{name}. Got #{other_type}"

        {{:build_one, _type}, nil} ->
          Map.put(record, name, nil)

        {{:build_one, type}, _} ->
          associated_record = build(module, type, refinements)
          Map.put(record, name, associated_record)

        {:skip, _} ->
          record
      end
    end)
  end

  defp resolve_refinement(module, type, :default) do
    module.refinement(type, :default)
  rescue
    _e in [UndefinedFunctionError, FunctionClauseError] -> %{}
    e -> reraise e, __STACKTRACE__
  end

  defp resolve_refinement(module, type, refinement) do
    module.refinement(type, refinement)
  rescue
    _e in [UndefinedFunctionError, FunctionClauseError] ->
      merge_refinements(module, type, refinement, %{})

    e ->
      reraise e, __STACKTRACE__
  end

  defp merge_refinements(module, type, refinements, result) when is_tuple(refinements) do
    refinements
    |> Tuple.to_list()
    |> Enum.reduce(result, &deep_merge(&2, resolve_refinement(module, type, &1), false, true))
  end

  defp merge_refinements(_module, _type, refinements, result) when is_map(refinements) do
    deep_merge(result, refinements, false)
  end

  defp merge_refinements(module, type, refinement, _result) do
    raise ArgumentError, "Unknown refinement for #{type} in #{module}: #{inspect(refinement)}"
  end

  defp ecto_association(type, name), do: type.__schema__(:association, name)
  defp ecto_embed(type, name), do: type.__schema__(:embed, name)

  defp deep_merge(left, right, concat_lists? \\ true, struct_overrides? \\ false) do
    Map.merge(left, right, &deep_resolve(&1, &2, &3, concat_lists?, struct_overrides?))
  end

  defp deep_resolve(_key, _left, %{__struct__: _type} = right, _concat_lists?, true) do
    right
  end

  defp deep_resolve(
         _key,
         %{__struct__: type} = left,
         %{__struct__: type} = right,
         _concat_lists?,
         _struct_overrides?
       ) do
    struct!(type, deep_merge(Map.from_struct(left), Map.from_struct(right)))
  end

  defp deep_resolve(_key, %{__struct__: type}, _right, _concat_lists?, _struct_overrides?) do
    raise ArgumentError, "#{type} cannot be merged with non-#{type}."
  end

  defp deep_resolve(_key, _left, %{__struct__: type}, _concat_lists?, _struct_overrides?) do
    raise ArgumentError, "Non-#{type} cannot be merged with #{type}."
  end

  defp deep_resolve(_key, %{} = left, %{} = right, _concat_lists?, _struct_overrides?) do
    deep_merge(left, right)
  end

  defp deep_resolve(_key, left, right, true, _struct_overrides?)
       when is_list(left) and is_list(right) do
    left ++ right
  end

  defp deep_resolve(_key, _left, right, _concat_lists?, _struct_overrides?), do: right
end
