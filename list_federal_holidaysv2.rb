#!/usr/bin/ruby
#filename: list_us_federal_holidays.rb
#description: generate list of holiday work days for 100 years
#language: Ruby


require 'time'
time=Time.now

$debug=0 #debug global

#static holiday processor
def return_static_day(myday,day_map,human_label)

 static_day=myday
 my_1day=(60*60*24) #1 day in seconds

 #static holiday
 if ( myday.wday != day_map['sun']  and  myday.wday != day_map['sat'])  #not on a weekend
   static_day=("#{(myday).to_i}:#{human_label}")
 elsif myday.wday == day_map['sun'] #push Monday after
   static_day=("#{(myday+my_1day).to_i}:#{human_label} Monday After")
 elsif myday.wday == day_map['sat'] #Friday before
   static_day=("#{(myday-my_1day).to_i}:#{human_label} Friday Before")
 else
   #we shouldn't see anything here
 end
 return static_day
end 
 
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

  #add Christmas
  myday=Time.strptime("12/25/#{year}","%m/%d/%Y")
  my_christmas=return_static_day(myday,day_map,"Christmas")
  holiday_list.push(my_christmas)
  

  #Thanksgiving 4th Thursday of every November
  myday=Time.strptime("11/01/#{year}","%m/%d/%Y")
  my_day=return_day(myday,target_day=day_map['thu'],4) #Target get 4th Thursday of month
  holiday_list.push("#{my_day.to_i}:Thanksgiving")

  #Veterans day static 11/11
  my_start=Time.strptime("11/11/#{year}","%m/%d/%Y")
  my_day=return_static_day(my_start,day_map,"Veterans day")
  holiday_list.push(my_day)

  #Columbus Day ( 2nd Monday in October) 
  my_start=Time.strptime("10/01/#{myday.year}","%m/%d/%Y")
  my_day=return_day(my_start,target_day=day_map['mon'],2) #Target get 2nd Tue of month
  holiday_list.push("#{my_day.to_i}: Columbus Day")

  #Labor day ( First Monday in Sept) 
  my_start=Time.strptime("9/01/#{myday.year}","%m/%d/%Y")
  my_day=return_day(my_start,target_day=day_map['mon'],1) #Target get 1st Mon of month
  holiday_list.push("#{my_day.to_i}: Labor Day")

  #Independence Day
  my_start=Time.strptime("7/04/#{myday.year}","%m/%d/%Y")
  my_i=return_static_day(my_start,day_map,"Independence Day")
  holiday_list.push(my_i)

  #Memorial Day ( last monday in may) 
  my_start=Time.strptime("5/1/#{year}","%m/%d/%Y")
  my_day=return_last_day(my_start,target_day=day_map['mon'])
  holiday_list.push("#{my_day.to_i}:Memorial day")

  #Washingon's Birthday ( Third Monday Feb ) 
  my_start=Time.strptime("2/1/#{year}","%m/%d/%Y")
  my_day=return_day(my_start,target_day=day_map['mon'],3) #Target get 3rd Mon of month
  holiday_list.push("#{my_day.to_i}:Washington's Birthday")

  #Martin Luther King Jr. Birthday ( Third Monday Jan ) 
  my_start=Time.strptime("1/3/#{year}","%m/%d/%Y")
  my_day=return_day(my_start,target_day=day_map['mon'],3) #Target get 3rd Mon of month
  holiday_list.push("#{my_day.to_i}:Martin Luther King's Birthday")

  #new years static 1/1
  myday=Time.strptime("1/1/#{year}","%m/%d/%Y")
  my_new=return_static_day(myday,day_map,"New Years Day")
  holiday_list.push(my_new)

  return holiday_list
  
end


my_holidays=[] #list of holidays

for year in 2020..2220
   tmp_list=[]
   tmp_list=holiday_rules_us(year)
   my_holidays.push(tmp_list.sort)
end

my_holidays.flatten.each do |line|
  tmp=line.split(/:/) #elment is an array
  #my_start=Time.strptime("10/01/#{myday.year}","%m/%d/%Y")
  #humanlike=Time.at(tmp[0])
  #puts tmp[0].to_i
  mytime=Time.at(tmp[0].to_i) 
  formatted=mytime.strftime("%m/%d/%Y")
  puts "#{formatted}: #{tmp[1].strip}"
end


#for line in my_holidays 
#  puts line
#  tmp=line.split(":")[1] 
#end

