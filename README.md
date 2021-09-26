  # Extractly

<!--
DO NOT EDIT THIS FILE
It has been generated from the template `README.md.eex` by Extractly (https://github.com/RobertDober/extractly.git)
and any changes you make in this file will most likely be lost
-->


[![CI](https://github.com/RobertDober/extractly/actions/workflows/ci.yml/badge.svg)](https://github.com/RobertDober/extractly/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/RobertDober/extractly/badge.svg?branch=master)](https://coveralls.io/github/RobertDober/extractly?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/extractly.svg)](https://hex.pm/packages/extractly)
[![Hex.pm](https://img.shields.io/hexpm/dw/extractly.svg)](https://hex.pm/packages/extractly)
[![Hex.pm](https://img.shields.io/hexpm/dt/extractly.svg)](https://hex.pm/packages/extractly)


## Extractly

  Provide easy access to information inside the templates rendered by `mix xtra`

## Extractly.do_not_edit_warning/1

  Emits a comment including a message not to edit the created file, as it will be recreated from this template.

  It is a convenience to include this into your templates as follows

          <%= xtra.do_not_edit_warning %>

  or I18n'ed

          <%= xtra.do_not_edit_warning, lang: :fr %>

  If you are not generating html or markdown the comment can be parametrized

          <%= xtra.do_not_edit_warning, comment_start: "-- ", comment_end: "" %>

  If you want to include the name of the source template use `template: template` option, so
  a call may be as complex as:

          <%= xtra.do_not_edit_warning, comment_start: "-- ", comment_end: "", template: template, lang: :it %>


## Extractly.functiondoc/2

  Returns docstring of a function
  Ex:

```elixir
      iex(1)> {:ok, lines} = Extractly.functiondoc("Extractly.moduledoc/2") |> hd()
      ...(1)> lines |> String.split("\n") |> Enum.take(3)
      ["  Returns docstring of a module", "", "  E.g. verbatim"]
```

  We can also pass a list of functions to get their docs concatenated

```elixir
      iex(2)> [{:ok, moduledoc}, {:error, message}] = Extractly.functiondoc(["Extractly.moduledoc/2", "Extactly.functiondoc/2"])
      ...(2)> moduledoc |> String.split("\n") |> Enum.take(4)
      [ "  Returns docstring of a module",
        "  E.g. verbatim",
        "",
        "      Extractly.moduledoc(\"Extractly\")"]
      ...(2)> message
      "Function doc for function Extactly.functiondoc/2 not found"
```

  If all the functions are in the same module the following form can be used

```elixir
      iex(3)> [{:ok, out}, _] = Extractly.functiondoc(["moduledoc/2", "functiondoc/2"], module: "Extractly")
      ...(3)> String.split(out, "\n") |> hd()
      "  Returns docstring of a module"
```

  However it is convenient to add a markdown headline before each functiondoc, especially in these cases,
  it can be done by indicating the `headline: level` option

```elixir
      iex(4)> [{:ok, moduledoc}, {:ok, functiondoc}] = Extractly.functiondoc(["moduledoc/2", "functiondoc/2"], module: "Extractly", headline: 2)
      ...(4)> moduledoc |> String.split("\n") |> Enum.take(3)
      [ "## Extractly.moduledoc/2",
        "",
        "  Returns docstring of a module"]
      ...(4)> functiondoc |> String.split("\n") |> Enum.take(3)
      [ "## Extractly.functiondoc/2",
        "",
        "  Returns docstring of a function"]
```

  Often times we are interested by **all** public functiondocs...

```elixir
      iex(5)> [{:ok, out}|_] = Extractly.functiondoc(:all, module: "Extractly", headline: 2)
      ...(5)> String.split(out, "\n") |> Enum.take(3)
      [ "## Extractly.do_not_edit_warning/1",
        "",
        "  Emits a comment including a message not to edit the created file, as it will be recreated from this template."]
```

  We can specify a language to wrap indented code blocks into ` ```elixir\n...\n``` `

  Here is an example

```elixir
      iex(6)> [ok: doc] = Extractly.functiondoc("Extractly.functiondoc/2", wrap_code_blocks: "elixir")
      ...(6)> doc |> String.split("\n") |> Enum.take(10)
      [ "  Returns docstring of a function",
        "  Ex:",
        "",
        "```elixir",
        "      iex(1)> {:ok, lines} = Extractly.functiondoc(\"Extractly.moduledoc/2\") |> hd()",
        "      ...(1)> lines |> String.split(\"\\n\") |> Enum.take(3)",
        "      [\"  Returns docstring of a module\", \"\", \"  E.g. verbatim\"]",
        "```",
        "",
        "  We can also pass a list of functions to get their docs concatenated"]
```


## Extractly.macrodoc/2

  Returns docstring of a macro


## Extractly.moduledoc/2

  Returns docstring of a module

  E.g. verbatim

```elixir
      iex(7)> {:ok, doc} = Extractly.moduledoc("Extractly")
      ...(7)> doc
      "  Provide easy access to information inside the templates rendered by `mix xtra`\n"
```

  We can use the same options as with `functiondoc`

```elixir
      iex(8)> {:ok, doc} = Extractly.moduledoc("Extractly", headline: 2)
      ...(8)> doc |> String.split("\n") |> Enum.take(3)
      [
        "## Extractly", "", "  Provide easy access to information inside the templates rendered by `mix xtra`"
      ]
```

  If we also want to use `functiondoc :all, module: "Extractly"` **after** the call of `moduledoc` we can
  include `:all` in the call of `moduledoc`, which will include function and macro docstrings as well

```elixir
      iex(9)> [{:ok, moduledoc} | _] =
      ...(9)>   moduledoc("Extractly", headline: 3, include: :all)
      ...(9)> moduledoc
      "### Extractly\n\n  Provide easy access to information inside the templates rendered by `mix xtra`\n"
```

```elixir
      iex(10)> [_, {:ok, first_functiondoc} | _] =
      ...(10)>   moduledoc("Extractly", headline: 3, include: :all)
      ...(10)> first_functiondoc |> String.split("\n") |> Enum.take(5)
      [
        "### Extractly.do_not_edit_warning/1",
        "",
        "  Emits a comment including a message not to edit the created file, as it will be recreated from this template.",
        "",
        "  It is a convenience to include this into your templates as follows"
      ]
```


## Extractly.task/2

Returns the output of a mix task
  Ex:

```elixir
    iex(12)> Extractly.task("cmd", ~W[echo 42])
    "42\n"
```

```elixir
    iex(13)> try do
    ...(13)>   Extractly.task("xxx")
    ...(13)> rescue
    ...(13)>   e in RuntimeError -> e.message |> String.split("\n") |> hd()
    ...(13)> end
    "The following output was produced wih error code 1"
```


## Extractly.toc/2


Extract Table Of Contents from a markdown document

The files used for the following doctest can be found [here](https://github.com/RobertDober/extractly/tree/master/test/fixtures)

```elixir
    iex(11)> lines = [
    ...(11)>         "## Usage",
    ...(11)>         "### API",
    ...(11)>         "#### EarmarkParser.as_ast/2",
    ...(11)>         "### Support",
    ...(11)> ]
    ...(11)> toc(lines, gh_links: true)
    [
      "- [Usage](#usage)",
      "  - [API](#api)",
      "    - [EarmarkParser.as_ast/2](#earmarkparseras_ast2)",
      "  - [Support](#support)",
    ]
```

Detailed description can be found in `Extractly.Toc`'s docstrings


## Extractly.version/0

A convenience method to access this libraries version


## Extractly.Toc

Extract Table Of Contents from a list of lines representing a Markdown document

## Extractly.Toc.render/2

Depending on the options the Table Of Contents extracted from the lines can be
  rendered in different formats, the default being Markdown

#### Markdown

```elixir
    iex(1)> render(["# Hello", "## World"])
    ["- Hello",  "  - World"]
```

Numbered lists can be created too

```elixir
    iex(2)> render(["# Hello", "## World"], type: :ol)
    ["1. Hello",  "   1. World"]
```


Oftentimes the level of headlines is adapted for output, e.g. `###` for the top
and `#####` for the second level.

`render` accounts for that

```elixir
    iex(3)> render(["### Alpha", "ignored", "##### Alpha.1", "", "### Beta"])
    ["- Alpha", "  - Alpha.1", "- Beta"]
```

##### Remove Gaps

Sometimes there will be _gaps_ in the levels of headlines and these holes might
not reflect semantic but rather stylistic concerns, if this is the case the option
`remove_gaps` can be set to `true`

```elixir
    iex(4)> render(["# First", "### Third (but will go to second level)", "## Second"], remove_gaps: true)
    ["- First", "  - Third (but will go to second level)", "  - Second"]
```


##### Github README Links

This is all nice, however a TOC is most useful if links are provided.

`render` can render Github like links to within the page, here is a real world example
from a Github README.md file

```elixir
    iex(5)> lines = [
    ...(5)>         "## Usage",
    ...(5)>         "### API",
    ...(5)>         "#### EarmarkParser.as_ast/2",
    ...(5)>         "### Support",
    ...(5)> ]
    ...(5)> render(lines, gh_links: true)
    [
      "- [Usage](#usage)",
      "  - [API](#api)",
      "    - [EarmarkParser.as_ast/2](#earmarkparseras_ast2)",
      "  - [Support](#support)",
    ]
```

#### HTML

Sometimes it might be appropriate to generate HTML directly

```elixir
    iex(6)> render(["## One", "### Two"], format: :html)
    ["<ul>", "<li>One<ul>", "<li>Two</li>", "</ul></li>", "</ul>"]
```

##### Exlcuding levels and changing list styles

Let us examine these two options with HTML output, they work too for Markdown of course, but are meaningless with the more
_raw_ output formats

So we do not want to include levels greater than, say 3, and we also want to ignore top level headlines, probably because only
one top level part has sublevels

```elixir
    iex(7)> document = [
    ...(7)> "# Ignore",
    ...(7)> "# Too, but not what's below",
    ...(7)> "## Synopsis",
    ...(7)> "## Description",
    ...(7)> "### API",
    ...(7)> "#### too detailed",
    ...(7)> "### Tips & Tricks",
    ...(7)> "# Ignored again"
    ...(7)> ]
    ...(7)> render(document, format: :html, min_level: 2, max_level: 3, start: 5, type: :ol)
    [
      ~S{<ol start="5">},
      ~S{<li>Synopsis</li>},
      ~S{<li>Description<ol>},
      ~S{<li>API</li>},
      ~S{<li>Tips &amp; Tricks</li>},
      ~S{</ol></li>},
      ~S{</ol>},
    ]
```

#### PushList

Either a linear `PushList`

```elixir
    iex(8)> render(["# I", "## I.1", "## I.2", "### I.2.(i)", "# II", "### II.1.(ii)"], format: :push_list)
    ["I", :open, "I.1", "I.2", :open, "I.2.(i)", :close, :close, "II", :open, :open, "II.1.(ii)", :close, :close]
```


#### AST tree

```elixir
    iex(9)> render(["# I", "## I.1", "## I.2", "### I.2.(i)", "# II", "### II.1.(ii)"], format: :ast)
    ["I", ["I.1", "I.2", ["I.2.(i)"]], "II", [["II.1.(ii)"]]]
```



## Mix.Tasks.Xtra


##  Mix task to Transform EEx templates in the context of the `Extractly` module.

  This tool serves two purposes.

  1. A simple CLI to basicly `EEx.eval_file/2`

  1. Access to the `Extractly` module (available as binding `xtra` too)

  1. Access to the name of the rendered template with the `template` binding

  The `Extractly` module gives easy access to Elixir metainformation of the application using
  the `extractly` package, notably, _module_  and _function_ documentation.

  This is BTW the raison d'être of this package, simple creation of a `README.md` file with very simple
  access to the projects hex documentation.

  Thusly hexdoc and Github will always be synchronized.

  To see that in action just look at the [`README.md.eex`](README.md.eex) file of this package and compare
  with what you are reading here.


  Example Template:

      Some text
      <%= xtra.functiondoc("M.shiny_function/2") %>
      <%= xtra.moduledoc("String") %>

      More text


## Mix.Tasks.Xtra.Help

### Usage:

    mix xtra [options]... [template]

#### Options:

    --help | -h     Prints short help information to stdout and exits.
    --quiet | -q    No output to stdout or stderr
    --version | -v  Prints the current version to stdout and exits.
    --verbose | -V  Prints additional output to stderr

    --output filename
              The name of the file the rendered template is written to, defaults to the templates'
              name, without the suffix `.eex`

#### Argument:

    template, filename of the `EEx` template to use, defaults to `"README.md.eex"`





Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/extractly](https://hexdocs.pm/extractly).


## Author

Copyright © 20[18-21] Robert Dober, robert.dober@gmail.com,

# LICENSE

Same as Elixir, which is Apache License v2.0. Please refer to [LICENSE](LICENSE) for details.

SPDX-License-Identifier: Apache-2.0
