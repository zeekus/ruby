#!/usr/bin/ruby
#filename: cash_out_senario.rb
#description: calculate tax and reinvest senarios. 
#

price_object=[ 165000, 201000, 349000, 450000 ]
sell_coins=STDIN.gets.chomp()


#credits: Rick Moore 
#source https://dirklo.medium.com/formatting-number-strings-in-ruby-4da35d5282e3
def format_number(number)
    whole, decimal = number.to_s.split(".")
    num_groups = whole.chars.to_a.reverse.each_slice(3)
    whole_with_commas = num_groups.map(&:join).join(',').reverse
    [whole_with_commas, decimal].compact.join(".")
end


for x in price_object
  #format as decimal float
  puts "--------------------"
  after_tax  = ( x.to_f * sell_coins.to_f * 0.50 )
  buy_back=( x.to_f * 0.3)
  puts "1) object price " + format_number('%.2f' % x)
  expected_retrace =  after_tax.to_f / buy_back.to_f
  puts "2) after tax for sell of #{sell_coins.to_i} object:" + format_number('%.2f' % after_tax)
  puts "3) " + format_number('%.4f' % expected_retrace) + " object @ #{buy_back}"
end


