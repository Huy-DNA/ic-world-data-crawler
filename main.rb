# frozen_string_literal: true

require 'selenium-webdriver'

puts 'Start session'

driver = Selenium::WebDriver.for :chrome

driver.navigate.to 'https://www.thegioiic.com/product/'

puts 'Navigated to www.thegioiic.com'

puts 'End session'

driver.quit
