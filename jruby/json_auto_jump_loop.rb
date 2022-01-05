#!/usr/bin/jruby
#filename: json_auto_jump_loop.rb
#description: moves ship from system to system until docking.
#requires a location.json file to exist. 
#requires stations and gates on overview
#use: json_setup_screen_points.rb to setup json file holding buttons
#use  json_test_setup.rb to verify the button locations are where they are.

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
    logfile_loc_glob="#{my_homedir}/Documents/EVE/logs/Gamelogs/*.txt" #glob for all
    #logfile_loc_glob="#{my_homedir}/Documents/testlog.txt" #glob for all
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
    capture_string="" #default is blank
    logfile_data.each  { |line|
      if /^\[/.match(line) #sometimes the lines don't have the time ignore them
        if debug ==1 
          puts "#{count}:#{line}"  #look at it
          count = count + 1
        end
        result=is_log_string_current(debug,line.chomp,sec_threshold) #current log entry only
        if line =~ /#{target_phrase}/i  and result==1
           if target_phrase =~ /Jumping/i or target_phrase =~ /Undocking/i 
            capture_string = line.split("(None) ")[1]#remove first part of line so just get the jumping info
           elsif target_phrase =~ /docking/i or target_phrase =~ /warping/i or target_phrase =~ /please wait.../i
            capture_string = line.split("(notify) ")[1]#remove first part of line so just get the docking or warping line  
           elsif target_phrase =~ /combat/i
            capture_string = line.split("(combat) ")[1]
           else
            puts "" #do nothing
           end
        end
      end
    }
    return capture_string #convert to string just in case
  end #function
end #class

class Action

  def speak(message)
    if File.exist?("/usr/bin/espeak")  
     system("echo #{message} | espeak > /dev/null 2> /dev/null") #supress messages
     puts "#{message}"
    else
      puts "warning missing espeak..."
      puts "#{message}"
    end
  end

  def get_current_mouse_location(robot)
    x=MouseInfo.getPointerInfo().getLocation().x
    y=MouseInfo.getPointerInfo().getLocation().y
    self.mydebugger("get_current_mouse_location", "under mouse location", "[#{x},#{y}]" ) 
    return [x,y]
  end

  def mydebugger(myfuncname,myfillerstring,mylocations)
    if $debug==1
      puts "DEBUG 1:#{myfuncname} #{myfillerstring} #{mylocations}" 
    end
  end

  def move_mouse_to_target_like_human(robot,target_location)
    myloc=[] 
    myloc=get_current_mouse_location(robot)
    mydebugger("move_mouse_to_target_like_human", "mouse location", myloc ) 

    x=myloc[0]
    y=myloc[1]

    until myloc==target_location do
    
      #moving pointer up and left
      if ( x > target_location[0] and y > target_location[1] )
	    if ( x-10 > target_location[0] && y-10 > target_location[1]) 
          #fast moving to up and left by 10 
          x=x-10
          y=y-10
	    else
          #slow moving to up and left by 1
          x=x-1
          y=y-1
        end
      #moving pointer down and right 
      elsif ( x< target_location[0] and y < target_location[1] )
        if ( x+10 > target_location[0] && y+10> target_location[1]) 
         #fast moving down and right x 10
         x=x+10
         y=y+10
	    else
         #slow moving down and right
         x=x+1
         y=y+1
        end
      #moving pointer down and left 
      elsif ( x> target_location[0] and y < target_location[1] )
        if ( x-10 > target_location[0] && y+10> target_location[1]) 
          #fast moving down and left by 10
          x=x-10
          y=y+10
        else
          #slow moving down and left
          x=x-1
          y=y+1
        end
      #moving pointer up and right
      elsif ( x< target_location[0] and y > target_location[1] )
        if ( x+10 > target_location[0] && y-10> target_location[1]) 
          #fast moving up and right by 10
          x=x+10
          y=y-10
	    else
          #slow moving up and right by 1
          x=x+1
          y=y-1
	    end
      #move right only 
      elsif ( x< target_location[0])
        if ( x+10 > target_location[0] ) 
          #+ #moving right by 10
          x=x+10
        else
          #+ #moving right
          x=x+1
        end
      #move left only 
      elsif ( x> target_location[0])
        if ( x-10 > target_location[0] ) 
          #fast moving left by 10
          x=x-10
        else
          #slow moving left 
          x=x-1
        end
      #move up only 
      elsif ( y< target_location[1])
        if ( y+10 > target_location[1] ) 
          #- #moving up by 10
          y=y+10
        else
          #+ #moving up
          y=y+1
        end
      #move down only 
      elsif ( y> target_location[1])
        if ( y-10 > target_location[1] ) 
          #fast moving down by 10
          y=y-10
	      else
          #slow moving down
          y=y-1
        end
      else
        my_tmp_location=self.get_current_mouse_location(robot)
        self.mydebugger("move_mouse_to_target_like_human", "target location", "#{target_location[0]},#{target_location[1]}" ) 
        robot.delay(10) 
        return(1) 
      end #end if
      robot.mouseMove(x,y)
      robot.delay(1) 
    end #end of until loop
  end #end function move_mouse_to_target_like_human

  def color_pixel_scan_in_range(robot,target_color,left_top_xy,right_bottom_xy,rgb_color_map,debug) 
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
          puts "possible match - The pixel could be #{target_color}"
          return found_icon_coord
        elif rgb_color_map[hex_string] != nil and target_color
          puts "possible match - The pixel could be #{rgb_color_map[hex_string]}"
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
  
  def color_intensity (r,g,b)
    colori = ( r + g + b ) / 3.0
     return colori 
  end

  #Note: guess_color needs a rewrite. The logic her is not accurate. Grey vs white. The colors that are easier to detect should be higher. 
  #not very accurate
  def guess_color(r,g,b)
   my_color = "unknown"
   hue = self.color_intensity(r,g,b)
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

  def hit_the_button(robot,target_location,jump_count,message,debug)
    #Hit the press the jump button 
    if message =~ /j/i #jump button
      my_message=double_click(robot,target_location) #jump double click
    else 
      my_message=single_click(robot,target_location) #every thing else
    end
    #j for jump a for align 
    self.speak(message) if debug == 1
    puts "We #{my_message} on warp_to_top."
    jump_count = jump_count + 1
    puts "jump count is #{jump_count}. We are in warp..."
    
    return jump_count
  end

end #end class

def cloak_ship(robot,cloaking_module,micro_warpdrive,debug)

   #cloak module
   #key list ref http://www.kbdedit.com/manual/low_level_vk_list.html
   if debug==1
     my_action=Action.new
     my_action.speak("cloaking")
   end
   
   mydelay=rand(101..200)
   robot.delay(mydelay)
   single_click(robot,target_location=micro_warpdrive)
   robot.delay(mydelay)
   single_click(robot,target_location=cloaking_module)
end

def randomize_xy(target_location)
  puts "single click - original location #{target_location}"
  #randomize target location a tiny bit so we are not an obvious
  rx=rand(-1..1) #tiny bit of randomness added so we don't click in the same exact spot everytime
  x=target_location[0]+rx

  ry=rand(-1..1) #tiny bit of randomness added so we don't click in the same exact spot everytime
  y=target_location[1]+ry
  
  new_target_location=[x,y]
  puts "single click - randomized location #{new_target_location}"
  return new_target_location
end

def single_click(robot,target_location)
   target=Action.new

   target_location=randomize_xy(target_location) 

   target.move_mouse_to_target_like_human(robot,target_location)
   delay=rand(150..200)
   robot.delay(delay)

   #left click
   robot.mousePress(InputEvent::BUTTON1_MASK)
   delay=rand(150..350)
   robot.delay(delay)
   robot.mouseRelease(InputEvent::BUTTON1_MASK)
end

def double_click(robot,target_location)
  #moust double clicks require 2 clicks in 500ms or less
  target=Action.new
  target_location=randomize_xy(target_location)
  target.move_mouse_to_target_like_human(robot,target_location)
  delay=rand(120..160)
   for i in (1..2)
     robot.mousePress(InputEvent::BUTTON1_MASK)
     robot.delay(delay)
     robot.mouseRelease(InputEvent::BUTTON1_MASK)
     robot.delay(delay)
   end
end

def check_non_clickable(robot,search_element,left_top_xy,right_bottom_xy,rgb_color_map,debug)

  #scan region of screen without moving the mouse
  my_action=Action.new
  target_location=my_action.color_pixel_scan_in_range(robot,search_element,left_top_xy,right_bottom_xy,rgb_color_map,debug)

  if target_location != [0,0]
    return "yes"
  else
    puts "warn: we didn't find the #{search_element} at #{target_location}" if debug == 1
    if search_element=="grey_speed" #workaround grey and white look very similar assume same 
      target_location=my_action.color_pixel_scan_in_range(robot,"white_icon",left_top_xy,right_bottom_xy,rgb_color_map,debug)
      if target_location != [0,0]
        return "yes" #this was white but in the grey search area
      else
        return "no" #we are sure this isn't grey or white.
      end
    end

    return "no" # if all else fails we return no
  end
end

def check_clickable(robot,my_start,search_element,clicks,left_top_xy,right_bottom_xy,rgb_color_map,debug) 
  #move the pointer to the target location like a human before clicking 
  my_action=Action.new
  my_action.speak("scanning for clickable target") if debug ==1 
  target_location=my_action.color_pixel_scan_in_range(robot,search_element,left_top_xy,right_bottom_xy,rgb_color_map,debug)
 
   if target_location != [0,0] and target_location != nil 
      single_click(robot,target_location)
      return "single clicked"
   else
    puts "error: we didn't find the #{search_element} or click"
    min,sec=(Time.now.to_i-my_start).divmod(60)
    puts "run time was #{min} mins #{sec} seconds"
    exit
   end
end

def wait_until_we_are_moving(robot,speed_top,speed_bottom,rgb_color_map,debug)
  wait_until_we_are_moving_start_time=Time.now.to_i #get time in secs
  my_action=Action.new
  my_action.speak("waiting on movement") if debug==1
  are_we_moving="no"
  are_we_stopped="yes"
  until are_we_moving == "yes" and are_we_stopped == "no"
    are_we_moving  = check_non_clickable(robot,"blue_speed",speed_top,speed_bottom,rgb_color_map)
    are_we_stopped = check_non_clickable(robot,"grey_speed",speed_top,speed_bottom,rgb_color_map)
    my_action.speak("fast_blue #{are_we_moving} grey_speed #{are_we_stopped} ") if debug==1
    puts "waiting to speeding up..."
  end
 
  mins,secs = (Time.now.to_i-wait_until_we_are_moving_start_time).divmod(60) # convert runtime to minutes and seconds
  my_action.speak("movement detected in #{secs} seconds")
  return "yes" #results 
  
end



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
icon_is_visable="no"    #status of icon on right of screen
are_we_moving="no"      #status of ship blue check
are_we_stopped="yes"    #status of ship grey check 
icon_found_count=0      #counter for stats
icon_notfound_count=0   #counter for icon misses
debug=0                #espeak gets chatty with debug =1 
cloaking_ship=0
ship_align_time=ship_align_secs["h"] #hauler is the default with a 20 second align time

def help(command,ship_align_secs)
  puts "help was called"
  puts "#{command} use: -c -s:t for cloaking transport"
  puts "#{command} use: -s:cr for cruiser with no cloak"
  puts "ship types defined:"
  for key,values in ship_align_secs
    print key + ", "
  end
end

puts "length of the 'ARGV' array is: " + ARGV.length.to_s  if debug==1

for i in 0 ... ARGV.length
  puts "MAIN DEBUG#{i}: '#{ARGV[i].chomp}'" if debug==1
  if ARGV[i] =~ /-/ and ARGV[i] !~ /-help/ #alternate run 'help' is found
    puts "DEBUG#{i}: flag detected '#{ARGV[i].chomp}'" if debug==1
    arg_count=i+1
    puts "DEBUG#{i}: associated with'#{ARGV[arg_count].chomp}'" if debug==1
  elsif ARGV[i].chomp =~ /-help/ or ARGV[i] =~ /\s+/ #need help
    puts "DEBUG3: 'help command received'" if debug==1
    help(command=$0,ship_align_secs)
  else
    puts ""
  end
end

for string in ARGV
 puts "You typed `#{string}` as your argument(s)." if debug==1
 if string =~ /-c/
  cloaking_ship=1
  puts "cloaking is enabled"
 end 
 if string =~/-s/
  my_string=string.split(/:/)[1]
  ship_align_time=ship_align_secs["#{my_string}"]
  puts "align time is set to : #{ship_align_time}"
 end

end

#test area for above class
robot = Robot.new
my_action=Action.new
my_logger=LogParser.new

#load in json file
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

while in_space==1 

  #check for icon - needed to find the yellow icon
  icon_is_visable = check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug) 
  my_action.speak("L3 icon #{icon_is_visable}") if debug ==1

  ###########################################
  #SEQ 0: prerequisite - select the yellow destination icon
  #issues this disappears sometimes at random intervals. 
  ###########################################
  if destination_selected == 0 or icon_is_visable =="no" # only need this once to set state
    robot.delay(500)  #1/2 second delay
    my_action.speak("go 0 single click") if debug == 1
    single_click(robot,ref_point) #click on center of screen 
    #check and click on the yellow destination marker
    my_message=check_clickable(robot,my_start,"jtarget_yellow",clicks=1,yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map,debug)
    puts "We #{my_message} on our destination."
    destination_selected=1
    my_action.speak("go 0 destination selected") if debug ==1
  end

  #check for grey - ocassionally this is white
  are_we_stopped = check_non_clickable(robot,"grey_speed",blue_speed_top,blue_speed_bottom,rgb_color_map,debug)
  my_action.speak("L1 grey stopped #{are_we_stopped}") if debug==1

  #check for blue 
  are_we_moving  = check_non_clickable(robot,"blue_speed",blue_speed_top,blue_speed_bottom,rgb_color_map,debug)
  my_action.speak("L2 blue moving #{are_we_moving}") if debug==1

  #check for icon
  icon_is_visable = check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug)
  my_action.speak("L3 icon #{icon_is_visable}") if debug ==1

  # if debug ==1 #debug icon search 
  #   if icon_is_visable == "yes"
  #     icon_found_count=icon_found_count+1
  #     puts "testing: we see the icon and saw it #{icon_found_count} times"
  #   else
  #     icon_notfound_count=icon_notfound_count+1
  #     puts "testing: we *** do not *** see the icon. Miss count is #{icon_notfound_count}"
  #   end
  #   robot.delay(500)  #1/2 second delay
  # end

  start_jump_count=jump_count
  jump_button_pressed=0
  ###################
  #SEQ: 1. hit jump button
  ###################
  if in_space == 1 and destination_selected == 1 and icon_is_visable == "yes"
    robot.delay(1000)  #1 second delay
    my_action.speak("go 1 jump") if debug ==1
    if cloaking_ship == 1
      puts "hit the align button"
      my_action.hit_the_button(robot,target_location=align_to_top,jump_count,message="a",debug)
      if jump_count > 0 #only cloak when on second jump to avoid stations.
        puts "cloaking routine"
        cloak_ship(robot,cloaking_module,microwarp_module,debug)
      end
    end
 
    jump_count=my_action.hit_the_button(robot,target_location=jump_button_top,jump_count,message="j",debug)



    my_action.speak("jump #{jump_count}")
    jump_button_pressed=1

    #check logs for this message
    #double clicks generate this text #(notify) You cannot do that while warping.
    my_string= capture.log_reader(debug=0,"warping",log_size=5,sec_threshold=2) #warping message with double click or click on speed while in space
    puts "2 - double clicked warpto button twice '#{my_string}'" if my_string != ""
    if my_string =~ /warp/i
      my_action.speak("in warp")
    else 
      my_action.speak("we appaer to have missed a warp. Trying again.")
      jump_count=my_action.hit_the_button(robot,target_location=jump_button_top,jump_count,message="j",debug)
    end 

    if jump_count==1
      robot.delay(7000) #10 second delay near station
    else
      robot.delay(500) #1/2 second delay
    end
  end

  #################
  #SEQ 2: ship should be speeding up blue bar filling
  #################
  if jump_button_pressed ==1
    my_action.speak("go 2 advance") if debug ==1

    #######################################################
    #Ship should be speeding up. Wait until the blue bar is full speed.
    #######################################################
    wait_count =0

    align_time_start=Time.now.to_i #get time in secs
    
    until are_we_moving == "yes" 
       print "...waiting for ship to reach full speed."
       are_we_moving  = check_non_clickable(robot,"blue_speed",blue_speed_top,blue_speed_bottom,rgb_color_map,debug)
       #are_we_stopped = check_non_clickable(robot,"grey_speed",blue_speed_top,blue_speed_bottom,rgb_color_map,debug)
       wait_count=wait_count+1
       robot.delay(500)  #1/2 second delay
                        
       if (wait_count/2) > ship_align_time #over ride for when things are happening too slow
        my_action.speak("acceleration overwait warning") 
        puts "warning acceleration is taking too long. rescanning and clicking on yellow"
        my_message=check_clickable(robot,my_start,"jtarget_yellow",clicks=1,yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map,debug)
        my_action.hit_the_button(robot,target_location=jump_button_top,jump_count,message="j",debug)
        wait_count=0 #reset wait count
       else 
        puts "waiting for align #{wait_count}"
       end
    end
    
    min,sec=(Time.now.to_i-align_time_start).divmod(60) #align time to min secs
    puts "align time was #{min} mins #{sec} seconds"
    
    ###################
    #SEQ 3. waiting for jump completion
    ###################
    my_action.speak("go 3 waiting for jump") if debug ==1
    jump_seq_complete=0
    in_hyper_jump=Time.now.to_i #get time in secs
    #######################################################
    #problem area - logs are not always working/reliable. 
    #Upon jump to a new systems we should get a log entry. *Note* this ocassionally fails. 
    #######################################################
    wait_count =0
    my_jump_click_again = 0 # work around for stuck gates 
    session_change_wait=0
    until jump_seq_complete==1
      robot.delay(500)  #1/2 second delay
      wait_count=wait_count+1

      #Fail SAFE check for icon and monitor speed
      icon_is_visable = check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug)
      are_we_moving  = check_non_clickable(robot,"blue_speed",blue_speed_top,blue_speed_bottom,rgb_color_map,debug)
      my_button_visable = check_non_clickable(robot,"white_icon",jump_button_top,jump_button_bottom,rgb_color_map,debug)
      my_action.speak("L3 icon #{icon_is_visable}") if debug ==1


      my_jump_string=capture.log_reader(debug=0,"Jumping",log_size=5,sec_threshold=2) #jumping is slow 10 secs
      puts "3 - jumping - '#{my_jump_string.to_s}'" if my_jump_string != ""

      my_docking_string=capture.log_reader(debug=0,"docking",log_size=5,sec_threshold=2) #jumping is slow 10 secs
      puts "3 - dockinging - '#{my_docking_string.to_s}'" if my_docking_string != ""

 
      if ( my_jump_string =~ /jumping/i )
        my_action.speak("#{my_jump_string}") #speak jump string from log
        jump_seq_complete=1
        robot.delay(2000) #screen blinks. This is a work around.
      elsif (my_docking_string =~ /docking/i )
        my_action.speak("docking finished")
        min,sec=(Time.now.to_i-my_start).divmod(60)
        puts "run time was #{min} mins #{sec} seconds"
        exit 
      elsif ( icon_is_visable=="no" and are_we_moving =="no")
        my_action.speak("failsafe jump wait 5 secs")
        jump_seq_complete=1
        robot.delay(5000) #5 second delay
      else
        min,secs=(Time.now.to_i-in_hyper_jump).divmod(60)
        #work around cloaker ship not registering jump
        #ocassionally we mess up a jump gates lock us out. This should catch it. 
        
        if icon_is_visable=="yes" and are_we_moving=="no"
          if session_change_wait ==0
            my_action.speak("stopping")  
            my_action.speak("pressing jump") 
            single_click(robot,target_location=jump_button_bottom) #force single click
          end
          session_change_wait=session_change_wait+1
          my_action.speak("#{session_change_wait}") #if debug == 1
          
          icon_is_visable = check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug)
          robot.delay(100)
             
          if session_change_wait % 7 == 0 and icon_is_visable == "yes" # every 7 
            my_action.speak("jump again") if debug == 1
            single_click(robot,target_location=jump_button_bottom) #force single click
          end           
        end
      end 
    end
    mins,secs=(Time.now.to_i-in_hyper_jump).divmod(60) #get time in warp 
    puts "in warp time was #{mins} minutes ,#{secs} seconds"

    ########################################################
    #SEQ 4: Verifying end of jump sequence. Overview should display the 'i' icon on the far right of the screen. 
    ########################################################
    wait_for_session_change=Time.now.to_i
    wait_count =0 
    jump_button_visable = check_non_clickable(robot,"white_icon",jump_button_top,jump_button_bottom,rgb_color_map,debug)
    icon_is_visable = check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug)
    single_click(robot,ref_point) #move mouse to see the buttons 

    until icon_is_visable=="yes" and jump_button_visable=="yes"
     my_action.speak("go 4 refresh") if debug == 1 
     print "checking refresh"
     robot.delay(250)  #1/2 second delay 
     wait_count=wait_count+1
     icon_is_visable = check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map,debug)
     jump_button_visable = check_non_clickable(robot,"white_icon",jump_button_top,jump_button_bottom,rgb_color_map,debug)
     min,secs=(Time.now.to_i-wait_for_session_change).divmod(60)
     if secs % 3 == 0  and wait_count > 10 #work around - ocassionally we can lose track of the gate after completing a jump. re-scan for it if lost after 7 seconds.
       puts" lost white icon or jump_button: we should click on the yellow icon again."
       #check and click on the destination indicator
       my_action.speak("go 4B lost track of the gate. jump_button visible #{jump_button_visable} icon visible #{icon_is_visable}") 
       my_message=check_clickable(robot,my_start,"jtarget_yellow",clicks=1,yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map,debug)
       wait_count=0 #reset wait count
     end
    end
    
  end
  
end  


