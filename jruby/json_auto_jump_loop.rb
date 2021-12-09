#!/usr/bin/jruby
#filename: automatic_moving.rb
#description: moves ship from system to system until docking.

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

class Findtarget

  def speak(message)
    if File.exist?("/usr/bin/espeak")  
     wait_delay=2 # 2 seconds 
     system("echo #{message} | espeak > /dev/null 2> /dev/null") #supress messages
     puts "#{message}"
     sleep wait_delay
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

  def color_pixel_scan_in_range(robot,target_color,left_top_xy,right_bottom_xy,rgb_color_map) 
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
         puts "warning: The pixel color of #{hex_string} at [#{x},#{y}] is not mapped. Keep on looking. Best Guess is color is #{my_best_guess}"
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

end #end class


def single_click(robot,target_location)

   #simulate_human_mouse_movement(robot,target_location) 
   #target_location=[x,y]
    
   target=Findtarget.new
   target.move_mouse_to_target_like_human(robot,target_location)
  
   #left click
   #logwrite("event: single click at #{x},#{y}")
   robot.mousePress(InputEvent::BUTTON1_MASK)
   robot.delay(155)
   #logwrite("event: single unclick at #{x},#{y}")
   robot.mouseRelease(InputEvent::BUTTON1_MASK)
   robot.delay(155)
end

def double_click(robot,target_location)
  target=Findtarget.new
  target.move_mouse_to_target_like_human(robot,target_location)
  
   for i in (1..2)
    robot.delay(150)
    robot.mousePress(InputEvent::BUTTON1_MASK)
    robot.delay(150)
    robot.mouseRelease(InputEvent::BUTTON1_MASK)
   end
end

def check_non_clickable(robot,search_element,left_top_xy,right_bottom_xy,rgb_color_map)
  mytarget=Findtarget.new

  target_location=mytarget.color_pixel_scan_in_range(robot,search_element,left_top_xy,right_bottom_xy,rgb_color_map)

  if target_location != [0,0]
    return "yes"
  else
    puts "warn: we didn't find the #{search_element} at #{target_location}"
    if search_element=="grey_speed" #gray and white look very similar so we check for both
      #check for white it sometimes changes to that color
      target_location=mytarget.color_pixel_scan_in_range(robot,"white_icon",left_top_xy,right_bottom_xy,rgb_color_map)
      if target_location != [0,0]
        return "yes" #this was white but in the grey search area
      else
        return "no" #we are sure this grey
      end
    end

    return "no" # none grey
  end
end

def check_clickable(robot,search_element,clicks,left_top_xy,right_bottom_xy,rgb_color_map)
  mytarget=Findtarget.new
  mytarget.speak("moving mouse to clickable target")
  target_location=mytarget.color_pixel_scan_in_range(robot,search_element,left_top_xy,right_bottom_xy,rgb_color_map)

   if target_location != [0,0] and target_location != nil 
    mytarget.move_mouse_to_target_like_human(robot,target_location)
    # if clicks==1
      mytarget.speak("single click")
      single_click(robot,target_location)
    # else
    #   mytarget.speak("double click")
    #   double_click(robot,target_location)
    # end
    return "double clicked"
   else
    puts "error: we didn't find the #{search_element} or click"
    exit
   end
end

def wait_until_we_are_moving(robot,speed_top,speed_bottom,rgb_color_map,debug)
  mytarget=Findtarget.new
  mytarget.speak("wait_unit_we_are_moving")
  are_we_moving="no"
  are_we_stopped="yes"
  until are_we_moving == "yes" and are_we_stopped == "no"
    are_we_moving  = check_non_clickable(robot,"blue_speed",speed_top,speed_bottom,rgb_color_map)
    are_we_stopped = check_non_clickable(robot,"grey_speed",speed_top,speed_bottom,rgb_color_map)
    mytarget.speak("fast_blue #{are_we_moving} grey_speed #{are_we_stopped} ") if debug==1
    puts "waiting to speeding up..."
  end
  
  return "yes" #results 
  
end



