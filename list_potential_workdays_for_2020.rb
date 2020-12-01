#!/usr/bin/ruby
#filename: list_potential_workdays_for_2020.rb
#description: generate list of potential work days for 2020
#note holidays are not in this list

period_s="01/01/2020"  #start
period_e="12/31/2020"  #end

require 'time'

my_start=Time.strptime(period_s,"%m/%d/%y")
my_end=Time.strptime(period_e,"%m/%d/%y")

one_day_adv=(60 * 60 * 24) #one day in seconds


nextday=my_start
count=0

while true
  formatted=nextday.strftime("%m/%d/%Y")
  puts "#{formatted} is Mon"  if nextday.monday? 
  puts "#{formatted} is Tue"  if nextday.tuesday? 
  puts "#{formatted} is Wed"  if nextday.wednesday? 
  puts "#{formatted} is Thu" if nextday.thursday? 
  puts "#{formatted} is Fri" if nextday.friday? 
  count=count+1 if nextday.saturday? != true and nextday.sunday? != true
  nextday=nextday+one_day_adv

  if nextday >  my_end
    break
  end

end

puts "day count is #{count}"
hours_needed=count*8
puts "hour count is #{hours_needed}"
