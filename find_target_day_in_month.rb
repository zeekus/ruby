#!/usr/bin/ruby
#filename: find_target_day_in_month.rb
#description: target a specific day
#author: Theodore Knab
#date: 12/01/2020

require 'time'
myday=Time.now
$debug=1

day_map={ "sun" => 0, 
          "mon" => 1, 
          "tue" => 2, 
          "wed" => 3 ,
          "thu" => 4, 
          "fri" => 5, 
          "sat" => 6
}

def return_day(my_start,target_day=day_map[mon],result_count)
  count=1                    #counter
  one_day_adv=(60 * 60 * 24) #one day in seconds
  nextday=my_start 
  if $debug ==1
    puts "debug: my_start is #{my_start}"
    puts "debug: my_start month is #{my_start.month}"
    puts "debug: target_day is #{target_day}"
    puts "debug: nextday month is #{nextday.month}"
    puts "debug: result_count is #{result_count}"
  end
  
  while my_start.month==nextday.month
    puts "#{nextday.day}: DEBUG  #{nextday}" if $debug == 1
    if nextday.wday == target_day
      puts "#{nextday.day}:  #{count} TARGET FOUND : monday #{nextday}" if $debug==1
      if count == result_count
        puts "DEBUG: *returning* #{nextday}" if $debug==1
        return nextday
      else
        count=count+1
      end
    end
    nextday=nextday+one_day_adv
  end
  
end


string_time="02/1/#{myday.year}"
my_start=Time.strptime(string_time,"%m/%d/%Y")
nextday=my_start
my_day=return_day(nextday,target_day=day_map['mon'],3) #Target get 3rd Monday of the Month
puts my_day 
exit

#count=1
#target_array=[]
#one_day_adv=(60 * 60 * 24) #one day in seconds

#  while my_start.month==nextday.month
#    #puts nextday
#    #if nextday.monday? 
#    if nextday.wday == day_map['mon']
#        puts "#{count}: monday #{nextday}" 
#        target_array.push(nextday)
#        count=count+1
#    end
#    nextday=nextday+one_day_adv
#  end
  