def is_log_entry_current(loginfo)
  debug=0
  #log date time parser

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
  if diff < 25 #25 second theshold
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

  #initialize variables
  dock_string=""
  jump_string="" 
 
  last_3.each do |line|  #look at it
    if /^\[/.match(line) #sometimes the lines don't have the time ignore them
      result=is_log_entry_current(line.chomp) #current log entry only
      if result ==1
        # puts "is string an array ?"
        # p string.instance_of? Array
        if line =~ /Requested to dock/i
          dock_string = line.split("(notify) Requested to ")[1]#remove first part of line so just get the jumping info
          return dock_string #end of journey see this
        else 
          jump_string = line.split("(None) ")[1]#remove first part of line so just get the jumping info
          return jump_string
        end
      end
    end
   end
   return "" #return an empty string to prevent an object pointer from getting returned and messsing up things
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

#test area for above class
robot = Robot.new
mytarget=Findtarget.new

#load in json file
my_json_file=("/var/tmp/locations.json")
if File.exist?(my_json_file)
  #puts "file exits. opening file..."
  file = File.read(my_json_file)
  data_hash = JSON.load(file) #load in json file holding locations
end

#variables come from json
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

destination_selected=0
in_space=1
jump_count = 0 
are_we_moving="no"
are_we_stopped="yes"
icon_found_count=0
icon_notfound_count=0

debug=1
cloaking_ship=0

while in_space==1 
  if destination_selected == 0 # only need this once to set state
    mytarget.speak("center") 
    single_click(robot,ref_point) #click on center of screen 
    #check and click on the destination indicator
    my_message=check_clickable(robot,"jtarget_yellow",clicks=1,yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map)
    puts "We #{my_message} on our destination."
    destination_selected=1
    #stop ship 
    mytarget.speak("stop ")
    sleep 2
  end

  are_we_stopped = check_non_clickable(robot,"grey_speed",blue_speed_top,blue_speed_bottom,rgb_color_map)
  mytarget.speak("L1 grey #{are_we_stopped}") if debug==1

  are_we_moving  = check_non_clickable(robot,"blue_speed",blue_speed_top,blue_speed_bottom,rgb_color_map)
  mytarget.speak("L2 blue #{are_we_moving}") if debug==1

  icon_is_visable = check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map)
  mytarget.speak("L3 icon #{icon_is_visable}") if debug ==1

  
  if icon_is_visable == "yes"
    icon_found_count=icon_found_count+1
    puts "testing: we see the icon and saw it #{icon_found_count} times"
  else
    icon_notfound_count=icon_notfound_count+1
    puts "testing: we *** do not *** see the icon. Miss count is #{icon_notfound_count}"
  end
  sleep 2

  if are_we_stopped=="yes" and in_space == 1 and destination_selected == 1 and icon_is_visable == "yes"
    if cloaking_ship == 1
      puts "We appear to be stopped... clicking align" 
      my_message=double_click(robot,target_location=align_to_top)
      ##################
      #TODO
      #need logic to turn on the cloaking device here
      ##################
      puts "We #{my_message} on align_to_top."
      ##################
      #wait for speed 
      ##################
      are_we_moving=wait_until_we_are_moving(robot,blue_speed_top,blue_speed_bottom,rgb_color_map,debug)
      mytarget.speak("align_to")
    end
    
    ####################
    #Hit the jump button 
    ####################
    my_message=double_click(robot,target_location=jump_button_top)
    mytarget.speak("jump")
    puts "We #{my_message} on warp_to_top."
    jump_count = jump_count + 1
    puts "jump count is #{jump_count}. We are in warp..."

    jump_seq_complete=0 
    mytarget.speak("waiting for completion")

    jump_seq_complete=0
    #wait until log says jump is complete
    until jump_seq_complete==1
     sleep 1
     parsed_log=log_reader() #gives an array for some reason
     if parsed_log.to_s =~ /jumping/i 
       puts parsed_log
       mytarget.speak(parsed_log)
       jump_seq_complete=1
     end
     if parsed_log.to_s =~ /dock/i and parsed_log !~ /jumping/i
       mytarget.speak("docking finished")
       exit 
     end
    end

    #gold_undock_is_visable = check_non_clickable(robot,"gold_undock",gold_undock,gold_undock,rgb_color_map)

    #if gold_undock_is_visable=="yes"
      #in_space=0
      #exit 
    #end
  
  #verify icon refeshed and jump squence really finished
  until icon_is_visable=="yes"
    icon_is_visable = check_non_clickable(robot,"white_icon",white_i_icon_top,white_i_icon_bottom,rgb_color_map)
  end
  mytarget.speak("jump #{jump_count}")
  else
    sleep 1 
  end
end  