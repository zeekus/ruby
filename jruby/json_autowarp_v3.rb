#filename: json_autowarpv3.rb
#description: clean up logic. rewritev3. 
#log items - expanded for reference
#image searches expanded

#logic redo
#1. First sequence - press warp verify warp
#2. Main loop: warp until docking sequence
    #A align ( action double click align button. Align button stays visable: verify with 'please wait' in log. or click again.) 
    #B warp to (verify warp to button is no longer visable and in warp appears in logs or press again)
      #button 1,2 disappear upon warp. 
    #C wait for slowdown. (monitor blue bar turns white and button1 appears)
    #D force jump ( press button 3 and wait for confirmation in logs or button 2 appears)
    #E scan for buttons if they don't exist then scan for yellow icon. 
#3. perform docking operations


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

class Logparse
     
  def self.is_log_string_current(debug,loginfo,sec_threshold)
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
  
  def self.log_reader(debug=1,target_phrase,log_size,sec_threshold)
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
           elsif target_phrase =~ /docking/i or target_phrase =~ /while warping/i or target_phrase =~ /please wait/i or target_phrase =~ /cloaking.*fails/i
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

class GUI_view

 

  def self.check_selected_item_menu()
    #low-medium depending on what is checked. 
    #least reliable unless we focus on the  dot images at position 1,4,and 9
    #Selected Item menu- icons
    #at gate stopping or stopped{ 'align_to'=>'1', 'warp_to'=>'0', 'jump'=>'1','orbit=>'1', 'keep_distance=>'0', 'target=>'1', 'eye1'==>'1', 'eye2' =>'1' , 'i_icon'=>'1']
    #at station stopping or stopped{ 'align_to'=>'1', 'warp_to'=>'0', 'jump'=>'1','orbit=>'1', 'keep_distance=>'0', 'target=>'1', 'eye1'==>'1', 'eye2' =>'1' , 'i_icon'=>'1']
    #in warp to gate or station { 'align_to'=>'0', 'warp_to'=>'0', 'jump'=>'1','orbit=>'0', 'keep_distance=>'0', 'target=>'0', 'eye1'==>'0', 'eye2' =>'1' , 'i_icon'=>'1']
  end

  def self.generate_feedback_with_a_click()
    #reliability: medium-high. Bullet proof feedback when it working. 
  end

  def self.look_for_blue_session_cloak_timer
    #do we see the session timer. Indicates session change completed. 
    #reliability: low-medium - can fail 20% of the time. 

  end    

  def self.check_button_clickable(robot,search_element,left_top_xy,right_bottom_xy,rgb_color_map,debug)
      #determine if a button changes colors when the mouse is moved into the box.
      offset_xy_position
  end

  def self.check_non_clickable(robot,search_element,left_top_xy,right_bottom_xy,rgb_color_map,debug)
    #description: scan region of screen without moving the mouse
    #reliabilty moderate - tells when we are moving or not. - can fail 5-10% of the time.
    #identifies if ship is moving or not
    #idenfiies buttons in interface. lowest reliablility.
    #identifies yellow icon 
    target_location=Utility.color_pixel_scan_in_range(robot,search_element,left_top_xy,right_bottom_xy,rgb_color_map,debug)
    if target_location != [0,0]
      return "yes" #positive
    else
      puts "warn: we didn't find the #{search_element} at #{target_location}" if debug == 1
      if search_element=="grey_speed" #workaround grey and white look very similar assume same 
        target_location=Utility.color_pixel_scan_in_range(robot,"white_icon",left_top_xy,right_bottom_xy,rgb_color_map,debug)
        if target_location != [0,0]
          return "yes" #this was white but in the grey search area
        else
          return "no" #we are sure this isn't grey or white.
        end
      end
      return "no" # if all else fails we return no
    end
  end

  def self.check_clickable(robot,my_start,search_element,clicks,left_top_xy,right_bottom_xy,rgb_color_map,debug,randomize) 
    #description: move the pointer to the target location like a human before clicking 
    
    User_Feedback.speak("scanning for clickable target") if debug ==1
    target_location=[0,0] #empty location
    counter=0

    #scan until we find something or try three times
    until counter>=3 or target_location !=[0,0] #scan 3 times before failing.
      target_location=Utility.color_pixel_scan_in_range(robot,search_element,left_top_xy,right_bottom_xy,rgb_color_map,debug)
      counter=counter+1
      robot.delay(500) #wait 500 seconds before each scan failure
    end
    if target_location != [0,0] and target_location != nil 
      GUI_Interact.single_click(robot,target_location,debug,randomize)
      return "single clicked"
    else
      puts "error: we didn't find the #{search_element} or click"
      User_Feedback.speak("lost track of #{search_element}. Exiting.") 
      min,sec=(Time.now.to_i-my_start).divmod(60)
      puts "run time was #{min} mins #{sec} seconds"
      exit
    end
  end

