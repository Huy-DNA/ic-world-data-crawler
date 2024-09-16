# typed: false
# frozen_string_literal: true

require 'sorbet-runtime'
require 'json'

extend T::Sig

def main
  file = File.open('data.txt', 'r')
  objs = JSON.parse file.read
  file.close
  File.open('formatted.json', 'w') do |file|
    file.write objs
  end
end

main
