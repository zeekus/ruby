#!/usr/bin/ruby
#filename: list_us_federal_holidays.rb
#description: generate list of holiday work days for 13 years

period_s="01/01/2020"  #start
period_e="12/31/2033"  #end

require 'time'
time=Time.now

def holiday_rules_us(myday)
  debug=1
   
  #formated day
  formatted=myday.strftime("%m/%d/%Y")
  puts "my date is #{formatted}" if debug == 1

  if debug ==1 
    # Components of a Time
    puts "Current Time : #{myday}"
    puts "year:    :#{myday.year}"   # => Year of the date 
    puts "month      :#{myday.month}"   # => Month of the date (1 to 12)
    puts "day        :#{myday.day}"     # => Day of the date (1 to 31 )
    puts "wday       :#{myday.wday}"    # => 0: Day of week: 0 is Sunday
    #puts "yday       :#{myday.yday}"    # => 365: Day of year
    #puts "hour       :#{myday.hour}"    # => 23: 24-hour clock
    #puts "min        :#{myday.min}"     # => 59
    #puts "sec        :#{myday.sec}"     # => 59
    #puts "time usec  :#{myday.usec}"    # => 999999: microseconds
    #puts "zone       :#{myday.zone}"    # => "UTC": timezone name
    #puts "year:      :#{myday.year}"    # => Year of the date 
  end
   
  
  #Christmas static 12/25
  if myday.month == 12 and ( myday.day==24 or myday.day==25 or myday.day==26 ) 
   return ("12/25/#{myday.year}") if ( myday.wday != 0  and  myday.wday != 6 and myday.day ==25 ) #push standard if not a week day
   return ("12/26/#{myday.year}") if ( myday.day  == 25 and  myday.wday == 0 ) #push Monday after  Sunday   12/25
   return ("12/24/#{myday.year}") if ( myday.day  == 25 and  myday.wday == 6 ) #push Friday before Saturday 12/25
  end


  #4th Thursday of every November
  return(formatted) if ( myday.month == 11 and ( myday.day > 21 and myday.day <=28 ) and myday.wday==4)  #Thanksgiving

  #Veterans day static 11/11
  if myday.month == 11 and ( myday.day==10 or myday.day==11 or myday.day==12 ) 
    return ("11/11/#{myday.year}") if ( myday.wday != 0  and  myday.wday != 6 and myday.day ==11 ) #push standard if not a week day
    return ("11/12/#{myday.year}") if ( myday.day  == 11 and  myday.wday == 0 ) #push Monday after Sunday 11/11
    return ("11/10/#{myday.year}") if ( myday.day  == 11 and  myday.wday == 6 ) #push Friday before Saturday 11/11
  end

  #Columbus Day ( 2nd Monday in October) 
  if myday.month == 10  and myday.wday==1
    if myday.day > 7 and  myday.day < 15
      return (formatted) 
    end
  end

  #Labor day ( First Monday in Sept) 
  if myday.month == 9  and myday.wday==1
    if myday.day < 7 
      return (formatted) 
    end
  end

  #indep day static 7/4
  if myday.month == 7 and  myday.day== 4  
    if myday.wday !=0 and myday.wday !=6 #regular day 
       return ("07/04/#{myday.year}") 
    elsif myday.wday == 0 #Sunday
       return ("07/05/#{myday.year}") 
    elsif myday.wday == 6   #Friday
       return ("07/03/#{myday.year}") 
    else
      puts "error in Indep day logic"
      exit
    end
  end

  #Memorial Day ( last monday in may) 
  #31 -7 = 24
  return formatted if ( myday.month==5 and myday.day > 23 and myday.wday==1) #Memorial day

  return formatted if ( myday.month==2 and ( myday.day < 23 and myday.day > 14 )  and myday.wday==1) #Memorial day
  #Washingon's Birthday ( Third Monday Feb ) 
  #todo

  #Martin Luther King Jr. Birthday ( Third Monday Jan ) 
  return formatted if ( myday.month==1 and ( myday.day < 23 and myday.day > 14 )  and myday.wday==1) #Memorial day
  
end


my_start=Time.strptime(period_s,"%m/%d/%Y")
my_end=Time.strptime(period_e,"%m/%d/%Y")

puts "start #{my_start}"
puts "myend #{my_end}"

one_day_adv=(60 * 60 * 24) #one day in seconds


nextday=my_start
count=0
my_holidays=[]

debug=0

while true
  formatted=nextday.strftime("%m/%d/%Y")
  holiday=holiday_rules_us(nextday)
  if holiday.to_s.length > 1
    puts "holiday on #{holiday}" if debug==1
    my_holidays.push(holiday) 
  end
  nextday=nextday+one_day_adv

  if nextday >  my_end
    puts "exiting with #{nextday} and #{my_end}"
    break
  end

end

puts "day count is #{count}"
#hours_needed=count*8
#puts "hour count is #{hours_needed}"

for line in my_holidays
  puts line
end
