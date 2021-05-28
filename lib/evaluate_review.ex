defmodule EvaluateReview do
  @moduledoc """
  Documentation for `EvaluateReview`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> EvaluateReview.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Read Json from File 

  credit to https://elixirforum.com/u/idi527

  ## Examples
      
      iex> filename = "/tmp/test.json"
      iex> EvaluateReview.read_json(filename)

  """
  def read_json(filename) do
    with {:ok, body} <- File.read(filename), {:ok, json} <- Jason.decode(body), do: {:ok, json}
  end

  @doc ~S"""
  Scrape Dealer Rater Reviews

  This function attempts to scrape reviews from the passed in url and returns a list of tuples,
  the first element being the review itself and the second element containing the username of
  the reviewer. 

  The simple css selectors employed are .review-content for the content of the review itself, 
  and the combination of .italic and .font-18 for the username of the reviewer. This is an 
  intentionally chosen shortcut. A slightly more robust approach might use the .review-container
  selector instead since it would seem less likely to change. I found it relatively bloated and 
  so opted for a quicker approach that felt more elegant. 

  A future approach might include user-defined selectors rather than hard coded ones, but as
  the use case is currently very narrowly defined (solely scraping reviews from deallerrater.com)
  this approach seemed unnecessarily complicated. 


  ## Examples
      
      iex> url = "http://127.0.0.1:8000/manual.cache.dealerreviews.html"
      iex> reviews = EvaluateReview.scrape(url)
      iex> reviews |> Enum.with_index() |> Enum.each(fn {{a, b},_} -> IO.puts("review: #{a}, reviewer: #{b}") end)

  """
  def scrape(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, document} = Floki.parse_document(body)
        reviews = Floki.find(document, ".review-content")
        reviewers = Floki.find(document, ".italic") |> Floki.find(".font-18")
        zipped_reviews = Enum.zip(reviews, reviewers)

        # TODO a and b as lists feels unnecessary here convert to string
        stripped_reviews =
          zipped_reviews
          |> Enum.with_index()
          |> Enum.map(fn {{{_, _, a}, {_, _, b}}, _} -> {a, b} end)

        stripped_reviews

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  @doc """
  Classify overly positive reviews

  Takes a list of reviews in the format produced by EvaluateReview.scrape(url)

  Produces a list of the top three offenders ordered by severity 

  Current criteria for a suspicious review is simply based on a count of the number 
  of exclamation points included in the review

  ## Examples
      
      iex> url = "http://127.0.0.1:8000/manual.cache.dealerreviews.html"
      iex> reviews = EvaluateReview.scrape(url)
      iex> top3 = EvaluateReview.suspect_reviews(reviews)
      iex> IO.inspect(top3)
  """
  def suspect_reviews(reviews) do
    rated_reviews =
      reviews
      |> Enum.with_index()
      |> Enum.map(fn {{a, b}, _} ->
        {{a, b},
         to_string(a)
         |> String.graphemes()
         |> Enum.count(&(&1 == "!"))}
      end)

    top_three =
      Enum.reverse(
        rated_reviews
        |> List.keysort(1)
        |> Enum.take(-3)
      )

    top_three
  end
end
