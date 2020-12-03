#!/usr/bin/ruby
#filename: list_us_federal_holidays.rb
#description: generate list of holiday work days for 100 years
#language: Ruby

require 'time'
time=Time.now

$debug=0 #debug global

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

def return_last_day(my_start,target_day=day_map[mon])
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
      my_start = nextday #last
      if count == 99 #last 
        puts "DEBUG: *returning* #{nextday}" if $debug==1
        return nextday
      else
        count=count+1
      end
    end
    nextday=nextday+one_day_adv
  end

  return my_start
end

def holiday_rules_us(year)
  holiday_list=[]
  debug=1

  #####################
  #human readable times
  #####################
  day_map={ "sun" => 0, 
          "mon" => 1, 
          "tue" => 2, 
          "wed" => 3 ,
          "thu" => 4, 
          "fri" => 5, 
          "sat" => 6
  }


  myday=Time.strptime("12/25/#{year}","%m/%d/%Y")
  #Christmas static 12/25
  if myday.month == 12 and ( myday.day==25) 
   holiday_list.push("12/25/#{year}: Christmas Day")        if ( myday.wday != day_map['sun']  and  myday.wday != day_map['sat']  and myday.day ==25 ) #push standard if not a week day
   holiday_list.push("12/26/#{year}: Christmas Monday off") if ( myday.day  == 25 and  myday.wday == day_map['sun'] ) #push Monday after  Sunday   12/25
   holiday_list.push("12/24/#{year}: Christmas Eve off")   if ( myday.day  == 25 and  myday.wday == day_map['sat'] ) #push Friday before Saturday 12/25
  end

  #Thanksgiving 4th Thursday of every November
  my_start=Time.strptime("11/1/#{year}","%m/%d/%Y")
  my_day=return_day(my_start,target_day=day_map['thu'],4) #Target get 4th Thursday of month
  formatted=my_day.strftime("%m/%d/%Y")
  holiday_list.push("#{formatted}: Thanksgiving")

  #Veterans day static 11/11
  myday=Time.strptime("11/11/#{year}","%m/%d/%Y")
  if myday.month == 11 and myday.day==11  
    holiday_list.push("11/11/#{year}: Veterans day proper") if ( myday.wday != day_map['sat']  and  myday.wday != day_map['sun']  and myday.day ==11 ) #push standard if not a week day
    holiday_list.push("11/12/#{year}: Veterans day after.") if ( myday.day  == 11 and  myday.wday == day_map['sun'] ) #push Monday after Sunday 11/11
    holiday_list.push("11/10/#{year}: Vetrans day eve")     if ( myday.day  == 11 and  myday.wday == day_map['sat'] ) #push Friday before Saturday 11/11
  end

  #Columbus Day ( 2nd Monday in October) 
  my_start=Time.strptime("10/1/#{myday.year}","%m/%d/%Y")
  my_day=return_day(my_start,target_day=day_map['mon'],2) #Target get 2nd Tue of month
  formatted=my_day.strftime("%m/%d/%Y")
  #holiday_list.push(formatted)
  holiday_list.push("#{formatted}: Columbus Day")

  #Labor day ( First Monday in Sept) 
  my_start=Time.strptime("9/1/#{myday.year}","%m/%d/%Y")
  my_day=return_day(my_start,target_day=day_map['mon'],1) #Target get 1st Mon of month
  formatted=my_day.strftime("%m/%d/%Y")
  holiday_list.push("#{formatted}: Labor Day")

  #Independence Day
  myday=Time.strptime("07/04/#{year}","%m/%d/%Y")
  if myday.month == 7 and  myday.day== 4  
    if myday.wday !=day_map['sun'] and myday.wday !=day_map['sat'] #regular day 
       holiday_list.push("07/04/#{year}: Independence Day" )
    elsif myday.wday == day_map['sun'] #Sunday
       my_day=("07/05/#{year}: Monday July 5th Independence Day")
       holiday_list.push(my_day)
    elsif myday.wday == day_map['sat'] #Friday
       my_day=("07/03/#{year}: Friday July 3rd Independence Day")
       holiday_list.push(my_day)
    else
      puts "error in Indep day logic"
      exit
    end
  end

  #Memorial Day ( last monday in may) 
  my_start=Time.strptime("5/1/#{year}","%m/%d/%Y")
  my_day=return_last_day(my_start,target_day=day_map['mon'])
  formatted=my_day.strftime("%m/%d/%Y")
  #holiday_list.push(formatted)
  holiday_list.push("#{formatted}: Memorial day")

  #Washingon's Birthday ( Third Monday Feb ) 
  my_start=Time.strptime("2/1/#{year}","%m/%d/%Y")
  my_day=return_day(my_start,target_day=day_map['mon'],3) #Target get 3rd Mon of month
  formatted=my_day.strftime("%m/%d/%Y")
  holiday_list.push("#{formatted}: Washington's Birthday")

  #Martin Luther King Jr. Birthday ( Third Monday Jan ) 
  my_start=Time.strptime("1/3/#{year}","%m/%d/%Y")
  my_day=return_day(my_start,target_day=day_map['mon'],3) #Target get 3rd Mon of month
  formatted=my_day.strftime("%m/%d/%Y")
  holiday_list.push("#{formatted}: Martin Luther King's Birthday")

  #new years static 1/1
  myday=Time.strptime("1/1/#{year}","%m/%d/%Y")
  if myday.wday !=day_map['sun'] and myday.wday !=day_map['sat'] #regular day 
    my_day=("01/01/#{year}: Happy New Year")
    holiday_list.push(my_day )
  elsif myday.wday == day_map['sun'] #Sunday
    my_day=("01/02/#{year}: Happy Monday after Year")
    holiday_list.push(my_day )
  else #Friday
   #work around for ordering issue
   year_before=year-1
   tmp=[]
   tmp.push("12/31/#{year_before}: Friday New Year's Eve")
   holiday_list = tmp + holiday_list.sort
   for list in holiday_list
     puts "DEBUG ODD #{list}"
   end
   return (holiday_list) #pre sorted  #for odd holiday
  end


  #return formatted if ( myday.month==1 and ( myday.day < 23 and myday.day > 14 )  and myday.wday==1) #Memorial day
  return holiday_list.sort
  
end


my_holidays=[] #list of holidays

for year in 2020..2220
   tmp_list=holiday_rules_us(year).sort! 
   my_holidays.push(tmp_list)
end

for line in my_holidays
  puts line
end

