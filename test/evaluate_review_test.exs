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

  test "review cache" do
    cache_file_wayback_status = ".cache/wayback.status.json"

    url =
      if(File.exists?(cache_file_wayback_status)) do
        {:ok, wayback_status} = EvaluateReview.read_json(cache_file_wayback_status)

        t_url =
          "https://web.archive.org/web/#{wayback_status["timestamp"]}/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

        t_url
      else
        t_url =
          "https://web.archive.org/web/20201127110830/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

        IO.puts("still writing cache, manually setting last known archive.org date")
        t_url
      end

    cache_file_wayback_reviews = ".cache/wayback.reviews.bin"
    review_list = EvaluateReview.scrape(url, [])
    EvaluateReview.cache(review_list, cache_file_wayback_reviews)
    assert File.exists?(cache_file_wayback_reviews)
  end

  @tag needs_cache: true
  test "load review cache" do
    cache_file_wayback_reviews = ".cache/wayback.reviews.bin"

    if(File.exists?(cache_file_wayback_reviews)) do
      review_list = EvaluateReview.load_from_cache(cache_file_wayback_reviews)
      assert is_list(review_list)
      assert is_tuple(hd(review_list))
    else
      raise "cached file not present: #{cache_file_wayback_reviews}"
    end
  end

  test "match selectors" do
    cache_file_wayback_status = ".cache/wayback.status.json"

    url =
      if(File.exists?(cache_file_wayback_status)) do
        {:ok, wayback_status} = EvaluateReview.read_json(cache_file_wayback_status)

        t_url =
          "https://web.archive.org/web/#{wayback_status["timestamp"]}/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

        IO.puts("timestamp of latest archive: #{wayback_status["timestamp"]}")
        t_url
      else
        t_url =
          "https://web.archive.org/web/20201127110830/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

        IO.puts("still writing cache, manually setting last known archive.org date")
        t_url
      end

    review_list =
      EvaluateReview.scrape(url, %{
        review: [".review-content"],
        reviewer: [".emp-467062", ".teal", ".small-text"]
      })

    review_list
    |> Enum.each(fn {_, employee} ->
      assert(String.trim(to_string(employee)) == "Mariela Hernandez")
    end)
  end

  test "scrape review" do
    cache_file_wayback_status = ".cache/wayback.status.json"

    url =
      if(File.exists?(cache_file_wayback_status)) do
        {:ok, wayback_status} = EvaluateReview.read_json(cache_file_wayback_status)

        t_url =
          "https://web.archive.org/web/#{wayback_status["timestamp"]}/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

        IO.puts("timestamp of latest archive: #{wayback_status["timestamp"]}")
        t_url
      else
        t_url =
          "https://web.archive.org/web/20201127110830/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

        IO.puts("still writing cache, manually setting last known archive.org date")
        t_url
      end

    review_list = EvaluateReview.scrape(url, [])
    assert is_list(review_list)
    assert is_tuple(hd(review_list))
  end

  test "scrape n reviews" do
    cache_file_wayback_status = ".cache/wayback.status.json"

    url =
      if(File.exists?(cache_file_wayback_status)) do
        {:ok, wayback_status} = EvaluateReview.read_json(cache_file_wayback_status)

        t_url =
          "https://web.archive.org/web/#{wayback_status["timestamp"]}/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

        IO.puts("timestamp of latest archive: #{wayback_status["timestamp"]}")
        t_url
      else
        t_url =
          "https://web.archive.org/web/20201127110830/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

        IO.puts("still writing cache, manually setting last known archive.org date")
        t_url
      end

    url_list = [url] ++ [url]

    assert(
      EvaluateReview.scrape_n(url_list, []) ==
        EvaluateReview.scrape(url, []) ++ EvaluateReview.scrape(url, [])
    )
  end

  @tag external: true
  test "scrape live review" do
    url =
      "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"

    review_list = EvaluateReview.scrape(url, [])
    assert is_list(review_list)
    assert is_tuple(hd(review_list))
  end

  # Proof of concept. Scraper works with other review sites though often finding the right selector
  #  is challenging and data isn't necessarily as clean. 
  #  In addition, shameless scraping from most sites will get you banned. To include this test, run 
  #  mix test ./test --include external
  @tag external: true
  test "scrape site agnostic" do
    url = "https://www.glassdoor.com/Reviews/Podium-Reviews-E1010497.htm"

    review_list =
      EvaluateReview.scrape(url, %{
        review: [".mb-xxsm", ".mt-0", ".css-5j5djr"],
        reviewer: [".pt-xsm", ".pt-md-0", ".css-1qxtz39", ".eg4psks0"]
      })

    # YMMV on site output and some cleanup may be required
    IO.inspect(review_list)
    assert is_list(review_list)
    assert is_tuple(hd(review_list))
  end

  @tag needs_cache: true
  test "top three offenders" do
    cache_file_wayback_reviews = ".cache/wayback.reviews.bin"

    if(File.exists?(cache_file_wayback_reviews)) do
      review_list = EvaluateReview.load_from_cache(cache_file_wayback_reviews)
      assert is_list(review_list)
      assert is_tuple(hd(review_list))
      top3 = EvaluateReview.suspect_reviews(review_list)
      assert length(top3) == 3
    else
      raise "cached file not present: #{cache_file_wayback_reviews}"
    end
  end
end
