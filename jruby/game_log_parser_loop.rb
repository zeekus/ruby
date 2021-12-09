#!/usr/bin/ruby
#filename: game_log_parser.rb
#description: function looks for active log file and then reads the messages. We only pull the relevant new data.
require 'time'

def is_log_entry_current(loginfo)
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
  if diff < 60 #60 seconds should be safe
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
 my_homedir=Dir.home
 logfile_loc_glob="#{my_homedir}/Documents/EVE/logs/Gamelogs/*.txt" #glob for all

 myfile=Dir.glob(logfile_loc_glob).max_by { |file_name| File.ctime(file_name) } 
 if File.exists?(myfile)
   puts "debug my last log is #{myfile}"
   file=File.open(myfile) #read file
   file_data=file.readlines.map(&:chomp) #attemping to get file data without new lines
   file.close #closing file
   filesize=0  #get size of the file
   filesize=file_data.size
   puts "'debug gamelog file has #{filesize}' lines"
   #only run if file size is greater than 5
   if filesize < 5
    puts "exiting. Listener is active but file is too small. Try exiting the station."
    exit
   end
 else 
   puts "missing file #{myfile} exiting"
   exit
 end
 
#  puts "is file_data an array ?"
#  p file_data.instance_of? Array

 last_3=file_data[-3..-1]  #get last 3 lines of the file_data
#  puts "is last_3 an array ?"
#  p last_3.instance_of? Array

 last_3.each do |line|  #look at it
   if /^\[/.match(line) #sometimes the lines don't have the time ignore them
     result=is_log_entry_current(line.chomp) #current log entry only
     if result ==1
        string = line.split("(None) ")[1]#remove first part of line so just get the jumping info
        # puts "is string an array ?"
        # p string.instance_of? Array
        return string
     end
   end
  end
  return "" #return an empty string to prevent an object pointer from getting returned and messsing up things
end

  
  #start of prototype loop
  jump_complete=0
  until jump_complete==1
    sleep 1
    parsed_log=log_reader()
    # puts "is parsed_log an array ?"
    # p parsed_log.instance_of? Array

    if parsed_log =~ /jumping/i 
      puts "'#{parsed_log}'"
      jump_complete =1
    end
  end # end of prototype loop
