#!/usr/bin/ruby
#filename: example_compound_inflation2.rb
#description: compound_inflation
#language: Ruby

def get_inflation_rate()
   #assume a inflation rate between 2% and 7%
   inflation_rate=(rand(7)*0.01)
   if inflation_rate > 0.02
      return inflation_rate
   else
      return 0.02
   end
end

iterations=20
x=0

inf=get_inflation_rate()
inflation_rate=(inf*0.01)

puts "Enter the start amount for the first year"
value=Integer(STDIN.gets())

needed=value

until x > iterations
    inflation_rate=get_inflation_rate()
    puts "Year %2i adjusted value is %10i with the inflation rate of %3i. You will need %10i to keep the same standard of living." % [ x,value,(inflation_rate*100), needed ]
    x = x + 1
    needed = needed + ( needed * inflation_rate )
    value = value - ( value * inflation_rate)
end
