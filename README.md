# Extractly



##  Mix task to Transform EEx templates in the context of the `Extractly` module.


  If a template is indicated than it is run in the context of the `Extractly` module which is
  passed in as variable `xtra`. And the output is written to a file named like the template without
  the `.eex` extension.

  This behavior can be changed via command line switches.

  Without an input template provided, the task is implying that `README.md.eex` was passed in.

  The `Extractly` module is available inside the templates but is also passed in as variable `xtra` for
  the convenience of the templates' authors.

  E.g. use the following template to extract some documentation from a module `M`.

      Some text
      <%= xtra.function_doc(M, :shiny_function/2) %>
      More text


## Usage:

    mix xtra [options]... [template]

### Options:

    --help     Prints short help information to stdout and exits.
    --version  Prints the current version to stdout and exits.
    --verbose  Prints additional output to stderr

    --output filename
              The name of the file the rendered template is written to, defaults to the templates'
              name, without the suffix `.eex`

### Argument:

    template, filename of the `EEx` template to use, defaults to `"README.md.eex"`




## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `extractly` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:extractly, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/extractly](https://hexdocs.pm/extractly).


## Author

Copyright © 2018,9 Robert Dober, robert.dober@gmail.com, Dave Thomas, The Pragmatic Programmers
@/+pragdave,  dave@pragprog.com

# LICENSE

Same as Elixir, which is Apache License v2.0. Please refer to [LICENSE](LICENSE) for details.

SPDX-License-Identifier: Apache-2.0
