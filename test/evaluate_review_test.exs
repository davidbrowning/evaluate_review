defmodule EvaluateReviewTest do
  use ExUnit.Case

  @tag needs_cache: true
  doctest EvaluateReview

  @tag needs_cache: true
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
  end

  @tag needs_cache: true
  test "load review cache" do
    cache_file_wayback_reviews = ".cache/wayback.reviews.bin"
    assert File.exists?(cache_file_wayback_reviews)
    review_list = EvaluateReview.load_from_cache(cache_file_wayback_reviews)
    assert is_list(review_list)
    assert is_tuple(hd(review_list))
  end

  @tag needs_cache: true
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
  end

  @tag needs_cache: true
  test "top three offenders" do
    cache_file_wayback_reviews = ".cache/wayback.reviews.bin"
    assert File.exists?(cache_file_wayback_reviews)
    review_list = EvaluateReview.load_from_cache(cache_file_wayback_reviews)
    assert is_list(review_list)
    assert is_tuple(hd(review_list))
    top3 = EvaluateReview.suspect_reviews(review_list)
    assert length(top3) == 3
  end
end
