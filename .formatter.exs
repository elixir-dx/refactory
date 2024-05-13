# Used by "mix format"
[
  inputs: [
    "*.{ex,exs}",
    "{config,lib}/**/*.{ex,exs}",
    "test/{refactory,support}/**/*.{ex,exs}",
    "test/*.{ex,exs}"
  ],
  import_deps: [:ecto],
  subdirectories: ["test/schema/migrations"]
]
