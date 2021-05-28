# EvaluateReview

EvaluateReview is a simple web scraper designed to detect inorganic overly positive reviews.

Online reviews have become critical to market success, and nothing puts customers off quite like
fake reviews and rating systems ripe with abuse. This service is intended to weed out fakers
at the high end of the review scale. It will attempt to detect and flag the top three most 
"overly positive" reviews and alert the user via log messages. It was tailored specifically for
dealerrater.com 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `evaluate_review` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:evaluate_review, "~> 0.1.0"}
  ]
end
```

## Testing
In order to be both courteous and more discrete, testing is configured to use an archived 
copy of dealerrater.com served from archive.org. Tests can be run with 

```elixir
mix test ./test/
```

Cache dependent tests are excluded by default, to run them

```elixir
mix test ./test --include needs_cache
```

# Running

To run the application, invoke the ./run.exs script with mix

```elixir
mix run ./run.exs
```

Note: the first run will download data from dealerrater.com all subsequent runs
will use a cached version of the relevant data saved in the .cache/ directory
unless said data is manually cleared

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/evaluate_review](https://hexdocs.pm/evaluate_review).

