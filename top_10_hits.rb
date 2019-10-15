#!/usr/bin/env ruby
#file_name: top_10_hiters.rb
#description: gets Top 10 requests by IPAddress per hour.
#
$debug=0
def getlogs(myhour,mytime,my_day)
   require 'socket'
   my_year=mytime.year
   my_month=mytime.month
   my_cur_hour=mytime.hour
   months=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
   mcount=1
   my_hostname=Socket.gethostname
   my_host=my_hostname.split(".")[0]

   for mon in months

        if ( ( "#{my_month}" == "0#{mcount}" ) or ( "#{my_month}" == "#{mcount}")  )
           puts "hit: month=#{mon}, my_month=#{my_month}, mcount=#{mcount}, my_day=#{my_day},myhour=#{myhour}" if $debug==1
           string_date="#{my_day}/#{mon}/#{my_year}:#{myhour}"


           if (my_cur_hour.to_i >= myhour.to_i )#only parse logs for times that passed
             my_lines=[]
             puts "------------------------------- TOP 10 IPADDRESS requesting data from #{my_hostname} #{string_date} --------------------------------------" #header

             if (my_host =~ /train/)
               cmd1="sudo cat /var/log/httpd/train.access.log" + "|" + "grep " + string_date + ": | "  + 'sed -e s/\ -.*//g | sort -n' + "|" + "uniq -c | sort -n | tail -10" #get top 10 IPS by hour
             elsif (my_host =~ /test/)
               cmd1="sudo cat /var/log/httpd/test.access.log" + "|" + "grep " + string_date + ": | "  + 'sed -e s/\ -.*//g | sort -n' + "|" + "uniq -c | sort -n | tail -10" #get top 10 IPS by hour
             else
               cmd1="sudo cat /var/log/httpd/live.access.log" + "|" + "grep " + string_date + ": | "  + 'sed -e s/\ -.*//g | sort -n' + "|" + "uniq -c | sort -n | tail -10" #get top 10 IPS by hour
             end
             puts "running: #{cmd1}" if $debug ==1
             my_lines=`#{cmd1}`.rstrip() #command 1 strip trailing white space if any
             #display output to screen
             for line in my_lines
               puts line
             end
           end
        end
     mcount+=1
   end
end

def get_last_5_days (today)
   my_day=""
   for x in 1..5
      my_day=(mytime.day-x)
	  puts "my day is #{my_day}"
   end
end

mytime=Time.now
today=mytime.day
get_last_5_days(today)

my_tmp_hr=""

for x in 00..24
  if x < 10
    puts "0#{x}" if $debug==1
    my_tmp_hr="0#{x}"
  else
    puts "#{x}" if $debug==1
    my_tmp_hr="#{x}"
  end
 getlogs(my_tmp_hr,mytime,today)
end
