#!/usr/bin/ruby
#find_the_number_closest_to_ours.rb

my_number = 40
array_of_numbers = [20, 30, 45, 50, 56, 60, 64, 80]
result = array_of_numbers.min_by{|x| (my_number-x).abs}
puts result
