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
    with {:ok, body} <- File.read(filename),
         {:ok, json} <- Jason.decode(body), do: {:ok, json}
  end

  @doc """
  Scrape Dealer Rater Reviews

  ## Examples
      
      iex> url = "https://web.archive.org/web/20201127110830/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"
      iex> EvaluateReview.scrape(url)

  """
  def scrape(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
         {:ok, document} = Floki.parse_document(body)
         reviews = Floki.find(document, ".review-content") 
         reviewers = Floki.find(document, ".italic") |> Floki.find(".font-18")
         zipped_reviews = Enum.zip(reviews, reviewers)
         stripped_reviews = zipped_reviews |> Enum.with_index() |> Enum.map(fn{{{_, _, a},{_, _, b}}, _} -> {a, b} end)
         stripped_reviews
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

end
