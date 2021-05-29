defmodule EvaluateReview do
  @moduledoc """
  Documentation for `EvaluateReview`.
  """

  @doc """
  cache review results

  # TODO encode this as JSON rather than binary

  credit to https://elixirforum.com/u/benwilson512

  Caches review lists as binary data so as to avoid unnecessary
  web scraping and to minimize suspicion

  """
  def cache(review_list, filename) do
    bytes = :erlang.term_to_binary(review_list)
    {:ok, cache} = File.open(filename, [:write])
    IO.binwrite(cache, bytes)
  end

  @doc """
  load cache review results

  credit to https://elixirforum.com/u/benwilson512

  """

  def load_from_cache(filename) do
    bytes = File.read!(filename)
    review_list = :erlang.binary_to_term(bytes)
    review_list
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

  @doc """
  Uses Floki to recursively match a given list of selectors. Often times css selectors are used for 
  many different tags on a page. The combination of several helps the user to narrow down their 
  selection to a single tag.

  """
  def match_selectors([head | tail], document) do
    result = Floki.find(document, head) 
    match_selectors(tail, result)
  end

  def match_selectors([], result) do
    result
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
      
      iex> url = "https://web.archive.org/web/20201127110830/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"
      iex> reviews = EvaluateReview.scrape(url, [])
      iex> reviews |> Enum.with_index() |> Enum.each(fn {{a, b},_} -> IO.puts("review: #{a}, reviewer: #{b}") end)

  """
  @defaults %{review: [".review-content"], reviewer: [".italic", ".font-18"]}

  def scrape(url, selectors) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, document} = Floki.parse_document(body)
        %{review: review, reviewer: reviewer} = Enum.into(selectors, @defaults)
        reviews = match_selectors(review, document)
        reviewers = match_selectors(reviewer, document)
        zipped_reviews = Enum.zip(reviews, reviewers)

        stripped_reviews =
          zipped_reviews
          |> Enum.map(fn {{_HTML_tag, _class_info, review_content}, 
             {_tag, _class, reviewer_content}} -> 
             {review_content, reviewer_content} end)

        stripped_reviews

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  @doc """
  Classify overly positive reviews

  Takes a list of reviews in the format produced by EvaluateReview.scrape(url, [])

  Produces a list of the top three offenders ordered by severity 

  Current criteria for a suspicious review is simply based on a count of the number 
  of exclamation points included in the review

  ## Examples
      iex> url = "https://web.archive.org/web/20201127110830/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"
      iex> reviews = EvaluateReview.scrape(url, [])
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
