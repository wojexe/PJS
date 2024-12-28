require "nokogiri"
require "httpx"
require "addressable/uri"

require "pry"

require_relative "allegro_product"

class AllegroCrawler
  attr_reader :crawled_products

  PAGES_TO_CRAWL = 1

  BASE_PATH = URI("https://allegro.pl")
  LAPTOP_CATEGORY_FRAGMENT = "laptopy-491"

  PRODUCTS_SELECTOR = "div[data-prototype-id=\"layout.container\"]"

  TITLE_SELECTOR = "article h2"
  PRICE_SELECTOR = "article span[aria-label*=\"zł\"]"

  DESCRIPTION_SELECTOR = "div[data-prototype-id=\"allegro.showoffer.description\"]"

  NEXT_PAGE_SELECTOR = "a._13q9y._8hkto.mh36_0.mvrt_0._1yr5c.mpof_ki.m389_6m"

  HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.2 Safari/605.1.15",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Encoding" => "gzip, deflate, br",
    "Accept-Language" => "en-US,en;q=0.9",
    "Cookie" => "datadome=dByzrwwLKkQODZ7OY9333cza7EhRZzIw0ZmyWO9Cnyuklb2o95W5ap2N6eAFOlkBK7BoDkehxEB23HxTWKvukCeeCF9V_4A8TbNIcabcTbDsjDULZlKpRFk4muQBbCCj; OptOutOnRequest=groups=googleAnalytics:0,googleAdvertisingProducts:0,tikTok:0,allegroAdsNetwork:0,facebook:0; wdctx=v5.H9v26yYEO7J9FHME77z3Jnrf4JdTURLEhPyepn-lu_DG1ESqpo1_nT2W9-gq1lvsCPr5JueNreW-fy83C2M2q7dPU-CFzScBH6MQ2yB-feMxb25x0-3sH6M29e5wvw949KKIrvWhbbDtbgulF0WJaMigErxblw91HBfhG0-4W9NAFtFxXPahjAN8bHlE7vz5gGV-jyyld9MEg6IR9SXahu2QEAZgmwrKaLe1FuSYB6bM.PFcObqSAROePT0lAXRc4EQ.bc-vtYPOfXw; _cmuid=7553d845-0a3a-4412-bf20-b1f76dc0c58c",
    "Priority" => "u=0, i",
    "Referer" => "https://allegro.pl/kategoria/laptopy-491",
    "Sec-Fetch-Dest" => "document",
    "Sec-Fetch-Mode" => "navigate",
    "Sec-Fetch-Site" => "same-origin"
  }

  def initialize(database)
    @db = database
    @crawled_products = []
  end

  def crawl_laptops
    @crawled_products = []

    (1..PAGES_TO_CRAWL).each do |i|
      response = fetch(laptops: true, page: i)
      page = Nokogiri::HTML(response)
      products = crawl_page(page)

      @crawled_products = products

      sleep(5)
    end
  end

  def crawl_search(s)
    @crawled_products = []

    response = fetch(search: s)

    page = Nokogiri::HTML(response)
    products = crawl_page(page)

    @crawled_products = products
  end

  def crawl_page(html)
    products = html.css(PRODUCTS_SELECTOR)

    titles = products.css(TITLE_SELECTOR)
    prices = products.css(PRICE_SELECTOR)
    links = titles.css("a").map { |e| e["href"] }

    titles.zip(prices, links)
      .first(1)
      .map do |title, price, link|
      description = crawl_listing(link)
      sleep(5)

      AllegroProduct.create(
        title: title&.text,
        description: description,
        price: price&.text,
        link: link
      )
    end
  end

  def crawl_listing(link)
    response = fetch_listing(link)

    page = Nokogiri::HTML(response)
    description = page.css(DESCRIPTION_SELECTOR).first

    # Replaces all tags with newlines (even images and spans - since we don't parse the CSS)
    description.inner_html.gsub(/<[^>]*>/, "").strip
  end

  private

  def fetch(laptops: false, search: nil, page: nil)
    url = crawl_url(laptops:, search:, page:)

    puts "Fetching #{url.to_str}"

    http = HTTPX.plugin(:follow_redirects)

    response = http
      .with(headers: HEADERS)
      .get(url)

    unless response&.status&.< 400
      puts "Status: #{response.status}"
      puts "Headers: #{response.headers}"
      puts response.body

      raise StandardError.new("Status code >= 400")
    end

    response
  end

  def fetch_listing(url)
    http = HTTPX.plugin(:follow_redirects)

    puts "Fetching #{url}"

    response = http
      .with(headers: HEADERS)
      .get(url)

    unless response&.status&.< 400
      puts "Status: #{response.status}"
      puts "Headers: #{response.headers}"
      puts response.body

      raise StandardError.new("Status code >= 400")
    end

    response
  end

  def crawl_url(laptops: false, search: nil, page: nil)
    uri = Addressable::URI.parse(BASE_PATH)

    if laptops
      uri.path = "/kategoria/#{LAPTOP_CATEGORY_FRAGMENT}"
    end

    params = {}

    if search
      uri.path = "listing" unless laptops
      params[:string] = search
    end

    params[:p] = page if page.is_a? Numeric

    uri.query_values = params unless params.empty?

    uri
  end
end
