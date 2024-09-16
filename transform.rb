# typed: false
# frozen_string_literal: true

require 'sorbet-runtime'
require 'json'

extend T::Sig

def main
  file = File.open('data.txt', 'r')
  objs = JSON.parse file.read
  file.close

  objs.each_with_index do |obj, i|
    File.open("formatted/#{i}.json", 'w') do |file|
      file.write obj
    end
  end
end

main