end

class User_Feedback
  def self.speak(message)
    if File.exist?("/usr/bin/espeak")  
     system("echo #{message} | espeak > /dev/null 2> /dev/null") #supress messages
     puts "#{message}"
    else
      puts "warning missing espeak..."
      puts "#{message}"
    end
  end

  def self.mydebugger(myfuncname,myfillerstring,mylocations)
    if $debug==1
      puts "DEBUG 1:#{myfuncname} #{myfillerstring} #{mylocations}" 
    end
  end
end

class GUI_Interact

  def self.single_click(robot,target_location,debug,randomize)
    Utility.target_location=offset_xy_position(target_location) if randomize==1
    move_mouse_to_target_like_human(robot,target_location,debug)
    robot.delay(rand(150..200))
    #left click
    robot.mousePress(InputEvent::BUTTON1_MASK)
    robot.delay(rand(150..350))
    robot.mouseRelease(InputEvent::BUTTON1_MASK)
 end
 
 def double_click(robot,target_location,debug,randomize)
    for i in (1..2)
      self.single_click(robot,target_location,debug,randomize)
    end
 end

  def self.cloak_ship(robot,cloaking_module,micro_warpdrive,debug)
    #click on the cloaking module
    if debug==1
      User_Feedback.speak("cloaking")
    end
    #covert ops cloak on 
    robot.delay(rand(400..500))
    single_click(robot,target_location=cloaking_module,debug,randomize=1)
 end

 def self.hit_the_button(robot,target_location,mycount,message,debug) 
   #'j' for jump 'a' for align 
  if message =~ /j/i or message =~ /a/i or message =~ /w/i #jump,align,or warpto button gets double click
    my_message=double_click(robot,target_location,debug) #double click
  else 
    my_message=single_click(robot,target_location,debug,randomize=1) #every thing else gets single click
  end
 
  User_Feedback.speak(message) if debug == 1
  puts "We clicked #{my_message}" if debug==1
  mycount = mycount + 1
  puts "count is #{mycount}. We pressed #{message}"
  return mycount
 end

 def self.micro_warpdrive_cloak_trick ( robot,cloaking_module,micro_warpdrive,align_button,warp_button,debug=1)
  if debug==1
    User_Feedback.speak("mwd cloaking")
  end
  puts "mwd cloaking"

  #assuming align pressed earlier and successful.
  robot.delay(rand(600..700))
  double_click(robot,micro_warpdrive,debug) #click mwd

  robot.delay(rand(600..750))
  double_click(robot,cloaking_module,debug) #click cloaker

  #wait 5
  robot.delay(rand(4000..5000))

  #click cloak
  double_click(robot,cloaking_module,debug) #click cloaker

  #click jump or warp to
  double_click(robot,warp_button,debug)
 end

 def self.move_mouse_to_target_like_human(robot,target_location,debug) 
  x,y=Utility.get_current_mouse_location(robot)
  mydebugger("move_mouse_to_target_like_human", "mouse location", [x,y] ) 

  counter=0
  until [x,y]==target_location do   
    if ( x > target_location[0] and y > target_location[1] ) #moving pointer up and left
      counter=counter+1
      puts ("up and left #{counter}") if debug==1
      x=x-1
      y=y-1
    elsif ( x< target_location[0] and y < target_location[1] ) #moving pointer down and right
      counter=counter+1
      puts ("down and right #{counter}") if debug==1
      x=x+1
      y=y+1
    elsif ( x> target_location[0] and y < target_location[1] ) #moving pointer down and left
      counter=counter+1
      puts ("down and left #{counter}") if debug==1
      x=x-1
      y=y+1
    elsif ( x< target_location[0] and y > target_location[1] ) #moving pointer up and right
      counter=counter+1
      puts ("up and right #{counter}") if debug==1
      x=x+1
      y=y-1
    elsif ( x< target_location[0]) #move right only
      counter=counter+1
      puts ("only right #{counter}") if debug==1
      x=x+1
    elsif ( x> target_location[0]) #move left only
      counter=counter+1
      puts ("only left #{counter}") if debug==1
      x=x-1
    elsif ( y< target_location[1]) #move up only 
      counter=counter+1
      puts ("only up #{counter}") if debug==1
      y=y+1
    elsif ( y> target_location[1]) #move down only
      counter=counter+1
      puts ("only down #{counter}") if debug==1
      y=y-1
    else
     my_tmp_location=self.get_current_mouse_location(robot)
     self.mydebugger("move_to_target_pixel_like_human", "target location", "#{target_location[0]},#{target_location[1]}" ) 
     robot.delay(1)
     return(1)
    end #end if
    robot.mouseMove(x,y)
    robot.delay(1) #mouse move is based on loop (0.1 for faster)
  end #end of until loop
 end #end function move_to_target_pixel_like_human
