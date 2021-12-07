#!/usr/bin/jruby
#filename: automatic_moving.rb
#description: moves ship from system to system.

require 'java'
require 'json'

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
    end
      puts "warning missing espeak..."
      puts "#{message}"
  end

  def get_current_mouse_location(robot)
    x=MouseInfo.getPointerInfo().getLocation().x
    y=MouseInfo.getPointerInfo().getLocation().y
    self.mydebugger("get_current_mouse_location", "under mouse location", "[#{x},#{y}]" ) 
    return [x,y]
  end

  def get_random_point 
    myloc=[]
    x = rand(1000) #limit
    y = rand(1000) #limit 
    myloc=[x,y]
    self.mydebugger("get_random_point", "future location is", myloc ) 
    return myloc
  end# end get_random_point

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

  def color_pixel_scan_in_range(robot,target_color,yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map) 
    count=0
    mybreak =0
    found_icon_coord=[]
    found_icon_coord =[0,0] #array location
  
    #scan on x axis main loop
    for x in yellow_icon_left_top[0]..yellow_icon_right_bottom[0]
      #scan on y axis inner loop
      for y in yellow_icon_left_top[1]..yellow_icon_right_bottom[1]
        count = count + 1
        found_icon_coord=[x,y]
        mycolors=robot.getPixelColor(x,y)
        #self.move_mouse_to_target_like_human(robot,tmp)
        r = mycolors.red
        g = mycolors.green
        b = mycolors.blue
        hex_string=(r.to_s(16) + g.to_s(16) + b.to_s(16)).upcase #RGB color to HEX format
        my_best_guess=guess_color(r,g,b) 
        if ( target_color == my_best_guess) 
          puts "possible match - The pixel could be #{target_color}"
          return found_icon_coord
        elif rgb_color_map[hex_string] != nil and target_color
          puts "possible match - The pixel could be #{rgb_color_map[hex_string]}"
          return found_icon_coord
        else 
         puts "warning: The pixel color of #{hex_string} is not mapped. Keep on looking. Best Guess is color is #{my_best_guess}"
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

def check_non_clickable(robot,searchable,pixel_left_top,pixel_right_bottom,rgb_color_map)
  mytarget=Findtarget.new
  target_location=mytarget.color_pixel_scan_in_range(robot,searchable,pixel_icon_left_top,pixel_icon_right_bottom,rgb_color_map)

  if target_location != [0,0]
    mytarget.move_mouse_to_target_like_human(robot,[1000,1000])
    return "yes"
   else
    puts "warn: we didn't find the #{searchable} at #{target_location}"
    return "no"
   end
end

def check_clickable(robot,searchable,clicks,icon_left_top,icon_right_bottom,rgb_color_map)
  mytarget=Findtarget.new
  target_location=mytarget.color_pixel_scan_in_range(robot,searchable,icon_left_top,icon_right_bottom,rgb_color_map)

   if target_location != [0,0] and target_location != nil 
    mytarget.move_mouse_to_target_like_human(robot,target_location)
    if clicks==1
      single_click(robot,target_location)
    else
      double_click(robot,target_location)
    end
    return "warping"
   else
    puts "error: we didn't find the #{searchable} or click"
    exit
   end
end

###################################################
#Future - todo - the color map should be put in a json file
###################################################
#maps for the RGB colors in HEX 
rgb_color_map={ 
  "5C467"  => "gold_undock",
  "5F489"  => "gold_undock",
  "5B455"  => "gold_undock",
  "5D478"  => "gold_undock",
  "508FC5" => "blue_fast",
  "4F8CC1" => "blue_fast",
  "5792C4" => "blue_fast",
  "5290C4" => "blue_fast",
  "558DBF" => "blue_fast",
  "508FC4" => "blue_fast",
  "5690C1" => "blue_fast",
  "5490C2" => "blue_fast",
  "5590C3" => "blue_fast",
  "528FC4" => "blue_fast",
  "A6A19B" => "grey_slow",
  "A39E98" => "grey_slow",
  "A7A29B" => "grey_slow",
  "A4A099" => "grey_slow",
  "A4A09A" => "grey_slow",
  "9E9C97" => "grey_slow",
  "A5A09A" => "grey_slow",
  "9C9791" => "grey_slow",
  "605617" => "jtarget_yellow",
  "635A14" => "jtarget_yellow",
  "483D1C" => "jtarget_yellow",
  "796B25" => "jtarget_yellow",
  "A8A013" => "jtarget_yellow",
  "A29B11" => "jtarget_yellow",
  "514420" => "jtarget_yellow",
  "B4AEF"  => "jtarget_yellow",
  "B3ADF"  => "jtarget_yellow",
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
fi

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

destination_selected=0
in_space=1
jump_count = 0 

while in_space==1
  are_we_stopped = check_non_clickable(robot,"grey_slow",blue_slow_top,blue_slow_bottom,rgb_color_map)
  are_we_moving  = check_non_clickable(robot,"blue_fast",blue_speed_top,blue_speed_bottom,rgb_color_map)
  if are_we_stopped=="yes" and are_we_moving "no" and in_space == 1 and destination_selected == 1
    puts "==> We appear to be stopped..."
    double_click(robot,target_location=jump_button_top)
    jump_count = jump_count + 1
    sleep 5
    are_we_moving  = check_non_clickable(robot,"blue_fast",blue_speed_top,blue_speed_bottom,rgb_color_map)
    if are_we_moving == "no"
      are_we_stopped = check_non_clickable(robot,"grey_slow",blue_slow_top,blue_slow_bottom,rgb_color_map)
      if are_we_stopped == "no"
        puts "we must be speeding up"
        sleep 5
      else 
        puts "slow ass ship."
      end
    end
  else
    #nothing
  end
  
  if destination_selected == 0
    success=check_clickable(robot,"jtarget_yellow",clicks=1,yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map)
    destination_selected=1
    puts "2. lets get going: initial warp"
    status=double_click(robot,target_location=jump_button_top])
    jump_count = jump_count + 1
    sleep 15
  else
    if destination_selected == 1 
      puts "waiting 5 secs. We in jump sequence #{jump_count}"
      sleep 5
    end 
  end  
   
end