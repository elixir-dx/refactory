# Refactory

An Elixir library to generate test data recursively with traits

## Installation

The package can be installed
by adding `refactory` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:refactory, "~> 0.1.0", only: :test}
  ]
end
```

Documentation can found at <https://hexdocs.pm/refactory/>.

<!-- MODULEDOC -->
Refactory allows generating Ecto records with nested overrides for your tests.

## Factory module

To start using Refactory, first define a factory module:

```
defmodule MyApp.Factory do
  use Refactory, repo: MyApp.Repo
end
```

## Usage

The factory module has two functions:

- `build/2` generates an Ecto record with the given traits applied
- `create/2` inserts an Ecto record into the database

## Traits

A trait can be
- a `Map` in which each key-value pair is either
  - a field with its value
  - an association with a trait (for `belongs_to`, `has_one`, and `embeds_one`)
  - _soon:_ an association with a list of traits (for `has_many` and `embeds_many`)
- a custom trait defined in the factory module (see below)
- a `Tuple` with multiple traits to be applied

## Basic example

```
defmodule MyApp.Factory do
  use Refactory, repo: MyApp.Repo
end

MyApp.Factory.build(MyApp.List, %{
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

## Default traits

Default traits can be defined in the factory module.
They are always applied first.

```
defmodule MyApp.Factory do
  use Refactory, repo: MyApp.Repo

  def trait(MyApp.List, :default) do
    %{
      title: "Default Title"
    }
  end
end


MyApp.Factory.build(MyApp.List)

%MyApp.List{title: "Default Title"}
```

## Custom traits

Custom traits can be defined in the factory module and then used by their name.

```
defmodule MyApp.Factory do
  use Refactory, repo: MyApp.Repo

  def trait(MyApp.List, :default) do
    %{
      title: "Default Title"
    }
  end

  def trait(MyApp.List, :with_admin_user) do
    %{
      created_by_user: %{
        role: :admin
      }
    }
  end
end


MyApp.Factory.build(MyApp.List, :with_admin_user)

%MyApp.List{title: "Default Title", created_by_user: %MyApp.User{role: :admin}}
```
<!-- MODULEDOC -->

## Why another factory library?

To my knowledge, this is the only factory library that supports recursive traits,
providing a powerful declarative appraoch to (test) data generation.

Recursive and/or nested approaches might be tricky in non-functional programming
languages, because the resulting objects often encapsulate internal state.
In Elixir, however, data structures are cleanly separated from behavior,
making it a great field of application for recursive data structure generation.

## Special thanks

This project is sponsored and kindly supported by [Team Engine](https://www.teamengine.co.uk/).

If you'd like to join us working on [Dx](https://github.com/elixir-dx/dx) and Refactory
as a contractor, please reach out to [@arnodirlam](https://github.com/arnodirlam).