end #end class GUI_Interact


class Utility

  def self.button_check(robot,x,y)
    robot.mouseMove(x,y) #button location
    r,g,b=get_color_of_pixel(robot,x,y,debug=1) #with mouse on location
    puts r,g,b
    rgb_total=r+g+b

    robot.mouseMove(x,y-25) #move mouse off button in upward direction
    r1,g1,b1=get_color_of_pixel(robot,x,y,debug=1) #with mouse off location
    puts r1,g1,b1
    rgb1_total = r1+g1+b1

    if rgb1_total != rgb_total
        return "yes"
    else
        return "no"
    end
  end

  def self.color_pixel_scan_in_range(robot,target_color,left_top_xy,right_bottom_xy,rgb_color_map,debug) 
    count=0
    mybreak =0
    found_icon_coord=[]
    found_icon_coord =[0,0] #array location
  
    #scan on x axis main loop
    for x in left_top_xy[0]..right_bottom_xy[0]
      #scan on y axis inner loop
      for y in left_top_xy[1]..right_bottom_xy[1]
        count = count + 1
        found_icon_coord=[x,y]
        rgb=robot.getPixelColor(x,y) #RGB color
        r = rgb.red
        g = rgb.green
        b = rgb.blue
        rgb=[r,g,b]
        hex_string="" #resets hex_string ever iteration
        for color in rgb
         hex=color.to_s(16).upcase
         hex = "0#{hex}" if hex.length < 2 #length of each HEX octet is always 2
         hex_string="#{hex_string}#{hex}" #RGB color to HEX format
        end
       
        my_best_guess=guess_color(r,g,b) 
        if ( target_color == my_best_guess) 
          puts "possible match - The pixel could be #{target_color}" if debug ==1
          return found_icon_coord
        elif rgb_color_map[hex_string] != nil and target_color
          puts "possible match - The pixel could be #{rgb_color_map[hex_string]}" if debug ==1
          return found_icon_coord
        else 
         if debug==1
           puts "warning: The pixel color of #{hex_string} at [#{x},#{y}] is not mapped. best #{my_best_guess}"
         end
        end #if loop
      end  #for y loop 
    end #for x loop
    
    found_icon_coord =[0,0] #array location
    return found_icon_coord #nothing found
  end
  
  def self.color_intensity (r,g,b)
    colori = ( r + g + b ) / 3.0
    return colori 
  end



  #Note: guess_color needs a rewrite. The logic her is not accurate. Grey vs white. The colors that are easier to detect should be higher. 
  #problem: not very accurate
  def self.guess_color(r,g,b)
    my_color = "unknown"
    hue = color_intensity(r,g,b)
    percent=hue
   
    return my_color ="red" if ( r > 200 and g < 50 and b <50 ) #red
    
    return my_color ="jtarget_yellow" if ( 
      ( r > 117 and  g > 117 and b < 50 ) and
      ( (r == g) or ( ( (g - 50) > b) and ( ( r - 50)  > b ) )) 
    ) #yellow
  
    return my_color ="blue" if ( r < 120 and b > 198)  #blue
  
    return my_color ="white_icon" if ( r>160 and g> 100 and b > 150 ) #white
  
    return my_color ="black" if ( r <  40  and g < 40 and b < 40 ) #black
  
    return my_color ="blue_speed" if ( 
     ( r> 65 and r<145) and ( g > 124 and g < 155) and ( b > 155 and b < 200 )
    )  
    return my_color ="grey_speed" if ( 
     ( r> 65 and r<190) and ( g > 65 and g < 190) and ( b > 65 and b < 190 ) and 
     ( 
       ( hue > (r - 5)) and ( hue > (g - 5)) and (hue > (b - 5 )) 
     ) 
     )
     #my_color = "#{my_color}:#{hue}"
    return my_color
   end

   def self.help(command,ship_align_secs)
    #description: generates help for command line input 
    puts "help was called"
    puts "use: #{command}  -c -s:t #for cloaking transport with standard covert ops"
    puts "use: #{command}  -ct -s:t #for cloaking transport with cloak trick"
    puts "use: #{command}  -s:cr   #for cruiser with no cloak 15 second align time"
    puts "ship types and align time defined:"
    for key,values in ship_align_secs
      printf "... key %2s tranlates to %2s seconds.\n" % [ key,values] 
      #print ", " if values != ship_align_secs.values.to_a.last #only add comma if not last element
    end
  end

  def self.randomize_click_target(top,bottom)
    #description: we return back a random location between two positons based on range
    xtop,ytop=top
    xbot,ybot=bottom
    x=rand(xtop..xbot)
    y=rand(ytop..ybot)
    return x,y
  end

  def self.offset_xy_position(target_location,debug=0)
    #description: simple offset 1 pixel : randomize target location a tiny bit so we are not an obvious
    puts "single click - original location #{target_location}" if debug == 1
    x=target_location[0]+rand(-1..1)
    y=target_location[1]+rand(-1..1)
    new_target_location=[x,y]
    puts "single click - randomized location #{new_target_location}" if debug==1
    return new_target_location
  end

  def self.get_current_mouse_location(robot,debug)
    x=MouseInfo.getPointerInfo().getLocation().x
    y=MouseInfo.getPointerInfo().getLocation().y
    User_Feedback.mydebugger("get_current_mouse_location", "under mouse location", "[#{x},#{y}]" ) if debug==1
    return [x,y]
  end
