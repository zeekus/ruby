require 'time'

class LogParser
     
  def is_log_string_current(debug,loginfo,sec_threshold)

    puts "is_log_string_current" + loginfo if debug ==1
 
    #string stripping log date time parser
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
    if diff < sec_threshold #theshold for number secs
      return 1 
    else
      return 0
    end
  end
  
  def log_reader(debug,target_phrase,log_size,sec_threshold)
    if debug ==1
     puts "debug is #{debug}"
     puts "target_phrase is #{target_phrase}"
     puts "log_size is #{log_size}"
     puts "sec_threshold is #{sec_threshold}"
    end
    #####################
    #find latest log file
    #####################
    ##bash equivalent
    ##file=system("find /home/$USER/Documents/EVE/logs/Gamelogs -cmin -1 -exec ls -lah {} ';'")
    my_homedir=Dir.home
    #logfile_loc_glob="#{my_homedir}/Documents/EVE/logs/Gamelogs/*.txt" #glob for all
    logfile_loc_glob="#{my_homedir}/Documents/testlog.txt" #glob for all
    limit=("-" + log_size.to_s).to_i #convert log size to negative number then back to integer
    last_log_entries=[] #empty array holding last log entries
    #initialize variables
    capture_string=""

    myfile=Dir.glob(logfile_loc_glob).max_by { |file_name| File.ctime(file_name) } 
    if File.exists?(myfile)
      puts "*** log_reader my last log is #{myfile}" if debug==1
      file=File.open(myfile) #read file
      logfile_data=file.readlines.map(&:chomp) #attemping to get file data without new lines
      file.close #closing file
      # filesize=0  #get size of the file
      # filesize=logfile_data.size
      puts "*** log_reader gamelog file has '#{logfile_data.size}' lines" if debug==1
      #only run if file size is greater than 5
      if logfile_data.size  < log_size
       puts "log_reader exiting. Listener is active but file is too small. Try exiting the station."
       exit
      else
        puts "*** log limit is [#{limit}..-1]" if debug==1 
      end
    else 
      if myfile !=null
        puts "log_reader missing file #{myfile} exiting"
      else 
        puts "log_reader file missing" 
      end
    end

    count=0
    capture_string='' #default is blank
    logfile_data.each  { |line|
      if /^\[/.match(line) #sometimes the lines don't have the time ignore them
        if debug ==1 
          puts "#{count}:#{line}"  #look at it
          count = count + 1
        end
        result=is_log_string_current(debug,line.chomp,sec_threshold) #current log entry only
        if line =~ /#{target_phrase}/i  and result==1
          if target_phrase =~ /docking/i or target_phrase =~ /warping/i
            capture_string = line.split("(notify) ")[1]#remove first part of line so just get the docking or warping line
          elsif target_phrase =~ /jumping/i
            capture_string = line.split("(None) ")[1]#remove first part of line so just get the jumping info
          else
            puts "" #do nothing
          end
        end
      end
    }
    return capture_string #convert to string just in case
  end #function
end #class
  
capture = LogParser.new
my_string= capture.log_reader(debug=1,"docking",log_size=5,sec_threshold=500) #debug =1, target_phrase="warp", lines=5
puts "returned string is '#{my_string}'"