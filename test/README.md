Web Traffic is monitored and inspected regularly by agencies from many countries all around the world. 
Search engines and service providers track everything from IP addresses to DNS lookups. Too much scraping
would set off alerts and alarm whistles in any company who takes security seriously. 

So as to avoid further suspicion, the test suite does not scrape dealerrater.com directly. 

Instead, the test suite will pull from archive.org's way back machine. As of this writing, the most recent
snapshot taken was in November of 2020. The way back machine has an api to verify the availability 
of a given site, and the first test in the suite confirms that the archive is available *and*
that the reviews present in cache are not up to date. 

This application includes a simple caching system to minimize to the greatest possible extent 
the risk of alerting the various actors involved in this scrape. 

To clear the cache, simply delete the files in ./cache/

Scraping dealerrater.com directly is reserved for those employing the application. 

An example url from the way back machine looks like:

```
https://web.archive.org/web/20201127110830/https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/
```

unfortunately, the way back machine only has a copy of the first page of reviews. Information gained from the first
page should be sufficient for testing any additional pages as the structure of each additional page is the same
