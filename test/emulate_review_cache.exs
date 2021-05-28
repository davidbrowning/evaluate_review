defmodule EvaluateReviewCacheTest do
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

  test "manual cache archived page" do
    url =
      "cache_file_waybahttps://web.archive.org/web/20201127110830/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/ck_reviews"

    review_list = EvaluateReview.scrape(url)
    EvaluateReview.cache(review_list, cache_file_wayback_reviews)
    assert File.exists?(cache_file_wayback_reviews)
  end
end
