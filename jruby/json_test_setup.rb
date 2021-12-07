#!/usr/bin/ruby
#filename: json_test_setup.rb
#description reads in data and tests to makes sure it is accessible and we can find the deefined points.
#

require 'java'
require 'json'

my_json_file=("/var/tmp/locations.json")
if File.exist?(my_json_file)
  #puts "file exits. opening file..."
  file = File.read(my_json_file)
  data_hash = JSON.load(file)
  for key,value in data_hash
     puts "#{key} => #{value}"
  end
end

#extract x and y from object
x,y=data_hash["yellow_icon_left_top"]
puts "#{x},#{y}"

#extract array
xy=[]
xy=data_hash["yellow_icon_left_top"]
puts "#{xy}"