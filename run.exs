filename = ".cache/all.live.reviews.bin"
if(File.exists?(filename) == false) do
  page1 = "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/"
  page2 = "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/page2"
  page3 = "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/page3"
  page4 = "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/page4"
  page5 = "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/page5"
  reviews = EvaluateReview.scrape(page1)
  reviews = reviews ++ EvaluateReview.scrape(page2)
  reviews = reviews ++ EvaluateReview.scrape(page3)
  reviews = reviews ++ EvaluateReview.scrape(page4)
  reviews = reviews ++ EvaluateReview.scrape(page5)
  EvaluateReview.cache(reviews, filename)
  IO.puts("current data pulled and cached")
else
  IO.puts("using cached data")
end

reviews = EvaluateReview.load_from_cache(filename)

top3 = EvaluateReview.suspect_reviews(reviews)
IO.inspect(top3)