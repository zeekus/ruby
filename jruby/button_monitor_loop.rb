#filename: button_monitory_loop.rb
#description: monitors state of buttons . 
#  Most buttons are dynamic and change color when a mouse is moved  


require 'java'
require 'json'
require 'time'
java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
# java_import 'java.awt.event.KeyEvent'   #presing keys
# java_import 'java.awt.Toolkit'          #gets screens size

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
    limit=10 #log limit
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
      #puts "looking in #{logfile_loc_glob} for log file"
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
        capture_string=target_phrase.upcase #return target phrase in upper case if nothing
        puts "debug log_reader result is #{result}" if debug==1
        if line =~ /#{target_phrase}/i  and result==1
           if target_phrase =~ /jumping/i or target_phrase =~ /undocking/i 
            capture_string = line.split("(None) ")[1]#remove first part of line so just get the jumping info
           elsif target_phrase =~ /docking/i or target_phrase =~ /while warping/i or target_phrase =~ /please wait/i or target_phrase =~ /cloaking.*fails/i
            capture_string = line.split("(notify) ")[1]#remove first part of line so just get the docking or warping line  
           elsif target_phrase =~ /combat/i
            capture_string = line.split("(combat) ")[1]
           end
        end
      end
    }
    return capture_string #convert to string just in case
  end #function
end #class

class Viewer


  def self.check_selected_item_menu()
    #possible future feature
    #low-medium depending on what is checked. 
    #least reliable unless we focus on the  dot images at position 1,4,and 9
    #Selected Item menu- icons
    #at gate stopping or stopped{ 'align_to'=>'1', 'warp_to'=>'0', 'jump'=>'1','orbit=>'1', 'keep_distance=>'0', 'target=>'1', 'eye1'==>'1', 'eye2' =>'1' , 'i_icon'=>'1']
    #at station stopping or stopped{ 'align_to'=>'1', 'warp_to'=>'0', 'dock'=>'1','orbit=>'1', 'keep_distance=>'0', 'target=>'1', 'eye1'==>'1', 'eye2' =>'1' , 'i_icon'=>'1']
    #in warp to gate or station { 'align_to'=>'0', 'warp_to'=>'0', 'jump'=>'1','orbit=>'0', 'keep_distance=>'0', 'target=>'0', 'eye1'==>'0', 'eye2' =>'1' , 'i_icon'=>'1']
  end

  def self.look_for_blue_session_cloak_timer
    #possible future feature 
    #do we see the session timer. Indicates session change completed. 
    #reliability: low-medium - can fail 20% of the time. 
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
    
    Feedback.speak("scanning for clickable target") if debug ==1
    target_location=[0,0] #empty location
    counter=0

    #scan until we find something or try three times
    until counter>=3 or target_location !=[0,0] #scan 3 times before failing.
      target_location=Utility.color_pixel_scan_in_range(robot,search_element,left_top_xy,right_bottom_xy,rgb_color_map,debug)
      counter=counter+1
      robot.delay(500) #wait 500 seconds before each scan failure
    end
    if target_location != [0,0] and target_location != nil 
      Interact.single_click(robot,target_location,debug,randomize)
      return "single clicked"
    else
      puts "error: we didn't find the #{search_element} or click"
      Feedback.speak("lost track of #{search_element}. Exiting.") 
      min,sec=(Time.now.to_i-my_start).divmod(60)
      puts "run time was #{min} mins #{sec} seconds"
      exit
    end
  end

  def self.recurring_visual_checks(robot,ref_point,rgb_color_map,data_hash,debug)

    #visual checks 
    
    #check for a specific color 
    i_icon_visible= Viewer.check_non_clickable(robot,"white_icon",data_hash["white_i_icon_top"],data_hash["white_i_icon_bottom"],rgb_color_map,debug) 
    are_we_stopped = Viewer.check_non_clickable(robot,"grey_speed",data_hash["blue_speed_top"],data_hash["blue_speed_bottom"],rgb_color_map,debug)
    are_we_moving  = Viewer.check_non_clickable(robot,"blue_speed",data_hash["blue_speed_top"],data_hash["blue_speed_bottom"],rgb_color_map,debug)
    
    #checks for interactive buttons
    align_is_interactive=Utility.button_check(robot,x=data_hash["align_to_top"][0],y=data_hash["align_to_top"][1],debug=0,ref_point)  #align button disappers when we warp.
    warp_to_is_interactive=Utility.button_check(robot,x=data_hash["warp_to_top"][0],y=data_hash["warp_to_top"][1],debug=0,ref_point) #jump button disappers when we warp or approach gate.
    orbit_button_visible=  Utility.button_check(robot,x=data_hash["orbit_button_top"][0],y=data_hash["orbit_button_top"][1],debug=0,ref_point) #orbit button disappers when warping or session complete.

    # Feedback.speak("L1 grey stopped #{are_we_stopped}") if debug==1
    # Feedback.speak("L2 blue moving #{are_we_moving}") if debug==1
    # Feedback.speak("L3 icon #{i_icon_visible}") if debug ==1

    return i_icon_visible,orbit_button_visible,are_we_stopped,are_we_moving,align_is_interactive,warp_to_is_interactive
  end 

