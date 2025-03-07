#!/usr/bin/env ruby

require "pry"
require "nokogiri"
require "httpx"

require_relative "sequel_database"
database = initialize_database

require_relative "allegro_crawler"
crawler = AllegroCrawler.new(database)

crawler.crawl_laptops
puts "Crawled laptops category: #{crawler.crawled_products.count}"

crawler.crawl_search("laptop dell")
puts "Crawled search results for 'laptop dell': #{crawler.crawled_products.count}"

pp crawler.crawled_products

binding.pry