end #Utility class

############
##MAIN
############
###################################################
#Future - todo - the color map should be put in a json file
###################################################
#maps for the RGB colors in HEX 
rgb_color_map={
  "5C0545" => "gold_undock",
  "590342" => "gold_undock",
  "5C0546" => "gold_undock",
  "508FC5" => "blue_speed",
  "4F8CC1" => "blue_speed",
  "5792C4" => "blue_speed",
  "5290C4" => "blue_speed",
  "558DBF" => "blue_speed",
  "508FC4" => "blue_speed",
  "5690C1" => "blue_speed",
  "5490C2" => "blue_speed",
  "5590C3" => "blue_speed",
  "528FC4" => "blue_speed",
  "508CC2" => "blue_speed",
  "4FC38D" => "blue_speed",
  "4DC18B" => "blue_speed",
  "A6A19B" => "grey_speed",
  "A39E98" => "grey_speed",
  "A7A29B" => "grey_speed",
  "A4A099" => "grey_speed",
  "A4A09A" => "grey_speed",
  "9E9C97" => "grey_speed",
  "A5A09A" => "grey_speed",
  "9C9791" => "grey_speed",
  "A4999E" => "grey_speed",
  "A3979D" => "grey_speed",
  "A29A9F" => "grey_speed",
  "A69CA3" => "grey_speed",
  "A69CA2" => "grey_speed",
  "605617" => "jtarget_yellow",
  "635A14" => "jtarget_yellow",
  "483D1C" => "jtarget_yellow",
  "796B25" => "jtarget_yellow",
  "A8A013" => "jtarget_yellow",
  "A29B11" => "jtarget_yellow",
  "514420" => "jtarget_yellow",
  "FFFFFF" => "white_icon"}

  ship_align_secs={
        "s"  =>  2,  #shuttle 
        "f"  =>  5,  #frig
        "t"  =>  7,  #transport
        "cr" =>  15, #cruiser 
        "h"  =>  20, #hauler
        "bs" =>  20, #battleship
        "fr" =>  65  #freighter
}
####################
#default settings
####################
destination_selected=0  #status of yellow selection
in_space=1              #status of ship - always 1
jump_count = 0          #counter for jumps   
warp_count = 0          #counter for warps
icon_is_visable="no"    #status of icon on right of screen
are_we_moving="no"      #status of ship blue check
are_we_stopped="yes"    #status of ship grey check 
icon_found_count=0      #counter for stats
icon_notfound_count=0   #counter for icon misses
debug=0                #espeak gets chatty with debug =1 
cloak_type=0
ship_align_time=ship_align_secs["h"] #hauler is the default with a 20 second align time



