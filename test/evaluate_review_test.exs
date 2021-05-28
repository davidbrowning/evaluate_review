defmodule EvaluateReviewTest do
  use ExUnit.Case
  doctest EvaluateReview

  test "archive.org ok" do
    url = "https://archive.org"
    {:ok, response} = HTTPoison.get(url)
    assert response.status_code == 200
    IO.puts("archive.org online")
  end

  test "way back machine ok" do
    url = "https://web.archive.org"
    {:ok, response} = HTTPoison.get(url)
    assert response.status_code == 200
    IO.puts("way back machine online")
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
    IO.puts("way back machine archived reviews page available")
  end

  test "review cache" do
    cache_file_wayback_status = ".cache/wayback.status.json"
    assert File.exists?(cache_file_wayback_status)
    {:ok, wayback_status} = EvaluateReview.read_json(cache_file_wayback_status)

    url =
      "https://web.archive.org/web/#{wayback_status["timestamp"]}/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

    cache_file_wayback_reviews = ".cache/wayback.reviews.bin"
    review_list = EvaluateReview.scrape(url)
    EvaluateReview.cache(review_list, cache_file_wayback_reviews)
    assert File.exists?(cache_file_wayback_reviews)
    IO.puts("review cache successful")
  end

  test "load review cache" do
    cache_file_wayback_reviews = ".cache/wayback.reviews.bin"
    assert File.exists?(cache_file_wayback_reviews)
    review_list = EvaluateReview.load_from_cache(cache_file_wayback_reviews)
    assert is_list(review_list)
    assert is_tuple(hd(review_list))
    IO.puts("load review from cache successful")
  end

  test "scrape review" do
    cache_file_wayback_status = ".cache/wayback.status.json"
    assert File.exists?(cache_file_wayback_status)
    {:ok, wayback_status} = EvaluateReview.read_json(cache_file_wayback_status)
    IO.puts("timestamp of latest archive: #{wayback_status["timestamp"]}")

    url =
      "https://web.archive.org/web/#{wayback_status["timestamp"]}/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

    # live
    # url =
    #  "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"
    review_list = EvaluateReview.scrape(url)
    assert is_list(review_list)
    assert is_tuple(hd(review_list))
    IO.puts("way back machine successfully scraped")
  end

  test "top three offenders" do
    cache_file_wayback_reviews = ".cache/wayback.reviews.bin"
    assert File.exists?(cache_file_wayback_reviews)
    review_list = EvaluateReview.load_from_cache(cache_file_wayback_reviews)
    assert is_list(review_list)
    assert is_tuple(hd(review_list))
    top3 = EvaluateReview.suspect_reviews(review_list)
    assert length(top3) == 3
    IO.puts("top 3 offenders identified")
  end
end
