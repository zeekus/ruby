#!/usr/bin/ruby
#language: Ruby
#filename: calculate_hour_needed_to_fullfil_timesheet.rb
#description: calc how many hours are needed to fufill the time period

start_of_pay_period="12/16/2020"  #start
end_of_pay_period="12/31/2020"  #end

require 'time'

my_start=Time.strptime(start_of_pay_period,"%m/%d/%y")
my_end=Time.strptime(end_of_pay_period,"%m/%d/%y")
now=Time.now
mytoday=now.strftime("%m/%d/%Y")

one_day_adv=(60 * 60 * 24) #one day in seconds

hours_completed=0
puts "length of ARGV array is: " + ARGV.length.to_s

#####################
#checking arguments
######################
if ARGV.length > 0 
   hours_completed=ARGV[0].to_i
   puts "hours completed entered with #{hours_completed}"
else
   puts "no hours completed"
   puts "hours completed entered with #{hours_completed}"
   
end


nextday=my_start
count=0

while true
  formatted=nextday.strftime("%m/%d/%Y")

  formatted="* #{formatted} *" if mytoday==formatted #when days match add this

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

puts "use: calculated_hours_needed_to_work.rb 20 #for 20 hours worked" 

puts "day count is #{count}"
hours_needed=count*8
puts "total hours needed for the period is #{hours_needed}"
puts "total hours completed is #{hours_completed}"
hours_remaining=hours_needed
hours_remaining=hours_remaining - hours_completed
puts "total hours remaining is #{hours_remaining}"