end

class Feedback
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

class Interact

  def self.single_click(robot,target_location,debug,randomize)
    target_location=Utility.offset_xy_position(target_location) if randomize==1
    move_mouse_to_target_like_human(robot,target_location,debug)
    robot.delay(rand(150..200))
    #left click
    robot.mousePress(InputEvent::BUTTON1_MASK)
    robot.delay(rand(150..350))
    robot.mouseRelease(InputEvent::BUTTON1_MASK)
 end
 
 def self.double_click(robot,target_location,debug,randomize)
    for i in (1..2)
      self.single_click(robot,target_location,debug,randomize)
    end
 end

  def self.cloak_ship(robot,cloaking_module,micro_warpdrive,debug)
    #click on the cloaking module
    if debug==1
      Feedback.speak("cloaking")
    end
    #covert ops cloak on 
    robot.delay(rand(400..500))
    single_click(robot,target_location=cloaking_module,debug,randomize=1)
 end

 def self.hit_the_button(robot,target_location,mycount,message,debug) 
   #'j' for jump 'a' for align 
  if message =~ /j/i or message =~ /a/i or message =~ /w/i #jump,align,or warpto button gets double click
    my_message=double_click(robot,target_location,debug,randomize=1) #double click
  else 
    my_message=single_click(robot,target_location,debug,randomize=1) #every thing else gets single click
  end
 
  Feedback.speak(message) if debug == 1
  puts "We clicked #{my_message}" if debug==1
  mycount = mycount + 1
  puts "count is #{mycount}. We pressed #{message}"
  return mycount
 end

 def self.micro_warpdrive_cloak_trick ( robot,cloaking_module,micro_warpdrive,align_button,warp_button,debug=1)
  if debug==1
    Feedback.speak("mwd cloaking")
  end
  puts "mwd cloaking"

  #assuming align pressed earlier and successful.
  robot.delay(rand(600..700))
  double_click(robot,micro_warpdrive,debug,randomize=1) #click mwd

  robot.delay(rand(600..750))
  double_click(robot,cloaking_module,debug,randomize=1) #click cloaker

  #wait 5
  robot.delay(rand(4500..6000)) #cycle end on mwd

  #click cloak
  double_click(robot,cloaking_module,debug,randomize=1) #click cloaker

  #click jump or warp to
  double_click(robot,warp_button,debug,randomize=1)
 end

 def self.move_mouse_to_target_like_human(robot,target_location,debug=0) 
  x,y=Utility.get_current_mouse_location(robot,debug)
  Feedback.mydebugger("move_mouse_to_target_like_human", "mouse location", [x,y] ) 

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
     my_tmp_location=self.get_current_mouse_location(robot,debug)
     self.mydebugger("move_to_target_pixel_like_human", "target location", "#{target_location[0]},#{target_location[1]}" ) 
     robot.delay(1)
     return(1)
    end #end if
    robot.mouseMove(x,y)
    robot.delay(1) #mouse move is based on loop (0.1 for faster)
  end #end of until loop
 end #end function move_to_target_pixel_like_human
end #end class Interact


