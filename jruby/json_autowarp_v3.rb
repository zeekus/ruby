#filename: json_autowarpv3.rb
#description: clean up logic. rewritev3. 
#log items - expanded for reference
#image searches expanded
   
require 'java'
require 'json'
require 'time'

java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
java_import 'java.awt.event.KeyEvent'   #presing keys
java_import 'java.awt.Toolkit'          #gets screens size

#use http://www.drpeterjones.com/colorcalc to verify colors
#blue range r(70-134),g(130-180),b(170-200)

start_time=Time.now.to_i #get time in secs

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
  
  def log_reader(debug=1,target_phrase,log_size,sec_threshold)
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
    my_homedir=Dir.home #get homdir
    user=my_homedir.gsub(/.*\//,'') #get user
    
    potential_log_locations=["#{my_homedir}/EVE/logs/Gamelogs/*.txt", 
                             "#{my_homedir}/Games/eve-online/drive_c/users/#{user}/Documents/EVE/logs/Gamelog/*.txt", 
                             "/home/#{user}/Documents/EVE/logs/Gamelogs/*.txt"  ]
  
    myfile=""
    potential_log_locations.each do |logfile_loc_glob|
      puts "looking in #{logfile_loc_glob} for log file"
      limit=("-" + log_size.to_s).to_i #convert log size to negative number then back to integer
      last_log_entries=[] #empty array holding last log entries
      #initialize variables
      capture_string=""
      myfile=Dir.glob(logfile_loc_glob).max_by { |file_name| File.ctime(file_name) } 
      if File.exists?(myfile) #we found a file. 
        break #leaving loop
      end
    end
 
    if File.exists?(myfile)
      puts "*** log_reader my last log is #{myfile}" if debug==1
      file=File.open(myfile) #read file
      logfile_data=file.readlines.map(&:chomp) #attemping to get file data without new lines
      file.close #closing file
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
    capture_string="" #default is blank
    logfile_data.each  { |line|
      if /^\[/.match(line) #sometimes the lines don't have the time ignore them
        if debug ==1 
          puts "#{count}:#{line}"  #look at it
          count = count + 1
        end
        result=is_log_string_current(debug,line.chomp,sec_threshold) #current log entry only
        puts "debug log_reader result is #{result}" if debug==1
        if line =~ /#{target_phrase}/i  and result==1
           if target_phrase =~ /Jumping/i or target_phrase =~ /Undocking/i 
            capture_string = line.split(") ")[1]#remove first part of line so just get the jumping info
           #capture important main notify messages
           elsif target_phrase =~ /docking/i or target_phrase =~ /while warping/i or target_phrase =~ /please wait/i or target_phrase =~ /*.loaking*.fails/i
            capture_string = line.split(") ")[1]#remove first part of line so just get the docking or warping line  
           elsif target_phrase =~ /combat/i
            capture_string = line.split(") ")[1]  
           else
            puts "" #do nothing
           end
        end
      end
    }
    return capture_string #convert to string just in case
  end #function
end #class

class GUIchecks
  def check_blue_bar()
  end

  def check_selected_item_menu()
     #Selected Item menu- icons
     #at gate stopping or stopped{ 'align_to'=>'1', 'warp_to'=>'0', 'jump'=>'1','orbit=>'1', 'keep_distance=>'0', 'target=>'1', 'eye1'==>'1', 'eye2' =>'1' , 'i_icon'=>'1']
     #at station stopping or stopped{ 'align_to'=>'1', 'warp_to'=>'0', 'jump'=>'1','orbit=>'1', 'keep_distance=>'0', 'target=>'1', 'eye1'==>'1', 'eye2' =>'1' , 'i_icon'=>'1']
     #in warp to gate or station { 'align_to'=>'0', 'warp_to'=>'0', 'jump'=>'1','orbit=>'0', 'keep_distance=>'0', 'target=>'0', 'eye1'==>'0', 'eye2' =>'1' , 'i_icon'=>'1']
  end

  generate_logfeedback_with_a_click()
      
  end
end