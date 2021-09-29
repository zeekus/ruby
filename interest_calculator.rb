#!/usr/bin/ruby
#filename: example_compound_inflation.rb
#description: compound_inflation
#language: Ruby

iterations=20
x=0
inf=rand(7)
inflation_rate=(inf*0.01)
value=100000 #initial value
needed=value

def get_inflation_rate()
   inflation_rate=(rand(7)*0.01)
   if inflation_rate > 0.02
      return inflation_rate
   else
      return 0.02
   end
end

puts "Enter the start amount for the first year"
value=Integer(STDIN.gets())

until x > iterations
    inflation_rate=get_inflation_rate()
    puts "Year %2i adjusted value is %10i with the inflation rate of %3i. You will need %10i to keep the same standard of living." % [ x,value,(inflation_rate*100), needed ]
    x = x + 1
    needed = needed + ( needed * inflation_rate )
    value = value - ( value * inflation_rate)
end