################################
#command line arg parsing 
################################
ARGV << '-help' if ARGV.empty? #default set to help
puts "length of the 'ARGV' array is: " + ARGV.length.to_s  if debug==1

for i in 0 ... ARGV.length
  puts "MAIN DEBUG#{i}: '#{ARGV[i].chomp}'" if debug==1
  if ARGV[i] =~ /-/ and ARGV[i] !~ /-help/ #alternate run 'help' is found
    puts "DEBUG#{i}: flag detected '#{ARGV[i].chomp}'" if debug==1
    arg_count=i+1
    puts "DEBUG#{i}: associated with'#{ARGV[arg_count].chomp}'" if debug==1
  elsif ARGV[i].chomp =~ /-help/ or ARGV[i] =~ /\s+/ #need help
    puts "DEBUG3: 'help command received'" if debug==1
    Utility.help(command=$0,ship_align_secs)
    exit
  else
    puts ""
  end
end

for string in ARGV
 puts "You typed `#{string}` as your argument(s)." if debug==1
 if string =~ /-ct/
  cloak_type=2
  puts "cloak trick enabled"
 elsif string =~ /-c/
  puts "cover ops enabled"
  cloak_type=1
 else
  puts "no cloaking"
 end 

 if string =~/-s/
  my_string=string.split(/:/)[1]
  ship_align_time=ship_align_secs["#{my_string}"]
  puts "align time is set to : #{ship_align_time}"
 end

end

######################
#Class initialization 
######################
robot = Robot.new        #holds Java AWT info

#load in json file that holds locations of mappings generated from json_setup_screen_points.rb 
my_json_file=("/var/tmp/locations.json")
if File.exist?(my_json_file)
  #puts "file exits. opening file..."
  file = File.read(my_json_file)
  data_hash = JSON.load(file) #load in json file holding locations
end

