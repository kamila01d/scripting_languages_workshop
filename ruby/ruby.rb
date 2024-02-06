require 'nokogiri'
require 'open-uri'

class AmazonCrawler
  def initialize
    @base_url = 'https://www.amazon.com'
  end

  def scrape_products_in_category(category)
    category_url = "#{@base_url}/s?k=#{URI.encode_www_form_component(category)}"
    scrape_products(category_url)
  end

  def scrape_products_by_keywords(keywords)
    keywords_url = "#{@base_url}/s?k=#{URI.encode_www_form_component(keywords)}"
    scrape_products(keywords_url)
  end

  private

  def scrape_products(url)
    doc = Nokogiri::HTML(URI.open(url, 'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'))

    products = []

    doc.css('.s-result-item').each do |item|
      title = item.at_css('.a-text-normal')&.text
      price = item.at_css('.a-offscreen')&.text

      next unless title && price

      product = {
        title: title.strip,
        price: price.strip
      }

      products << product
    end

    products
  end
end


crawler = AmazonCrawler.new


category_products = crawler.scrape_products_in_category('laptop')
category_products.each do |product|
  puts "Category - Title: #{product[:title]}, Price: #{product[:price]}"
end

keywords_products = crawler.scrape_products_by_keywords('web camera')
keywords_products.each do |product|
  puts "Keywords - Title: #{product[:title]}, Price: #{product[:price]}"
end
