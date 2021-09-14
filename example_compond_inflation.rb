#!/usr/bin/ruby
#filename: example_compound_inflation.rb
#description: compound_inflation reverse interest
#language: Ruby

iterations=5
x=0
inflation_rate=(7.0*0.01) #7%
value=100000 #initial value

until x > iterations
    puts "#{x} value is #{value} inflation rate is #{(inflation_rate*100).to_i}"
    x = x + 1
    value = value - ( value * inflation_rate)
    #puts "#{x} value is #{value} inflation rate is #{(inflation_rate*100).to_i}"
end

   