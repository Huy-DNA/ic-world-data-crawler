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

sig { params(driver: Selenium::WebDriver::Chrome::Driver).returns(T::Array[Item]) }
def fetch_all_items_with(driver)
  driver.find_elements(css: '.box-item').map do |e|
    Item.new(name: '', sub_items: [], metadata: {})
  end
end

def main
  puts 'Start session'

  driver = Selenium::WebDriver.for :chrome

  driver.navigate.to 'https://www.thegioiic.com/product/'

  puts 'Navigated to www.thegioiic.com'

  fetch_all_items_with driver

  puts 'End session'

  driver.quit
end

main
