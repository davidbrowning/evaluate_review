defmodule EvaluateReviewTest do
  use ExUnit.Case
  doctest EvaluateReview

  test "archive.org ok" do
    url = "https://archive.org"
    {:ok, response} = HTTPoison.get(url)
    assert response.status_code == 200
  end

  test "way back machine ok" do
    url = "https://web.archive.org"
    {:ok, response} = HTTPoison.get(url)
    assert response.status_code == 200
  end

  test "way back machine dealerrater.com" do
    url =
      "http://archive.org/wayback/available?url=https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

    cache_file_wayback_status = ".cache/wayback.status.json"
    {:ok, response} = HTTPoison.get(url)
    {:ok, body} = Jason.decode(response.body)
    assert body["archived_snapshots"]["closest"]["available"] == true
    assert body["archived_snapshots"]["closest"]["status"] == "200"
    {:ok, cache} = File.open(cache_file_wayback_status, [:write])
    IO.binwrite(cache, Jason.encode!(body["archived_snapshots"]["closest"]))
    assert File.exists?(cache_file_wayback_status)
  end

  test "scrape review" do
    cache_file_wayback_status = ".cache/wayback.status.json"
    assert File.exists?(cache_file_wayback_status)
    {:ok, wayback_status} = EvaluateReview.read_json(cache_file_wayback_status)
    IO.puts(wayback_status["timestamp"])
    # covert
    # url = "https://web.archive.org/web/#{wayback_status["timestamp"]}/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"
    # live
    # url =
    #  "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

    # cache (served up via python3 -m http.server)
    url = "http://127.0.0.1:8000/manual.cache.dealerreviews.html"
    cache_file_wayback_reviews = ".cache/wayback.reviews.bin"
    review_list = EvaluateReview.scrape(url)
    assert is_list(review_list)
    assert is_tuple(hd(review_list))
    # TODO encode this as JSON rather than binary
    # credit to https://elixirforum.com/u/benwilson512
    bytes = :erlang.term_to_binary(review_list)
    {:ok, cache} = File.open(cache_file_wayback_reviews, [:write])
    IO.binwrite(cache, bytes)
    assert File.exists?(cache_file_wayback_reviews)
  end

  test "top three offenders" do
    cache_file_wayback_reviews = ".cache/wayback.reviews.bin"
    assert File.exists?(cache_file_wayback_reviews)
    bytes = File.read!(cache_file_wayback_reviews)
    review_list = :erlang.binary_to_term(bytes)
    assert is_list(review_list)
    assert is_tuple(hd(review_list))
    top3 = EvaluateReview.suspect_reviews(review_list)
    assert length(top3) == 3
  end

  test "greets the world" do
    assert EvaluateReview.hello() == :world
  end
end
