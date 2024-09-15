# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require 'selenium-webdriver'

extend T::Sig

class Item < T::Struct
  const :name, String
  const :sub_items, T::Array[Item]
  const :metadata, T::Hash[String, T.anything]
end

sig { params(driver: Selenium::WebDriver::Chrome::Driver, link: String, level: Integer).returns(T::Array[Item]) }
def fetch_all_items_with(driver, link, level)
  driver.navigate.to link
  puts "#{' ' * level}Navigated to #{link}"
  res = driver.find_elements(css: '.box-item').map do |box|
    a = box.find_elements(tag_name: 'div')[1].find_element(tag_name: 'a')
    [a.text, a.attribute('href')]
  end.map do |(text, href)|
    Item.new(name: text, sub_items: fetch_all_items_with(driver, href, level + 1), metadata: {})
  end
  puts "#{' ' * level}Exitted from #{link}"
  driver.navigate.back
  res
end

def main
  puts 'Start session'

  driver = Selenium::WebDriver.for :chrome

  fetch_all_items_with(driver, 'https://www.thegioiic.com/product/', 0)

  puts 'End session'

  driver.quit
end

main
