#!/usr/bin/ruby
#filename: game_log_parser.rb
#description: function looks for active log file and then reads the messages. We only pull the relevant new data.
require 'time'

logfile_loc_glob="/home/zeek/Documents/EVE/logs/Gamelogs/*.txt" #glob for all

def is_log_entry_current(loginfo,counter)
  debug=0

  #string stripping 
  logtime=loginfo.gsub(/\(.*/,"").chomp                   #remove everything after the "(" character in the line
  logtime=loginfo.gsub(/(\[|\])/,"").chomp.strip          #remove brackets around the string and extra spaces aound the string

  #converting log time to usable format. Time source from log looks like [ 2021.12.02 19:21:20 UTC ].
  #Log example: [ 2021.12.01 21:50:52 ] (question) Are you sure you want to quit the game?
  logtime=DateTime.strptime(logtime, '%Y.%m.%d %H:%M:%S') #convert logtime sting to usable variable
  logtime_secs=logtime.strftime("%s")                     #convert time to seconds
  puts "debug log time- logtime_secs #{logtime_secs}" if debug==1


  current_secs=Time.now.utc.strftime("%s")                #our logs get current time in UTC seconds
  puts "debug - current_secs #{current_secs}" if debug==1
  diff=current_secs.to_i-logtime_secs.to_i                #calculate time diff in seconds from logs time to current time
  puts "debug: diff is #{diff}" if debug==1
  if diff < 10
    return 1 
  else
    return 0
  end
end


#####################
#find latest log file
#####################
##bash equivalent
##file=system("find /home/$USER/Documents/EVE/logs/Gamelogs -cmin -1 -exec ls -lah {} ';'")
myfile=Dir.glob(logfile_loc_glob).max_by { |file_name| File.ctime(file_name) } 

#get size of the file
filesize=0
file=File.open(myfile,"r")
filesize=file.readlines.size

puts "'debug filesize has #{filesize}' lines"

#only run if file size is greater than 5
if filesize < 5
  puts "exiting. Listener is active but file is too small. Try exiting the station."
  exit
else 
  puts "checking last 10 lines"
end

puts "logfile is #{myfile}"

#get last 25 lines of the log
last_10=IO.readlines(myfile)[-10..-1]

counter=0
old_results=0

last_10.each do |line|
  if /^\[/.match(line) #sometimes the lines don't have the time ignore them 
    result=is_log_entry_current(line.chomp,counter)
    if result==1
      counter=counter+1
      puts "new: #{line}"
    else 
      old_results=old_results+1
      #puts "old log entry #{line}" 
    end
  end
end

if old_results > 0
  puts "We found #{old_results} old messages in the logs"
  puts "We found #{counter} current messages in the logs"
else 
  puts "We found #{counter} current messages in the logs"
end
