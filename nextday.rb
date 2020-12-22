
#!/usr/bin/ruby
#language: Ruby
#filename: nextday.rb
#description: get nextday with time using machine time or a string 

require 'time'

def next_day(now)

    one_day_adv=(60 * 60 * 24) #one day in seconds
    
    if now.class == Time #convert to string
      mytoday=now.strftime("%m/%d/%Y") #regularize day into string
      puts "1 variable '#{mytoday}' is a  '#{mytoday.class}'"
    elsif now.class == String# assign variable
      mytoday=now
    end

    if mytoday.class == String #convert to Time
      mytoday=Time.strptime(mytoday,"%m/%d/%y") #convert back to machine time 
      puts "2 variable '#{mytoday}' is a  '#{mytoday.class}'"
      mytoday=mytoday+one_day_adv #increment one day 
      puts "3 variable '#{mytoday}' is a  '#{mytoday.class}'"
    end

    return mytoday #next day in time format 
   
end

now=Time.now
nextday=next_day(now).strftime("%m/%d/%Y") #convert to string from time
puts "#{nextday}"

nextday=next_day("12/31/20").strftime("%m/%d/%Y")
puts "#{nextday}"