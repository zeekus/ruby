class LogParser

#   def initialize(debug, phrase, logsize)
#     @debug = debug
#     @target_phrase = phrase
#     @log_size = logsize
#   end
      
  def is_log_entry_current(loginfo,debug)
 
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
    if diff < 10 #10 second theshold
      #buggy ? 
      return 1 
    else
      return 0
    end
  end
  
  def log_reader(debug,target_phrase,log_size)
    #####################
    #find latest log file
    #####################
    ##bash equivalent
    ##file=system("find /home/$USER/Documents/EVE/logs/Gamelogs -cmin -1 -exec ls -lah {} ';'")
    my_homedir=Dir.home
    logfile_loc_glob="#{my_homedir}/Documents/EVE/logs/Gamelogs/*.txt" #glob for all
    limit=("-" + log_size.to_s).to_i #convert log size to negative number then back to integer
    last_log_entries=[] #empty array holding last log entries
    #initialize variables
    capture_string=""

    myfile=Dir.glob(logfile_loc_glob).max_by { |file_name| File.ctime(file_name) } 
    if File.exists?(myfile)
      puts "*** log_reader my last log is #{myfile}" if debug==1
      file=File.open(myfile) #read file
      file_data=file.readlines.map(&:chomp) #attemping to get file data without new lines
      file.close #closing file
      filesize=0  #get size of the file
      filesize=file_data.size
      puts "*** log_reader gamelog file has '#{filesize}' lines" if debug==1
      #only run if file size is greater than 5
      if filesize < log_size
       puts "log_reader exiting. Listener is active but file is too small. Try exiting the station."
       exit
      else 
        last_log_entries=filedata[limit..-1] #adaptive log size 
      end
    else 
      if myfile !=null
        puts "log_reader missing file #{myfile} exiting"
      else 
        puts "log_reader file missing" 
      end
      exit
    end
  
    last_log_entries.each do |line|  #look at it
      if /^\[/.match(line) #sometimes the lines don't have the time ignore them
        result=is_log_entry_current(line.chomp) #current log entry only
        if result ==1
          if line.to_s =~ /#{target_phase}/i 
            if target_phase =~ /docking/ or target_phase =~ /warping/
              capture_string = line.split("(notify) Requested to ")[1]#remove first part of line so just get the jumping info
            elsif target_phase =~ /jumping/i 
              capture_string = line.split("(None) ")[1]#remove first part of line so just get the jumping info
            else
              capture_string = ""
            end
          end
          return capture_string.to_s #capture sting as string
        end
     end
     return "" #return empty string to prevent an array from getting passed
    end #last
  end #function
end #class
  
capture = LogParser.new
capture.log_reader(1,"warp",5) #debug =1, target_phrase="warp", lines=5