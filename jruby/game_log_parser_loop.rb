#!/usr/bin/ruby
#filename: game_log_parser.rb
#description: function looks for active log file and then reads the messages. We only pull the relevant new data.
require 'time'



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

def log_reader()
 #####################
 #find latest log file
 #####################
 ##bash equivalent
 ##file=system("find /home/$USER/Documents/EVE/logs/Gamelogs -cmin -1 -exec ls -lah {} ';'")
 logfile_loc_glob="/home/zteddy/Documents/EVE/logs/Gamelogs/*.txt" #glob for all
 myfile=Dir.glob(logfile_loc_glob).max_by { |file_name| File.ctime(file_name) } 

 filesize=0  #get size of the file
 file=File.open(myfile,"r")
 filesize=file.readlines.size
 puts "'debug filesize has #{filesize}' lines"

 #only run if file size is greater than 5
 if filesize < 5
  puts "exiting. Listener is active but file is too small. Try exiting the station."
  exit
 end

 #get last 3 lines of the log
 last_3=IO.readlines(myfile)[-3..-1]
 last_3.each do |line|

   if /^\[/.match(line) #sometimes the lines don't have the time ignore them
     result=is_log_entry_current(line.chomp,counter) #current log entry only
     if result ==1
        string = line.split("(None) ")[1]#remove first part of line so just get the jumping info
        return string
     end
   end
  end
end

jump_complete=0
until jump_complete==1
  sleep 1
  parsed_log=log_reader()
  if parsed_log =~ /jumping/i 
    puts parsed_log
    jump_complete =1
  end
end