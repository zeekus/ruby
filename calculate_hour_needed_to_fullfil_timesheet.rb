#!/usr/bin/ruby
#language: Ruby
#filename: calculate_hour_needed_to_fullfil_timesheet.rb
#description: calc how many hours are needed to fufill the time period
require 'time'

def get_todays_number(now)
 
  if now.sunday?
    return 0
  elsif now.monday?
    return 1
  elsif now.tuesday?
    return 2
  elsif now.wednesday?
    return 3
  elsif now.thursday?
    return 4
  elsif now.friday?
    return 5
  elsif now.saturday?
    return 6
  end
end

def get_monday(day_value)
    
    if day_value == 1    #monday
       puts monday
       return Time.now
    elsif day_value < 1  #sunday
       puts sunday
       return Time.now() + (60*60*24) 
    elsif day_value > 1
      return Time.now() - ((day_value-1) * (60*60*24))
    else
      exit 1 
    end
end

def get_friday(day_value)
    if day_value == 5  #friday
       return Time.now
    elsif day_value < 5  
      return Time.now() + ( (5-day_value) * (60*60*24))
    else
      return Time.now() - ((day_value-5) * (60*60*24))
    end
end


now=Time.now
get_week=Time.now().strftime "%W"
todays_num=get_todays_number(now)

puts "now is #{now}"
puts "week is #{get_week}"
puts "today's number is #{todays_num}" 

start_of_pay_period=get_monday(todays_num).strftime('%m/%d/%Y')
end_of_pay_period=get_friday(todays_num).strftime('%m/%d/%Y')

puts "start #{start_of_pay_period}"
puts "end #{end_of_pay_period}"


#start_of_pay_period="10/11/2021"  #start
#end_of_pay_period="10/15/2021"  #end



my_start=Time.strptime(start_of_pay_period,"%m/%d/%Y")
my_end=Time.strptime(end_of_pay_period,"%m/%d/%Y")
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
hours=0

while true
  formatted=nextday.strftime("%m/%d/%Y")
  formatted_text=""

  #puts "debug nextday is #{nextday}"

  if nextday.monday?
    formatted_text = "#{formatted} is Monday #{hours}"
  elsif nextday.tuesday?
    formatted_text = "#{formatted} is Tuesday #{hours}"
  elsif  nextday.wednesday?
    formatted_text = "#{formatted} is Wednesday #{hours}"
  elsif nextday.thursday?
    formatted_text = "#{formatted} is Thursday #{hours}"
  elsif nextday.friday?
    formatted_text = "#{formatted} is Friday #{hours}"
  else
    "Warning: day not counted"
  end
  hours=hours+8 if nextday.saturday? != true and nextday.sunday? != true

  #append today to formatted_text when today   
  formatted_text="#{formatted_text} * Today * " if mytoday==formatted #when days match add this
  
  #counter add next day only count monday - friday
  count=count+1 if nextday.saturday? != true and nextday.sunday? != true
  puts "#{count} #{formatted_text}" if nextday.saturday? != true and nextday.sunday? != true
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

