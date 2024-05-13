defmodule Refactory do
  @external_resource Path.expand("./README.md")
  @moduledoc File.read!(Path.expand("./README.md"))
             |> String.split("<!-- MODULEDOC -->")
             |> Enum.at(1)

  defmacro __using__(opts) do
    quote location: :keep do
      def refinery_repo() do
        unquote(opts[:repo])
      end

      def create(type, traits \\ %{}) do
        Refactory.create(__MODULE__, type, traits)
      end

      def build(type, traits \\ %{}) do
        Refactory.build(__MODULE__, type, traits)
      end
    end
  end

  @doc """
  Inserts an Ecto record with the given traits applied into the database
  """
  def create(module, type, traits \\ %{}) do
    repo = module.refinery_repo()
    build(module, type, traits) |> repo.insert!()
  end

  @doc """
  Generates an Ecto record with the given traits applied
  """
  def build(module, type, traits \\ %{}) do
    case resolve_refinement(module, type, {:default, traits}) do
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
    Enum.reduce(attrs, record, fn {name, traits}, record ->
      assoc =
        case ecto_association(type, name) || ecto_embed(type, name) do
          %Ecto.Association.BelongsTo{related: type} -> {:build_one, type}
          %Ecto.Association.Has{cardinality: :one, related: type} -> {:build_one, type}
          %Ecto.Embedded{cardinality: :one, related: type} -> {:build_one, type}
          _ -> :skip
        end

      case {assoc, traits} do
        {{:build_one, type}, %type{}} ->
          record

        {{:build_one, type}, %other_type{}} ->
          raise ArgumentError,
                "Expected value of type #{type} for #{type}.#{name}. Got #{other_type}"

        {{:build_one, _type}, nil} ->
          Map.put(record, name, nil)

        {{:build_one, type}, _} ->
          associated_record = build(module, type, traits)
          Map.put(record, name, associated_record)

        {:skip, _} ->
          record
      end
    end)
  end

  defp resolve_refinement(module, type, :default) do
    module.trait(type, :default)
  rescue
    _e in [UndefinedFunctionError, FunctionClauseError] -> %{}
    e -> reraise e, __STACKTRACE__
  end

  defp resolve_refinement(module, type, trait) do
    module.trait(type, trait)
  rescue
    _e in [UndefinedFunctionError, FunctionClauseError] ->
      merge_refinements(module, type, trait, %{})

    e ->
      reraise e, __STACKTRACE__
  end

  defp merge_refinements(module, type, traits, result) when is_tuple(traits) do
    traits
    |> Tuple.to_list()
    |> Enum.reduce(result, &deep_merge(&2, resolve_refinement(module, type, &1), false, true))
  end

  defp merge_refinements(_module, _type, traits, result) when is_map(traits) do
    deep_merge(result, traits, false)
  end

  defp merge_refinements(module, type, trait, _result) do
    raise ArgumentError, "Unknown trait for #{type} in #{module}: #{inspect(trait)}"
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
