# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require 'selenium-webdriver'

extend T::Sig

class LeafError < StandardError
end

class Item < T::Struct
  const :name, String
  const :sub_items, T::Array[Item]
  const :metadata, T::Hash[Symbol, T.anything]
end

sig { params(driver: Selenium::WebDriver::Chrome::Driver, link: String, level: Integer).returns(T::Array[Item]) }
def fetch_all_items_with(driver, link, level)
  driver.navigate.to link
  puts "#{' ' * level}Navigated to #{link}"
  res = driver.find_elements(css: '.box-item').map do |box|
    a = box.find_elements(tag_name: 'div')[1].find_element(tag_name: 'a')

    [a.text, a.attribute('href')]
  rescue Selenium::WebDriver::Error::WebDriverError
    raise LeafError, 'leaf page reached'
  end.map do |(text, href)|
    Item.new(name: text, sub_items: fetch_all_items_with(driver, href, level + 1), metadata: {})
  rescue LeafError
    driver.navigate.to href
    # fetch metadata here
    title_div = driver.find_element(css: '.product-title-show')
    img = driver.find_element(css: '#show-img')
    metadata = {}
    metadata[:thumbnail_url] = img.attribute('src')
    metadata[:title] = title_div.find_element(tag_name: 'h1').text
    metadata[:brand] = title_div.find_element(css: 'div > div:nth-child(1) span + *').text
    metadata[:manufacturer] = title_div.find_element(css: 'div > div:nth-child(2) span + *').text
    metadata[:description] = title_div.find_element(css: 'div > div:nth-child(3) span + *').text
    driver.find_elements(css: 'table tbody tr').each do |row|
      name = row.find_element(css: 'td:nth-child(1)').text
      value = row.find_element(css: 'td:nth-child(2)').text
      metadata[name.to_sym] = value
    rescue
    end
    Item.new(name: text, sub_items: [], metadata: metadata)
    puts metadata
    driver.navigate.back
  end
  res
ensure
  puts "#{' ' * level}Exitted from #{link}"
  driver.navigate.back
end

def main
  puts 'Start session'

  driver = Selenium::WebDriver.for :chrome

  items = fetch_all_items_with(driver, 'https://www.thegioiic.com/product/', 0)

  puts 'End session'

  puts items

  driver.quit
end

main