#Screen Location: variables come from json
cloaking_module=data_hash["cloaking_module"]
microwarp_module=data_hash["microwarp_module"]
ref_point=data_hash["screen_center"]
align_to_top=data_hash["align_to_top"]
align_to_bottom=data_hash["align_to_bottom"]
warp_to_top=data_hash["warp_to_top"]
warp_to_bottom=data_hash["warp_to_bottom"]
jump_button_top=data_hash["jump_button_top"]
jump_button_bottom=data_hash["jump_button_bottom"]
white_i_icon_top=data_hash["white_i_icon_top"]
white_i_icon_bottom=data_hash["white_i_icon_bottom"]
blue_speed_top=data_hash["blue_speed_top"]
blue_speed_bottom=data_hash["blue_speed_bottom"]
yellow_icon_left_top=data_hash["yellow_icon_left_top"]
yellow_icon_right_bottom=data_hash["yellow_icon_right_bottom"]
gold_undock=data_hash["gold_undock"]
my_start=Time.now.to_i #runtime start
while in_space==1 #main run area begins here. 
  #randomize places we click 
  align_button=Utility.randomize_click_target(align_to_top,align_to_bottom)
  warp_button=Utility.randomize_click_target(warp_to_top,warp_to_bottom)
  jump_button=Utility.randomize_click_target(jump_button_top,jump_button_bottom)

  #check for icon - needed to find the yellow icon after each run
  icon_is_visable = GUI_view.check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug) 
  User_Feedback.speak("L3 icon #{icon_is_visable}") if debug ==1
  ###########################################
  #SEQ 0: prerequisite - select the yellow destination icon
  #issues this disappears sometimes at random intervals. 
  ###########################################
  if destination_selected == 0 or icon_is_visable =="no" # need yellow icon selected for things to work. 
    robot.delay(500)  #1/2 second delay
    User_Feedback.speak("refresh click") if debug == 1
    GUI_Interact.single_click(robot,ref_point,debug,randomize=0) #click on center of screen 


    #check and click on the yellow destination marker
    my_message=GUI_view.check_clickable(robot,my_start,"jtarget_yellow",clicks=1,yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map,debug,randomize=0)
    puts "We #{my_message} on our destination."
    User_Feedback.speak("click") 
    destination_selected=1
    User_Feedback.speak("go 0 destination selected") if debug ==1
  end
  #check for grey - ocassionally this is white
  are_we_stopped = GUI_view.check_non_clickable(robot,"grey_speed",blue_speed_top,blue_speed_bottom,rgb_color_map,debug)
  User_Feedback.speak("L1 grey stopped #{are_we_stopped}") if debug==1
  #check for blue - movement
  are_we_moving  = GUI_view.check_non_clickable(robot,"blue_speed",blue_speed_top,blue_speed_bottom,rgb_color_map,debug)
  User_Feedback.speak("L2 blue moving #{are_we_moving}") if debug==1
  #check for icon - again 
  icon_is_visable = GUI_view.check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug)
  User_Feedback.speak("L3 icon #{icon_is_visable}") if debug ==1
  start_jump_count=jump_count
  jump_button_pressed=0
  warp_button_pressed=0
  ###################
  #SEQ: 1. hit warpto button or jump button - depending and verify
  ###################
  if in_space == 1 and destination_selected == 1 and icon_is_visable == "yes"
    robot.delay(1000)  #1 second delay
    User_Feedback.speak("go 1 warp") if debug ==1
    align_time_start=Time.now.to_i #get time in secs
    if cloak_type == 1 or cloak_type ==2
      puts "hit the align button until we see 'please wait' in the logs"
      
      until my_string =~ /please wait/i
        GUI_Interact.hit_the_button(robot,target_location=align_button,jump_count,message="a",debug)
        robot.delay(500) #1/2 sec delay for log entry to appear
        my_string=Logger.log_reader(debug,"please wait",log_size=5,sec_threshold=5) #got a wait
        sleep 1
      end

      if jump_count > 0 #only cloak when on second jump to avoid stations.
        puts "cloaking routine cloaktrick called"
        if cloak_type==2
          GUI_Interact.micro_warpdrive_cloak_trick(robot,cloaking_module,microwarp_module,align_button,warp_button,debug)
        elsif cloak_type==1
          puts "standard cloaking routine called"
          GUI_Interact.cloak_ship(robot,cloaking_module,microwarp_module,debug)
        end
      end
    end
    #########################
    #pressing warpto button  
    #########################
    my_string=""
    User_Feedback.speak(" warp #{warp_count}")
    warp_count=GUI_Interact.hit_the_button(robot,target_location=warp_button,warp_count,message="w",debug)
   
    warp_button_pressed=1

    until my_string =~ /warping/i
      GUI_Interact.double_click(robot,ref_point,debug) #click on center of screen
      robot.delay(500) #1/2 sec delay for log entry to appear
      my_string=Logger.log_reader(debug,"warping",log_size=5,sec_threshold=5) #got a wait
      GUI_Interact.hit_the_button(robot,target_location=warp_button,warp_count,message="w",debug)
      robot.delay(1000)  #1 second delay
    end
    robot.delay(3000) if warp_count ==1 #near station delay first jump 
    #double click somewhere in space to get the warp message in the log - looking for "(notify) You cannot do that while warping.""
     
    
    my_string=Logger.log_reader(debug,"warping",log_size=5,sec_threshold=5) #warping message with double click or click on speed while in space
    if my_string != "" or my_string.length > 1
      puts "2 - string is '#{my_string.to_s}'"  
      User_Feedback.speak("logger string is #{my_string.to_s}") if debug==1
    end
    #check icons again - the warp to icon should have disappeared
    warp_to_visable = GUI_view.check_non_clickable(robot,"white_icon",warp_to_top,warp_to_bottom,rgb_color_map,debug)
    if my_string.to_s =~ /warp/i or warp_to_visable=="no" #verify warp icon disappeared or we find it in the logs
      User_Feedback.speak("in warp")
    else 
      warp_to_visable = GUI_view.check_non_clickable(robot,"white_icon",warp_to_top,warp_to_bottom,rgb_color_map,debug) #double check 
      if warp_to_visable == "yes" 
        warp_to_visable = GUI_view.check_non_clickable(robot,"white_icon",warp_to_top,warp_to_bottom,rgb_color_map,debug) #double check 
        User_Feedback.speak("missed a warp. Trying again.")
        null=GUI_Interact.hit_the_button(robot,target_location=warp_button,warp_count,message="w",debug) #second try
      end
    end 
  end
  #################
  #SEQ 2: ship should be speeding up: blue bar filling
  #################
  if warp_button_pressed==1
    my_action.speak("go 2 advance") if debug ==1
    #######################################################
    #Ship should be speeding up. Wait until the blue bar is full speed.
    #######################################################
    wait_count =0
    until are_we_moving == "yes" 
       print "...waiting for ship to reach full speed. aligning: " if wait_count ==0 
       are_we_moving  = GUI_view.check_non_clickable(robot,"blue_speed",blue_speed_top,blue_speed_bottom,rgb_color_map,debug)
       wait_count=wait_count+1
       robot.delay(500)  #1/2 second delay                   
       if (wait_count/2) > ship_align_time #over ride for when things are happening too slow
         User_Feedback.speak("warning  acceleration overwait") 
         puts "warning acceleration is taking too long. rescanning and clicking on yellow"
         my_message=GUI_Interact.check_clickable(robot,my_start,"jtarget_yellow",clicks=1,yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map,debug,randomize=0)
         warp_to_visable = GUI_view.check_non_clickable(robot,"white_icon",warp_to_top,warp_to_bottom,rgb_color_map,debug) #check icons
         if warp_to_visable =="yes"
          GUI_Interact.hit_the_button(robot,target_location=warp_button,warp_count,message="w",debug)
         else
          GUI_Interact.hit_the_button(robot,target_location=jump_button,warp_count,message="j",debug)
         end
         wait_count=0 #reset wait count
       else 
         print "." #status bar like effect
       end
    end
    min,sec=(Time.now.to_i-align_time_start).divmod(60) #align time to min secs
    puts "" #new line
    puts "align time was #{min} mins #{sec} seconds"
    ###################
    #SEQ 3. waiting for jump completion
    ###################
    my_action.speak("go 3 waiting for jump") if debug ==1
    in_hyper_jump=Time.now.to_i #get time in secs
    #######################################################
    #problem area - logs are not always working/reliable. 
    #Upon jump to a new systems we should get a log entry. *Note* this ocassionally fails. 
    #######################################################
    wait_count=0
    my_jump_click_again=0 # work around for stuck gates 
    session_change_wait=0
    jbutton_seq=0
    jump_seq_complete=0
    until jump_seq_complete==1
      robot.delay(500)  #1/2 second delay
      wait_count=wait_count+1
      #Fail SAFE check for icon and monitor speed
      icon_is_visable = GUI_view.check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug)
      are_we_moving  = GUI_view.check_non_clickable(robot,"blue_speed",blue_speed_top,blue_speed_bottom,rgb_color_map,debug)
      my_button_visable = GUI_view.check_non_clickable(robot,"white_icon",jump_button_top,jump_button_bottom,rgb_color_map,debug)
      my_action.speak("L3 icon #{icon_is_visable}") if debug ==1
      #scan logs for a session change
      my_jump_string=Logger.log_reader(debug,"Jumping",log_size=5,sec_threshold=5) #jumping is slow 10 secs
      puts "3 - jumping - '#{my_jump_string.to_s}'" if my_jump_string != ""
      my_docking_string=Logger.log_reader(debug,"docking",log_size=5,sec_threshold=5) #jumping is slow 10 secs
      puts "4 - docking - '#{my_docking_string.to_s}'" if my_docking_string != ""
      if ( my_jump_string =~ /jumping/i )
        User_Feedback.speak("1 #{my_jump_string}") 
        jump_seq_complete=1
        robot.delay(rand(1500..2500)) #screen blinks. This is a work around.
      elsif (my_docking_string =~ /docking/i )
        User_Feedback.speak("1 docking finished")
        min,sec=(Time.now.to_i-my_start).divmod(60)
        puts "run time was #{min} mins #{sec} seconds"
        exit 
      elsif ( icon_is_visable=="no" and are_we_moving =="no")
        #check log again for a jump
        robot.delay(rand(1500..3000)) #wait 1.5-3 secs
        my_jump_string=Logger.log_reader(debug,"Jumping",log_size=5,sec_threshold=3) #jumping is slow 10 secs
        my_docking_string=Logger.log_reader(debug,"docking",log_size=5,sec_threshold=5) #jumping is slow 10 secs
        if my_jump_string != ""
          User_Feedback.speak("2 #{my_jump_string}") #speak jump string from log
        elsif  my_docking_string =~ /docking/i
          User_Feedback.speak("2 docking") #speak jump string from log
          exit
        else
          User_Feedback.speak("failsafe jump wait")
          robot.delay(rand(3000..5000)) #wait 3-5 secs
        end
        jump_seq_complete=1
      else
        min,secs=(Time.now.to_i-in_hyper_jump).divmod(60)
        #work around cloaker ship not registering jump
        #ocassionally we mess up a jump gates lock us out. This should catch it.    
        if icon_is_visable=="yes" and are_we_moving=="no"
          if session_change_wait ==0
            User_Feedback.speak("stopping")  
            User_Feedback.speak("pressing jump button #1") 
            #get yellow icon again
            my_message=GUI_view.check_clickable(robot,my_start,"jtarget_yellow",clicks=1,yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map,debug,randomize=0)
            GUI_Interact.single_click(robot,target_location=jump_button,debug,randomize=1) #force single click
            jump_count=jump_count+1
            jbutton_seq=jbutton_seq+1
          end
          session_change_wait=session_change_wait+1
          my_action.speak("#{session_change_wait}") if debug == 1
          icon_is_visable = check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug)
          robot.delay(100)
          if session_change_wait % 7 == 0 and icon_is_visable == "yes" # every 7 
            my_message=check_clickable(robot,my_start,"jtarget_yellow",clicks=1,yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map,debug,randomize=0)
            GUI_Interact.single_click(robot,target_location=jump_button_bottom,debug,randomize=1) #force single click
            jbutton_seq=jbutton_seq+1
            User_Feedback.speak("jump again #{jbutton_seq} timeout") # if debug == 1
          end           
        end
      end 
    end
    mins,secs=(Time.now.to_i-in_hyper_jump).divmod(60) #get time in warp 
    puts "in warp time was #{mins} minutes #{secs} seconds"
    warp_button_pressed=0 if jump_seq_complete==1 #reset warp button pressed when jump completes 

    ########################################################
    #SEQ 4: Verifying end of jump sequence. Overview should display the 'i' icon on the far right of the screen. 
    ########################################################
    wait_for_session_change=Time.now.to_i
    wait_count =0 
    jump_button_visable = check_non_clickable(robot,"white_icon",jump_button_top,jump_button_bottom,rgb_color_map,debug)
    icon_is_visable = check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug)
    GUI_Interact.single_click(robot,ref_point,debug,randomize=1) #move mouse to see the buttons 
    until icon_is_visable=="yes" and jump_button_visable=="yes"
     User_Feedback.speak("go 4 refresh") if debug == 1 
     print "refresh pause:" if wait_count==0
     print "."
     robot.delay(500)  #1/2 second delay 
     wait_count=wait_count+1
     icon_is_visable = GUI_view.check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug)
     jump_button_visable = GUI_view.check_non_clickable(robot,"white_icon",jump_button_top,jump_button_bottom,rgb_color_map,debug)
     min,secs=(Time.now.to_i-wait_for_session_change).divmod(60)
     if secs % 3 == 0  and wait_count > 10 #work around - ocassionally we can lose track of the gate after completing a jump. re-scan for it if lost after 7 seconds.
       puts "" #new line
       puts" lost white icon or jump_button: we should click on the yellow icon again."
       #check and click on the destination indicator
       User_Feedback.speak("go 4B lost track of the gate. jump_button visible #{jump_button_visable} icon visible #{icon_is_visable}") 
       my_message=GUI_view.check_clickable(robot,my_start,"jtarget_yellow",clicks=1,yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map,debug,randomize=0)
       wait_count=0 #reset wait count
     end
    end
    puts "" #new line
  end
  robot.delay(1500) #added 1.5 second delay for session refresh
end  
#test