class Utility

  def self.button_check(robot,x,y,debug,ref_point)

    Interact.move_mouse_to_target_like_human(robot,[x,y],debug=0) #move mouse on button
    robot.delay(500)
    
    #start location
    r,g,b,a=get_color_of_pixel(robot,x,y,debug=1) #with mouse on location
    hue1=color_intensity(r,g,b)
    puts "hue with mouse on is #{hue1}"
    
    Interact.move_mouse_to_target_like_human(robot,[x,y-100],debug=0) #move mouse off button
    r,g,b,a=get_color_of_pixel(robot,x,y,debug=1) #with mouse off location
    hue2=color_intensity(r,g,b)
    puts "hue with mouse off is #{hue2}"

    if (hue1 >  hue2 )
      mydiff= hue1 - hue2
      puts "hue difference is #{mydiff}"
      puts "button is darker with mouse moved off"
      return "yes"
    elsif ( hue2 > hue1)
      mydiff= hue2 - hue1
      puts "hue difference is #{mydiff}"
      puts "button is lighter with mouse moved off"
      return "yes" 
    else
      puts "hue is the same. not a clickable"
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
    
  def self.get_color_of_pixel(robot,x,y,debug)
    mycolors=robot.getPixelColor(x,y)
    r = mycolors.red
    g = mycolors.green
    b = mycolors.blue
    print "get_color_of_pixel: at [#{x},#{y}] color is r=#{r},g=#{g},b=#{b}\n" if debug==1
    return r,g,b
  end


  def self.get_hex_color(robot,x,y,debug)
    rgb=get_color_of_pixel(robot,x,y,debug)
    hex_string=""
    for color in rgb
      hex=color.to_s(16).upcase
      hex = "0#{hex}" if hex.length < 2 #length of each HEX octet is always 2
      hex_string="#{hex_string}#{hex}" #RGB color to HEX format
     end 
    return hex_string
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
    Feedback.mydebugger("get_current_mouse_location", "under mouse location", "[#{x},#{y}]" ) if debug==1
    return [x,y]
  end
end #Utility class


#load in json file that holds locations of mappings generated from json_setup_screen_points.rb 
#Screen Location: variables come from json
my_json_file=("/var/tmp/locations.json")
if File.exist?(my_json_file)
  #puts "file exits. opening file..."
  file = File.read(my_json_file)
  data_hash = JSON.load(file) #load in json file holding locations
else 
  puts "error missing #{my_json_file}"
  exit
end


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

robot = Robot.new

in_space=1
debug=1
ref_point=data_hash["screen_center"]

while in_space==1 do 
  sleep 5
  #randomize places we click for each iteration
  align_button=Utility.randomize_click_target(data_hash["align_to_top"],data_hash["align_to_bottom"])
  warp_button=Utility.randomize_click_target(data_hash["warp_to_top"],data_hash["warp_to_bottom"])
  jump_button=Utility.randomize_click_target(data_hash["jump_button_top"],data_hash["jump_button_bottom"])
  orbit_button=Utility.randomize_click_target(data_hash["orbit_button_top"],data_hash["orbit_button_bottom"])

  #run button visual checks 
  i_icon_visible,orbit_button_visible,are_we_stopped,are_we_moving,align_is_interactive,warp_to_is_interactive=Viewer.recurring_visual_checks(robot,ref_point,rgb_color_map,data_hash,debug)
  
  Feedback.speak("align button visible: #{align_is_interactive}")
  Feedback.speak("warp button visible: #{warp_to_is_interactive}")
  Feedback.speak("icon is visible #{i_icon_visible}")
  Feedback.speak("moving: #{are_we_moving}")
  Feedback.speak("orbit_button #{orbit_button_visible}")


  if i_icon_visible == "yes" and orbit_button_visible == "yes"
    Feedback.speak("we are at the gate or ready dock.")
  end
  if i_icon_visible =="yes" and orbit_button_visible == "no" and align_is_interactive == "no"
    Feedback.speak("we are warping.")
  end
  if are_we_moving=="yes" and orbit_button_visible == "no" and i_icon_visible == "yes" and align_is_interactive == "yes"
    Feedback.speak("aligning or ready to warp.")
  end
end



