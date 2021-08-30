#!/usr/bin/ruby
#lang: ruby
#filename: format_decimal.rb
#description: format numbers 

#credits: Rick Moore 
#source https://dirklo.medium.com/formatting-number-strings-in-ruby-4da35d5282e3
def format_number(number)
    whole, decimal = number.to_s.split(".")
    num_groups = whole.chars.to_a.reverse.each_slice(3)
    whole_with_commas = num_groups.map(&:join).join(',').reverse
    [whole_with_commas, decimal].compact.join(".")
end

n=(8.5+6.1) * 500000.01

#format as decimal float
puts format_number('%.2f' % n)
