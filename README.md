# EvaluateReview

EvaluateReview is a simple web scraper designed to detect inorganic overly positive reviews.

Online reviews have become critical to market success, and nothing puts customers off quite like
fake reviews and rating systems ripe with abuse. This service is intended to weed out fakers
at the high end of the review scale. It will attempt to detect and flag the top three most 
"overly positive" reviews and alert the user via log messages. 

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

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/evaluate_review](https://hexdocs.pm/evaluate_review).

