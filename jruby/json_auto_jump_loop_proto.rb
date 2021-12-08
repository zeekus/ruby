#!/usr/bin/jruby
#filename: automatic_moving.rb
#description: moves ship from system to system.

require 'java'

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
    wait_delay=2 # 2 seconds 
    system("echo #{message} | espeak > /dev/null 2> /dev/null") #supress messages
    sleep wait_delay
  end

  def get_current_mouse_location(robot)
    x=MouseInfo.getPointerInfo().getLocation().x
    y=MouseInfo.getPointerInfo().getLocation().y
    self.mydebugger("get_current_mouse_location", "under mouse location", "[#{x},#{y}]" ) 
    return [x,y]
  end

  def generate_random_location 
    myloc=[]
    x = rand(1000) 
    y = rand(1000)
    myloc=[x,y]
    self.mydebugger("generate_random_location", "future location is", myloc ) 
    return myloc
  end# end generate_random_location

  def mydebugger(myfuncname,myfillerstring,mylocations)
    if $debug==1
      puts "DEBUG 1:#{myfuncname} #{myfillerstring} #{mylocations}" 
    end
  end

  def move_to_target_pixel_like_human(robot,target_location)
    myloc=[] 
    myloc=get_current_mouse_location(robot)
    mydebugger("move_to_target_pixel_like_human", "mouse location", myloc ) 

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
	     self.mydebugger("move_to_target_pixel_like_human", "target location", "#{target_location[0]},#{target_location[1]}" ) 
       robot.delay(10)
       return(1)
      end #end if
      robot.mouseMove(x,y)
      robot.delay(1)
    end #end of until loop
  end #end function move_to_target_pixel_like_human

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
        myloc=[] 
        tmp=[x,y]
        mycolors=robot.getPixelColor(x,y)
        self.move_to_target_pixel_like_human(robot,tmp)
        r = mycolors.red
        g = mycolors.green
        b = mycolors.blue
        hex_string=(r.to_s(16) + g.to_s(16) + b.to_s(16)).upcase #RGB color to HEX format
        if rgb_color_map[hex_string] != nil and target_color == rgb_color_map[hex_string]
          puts "possible match - The pixel could be part of the " + rgb_color_map[hex_string]
          return [x,y]
        else
         #nulls will break things
         puts "warning: The pixel color of #{hex_string} is not mapped. Keep on looking."
        end #if loop
      end  #for y loop 
    end #for x loop
    
    return [0,0] #nothing found
  end
  
  def color_intensity (r,g,b)
    colori = ( r + g + b ) / 3.0
     return colori 
  end

end #end class


def single_click(robot,target_location)

   #simulate_human_mouse_movement(robot,target_location) 
   #target_location=[x,y]
    
   target=Findtarget.new
   target.move_to_target_pixel_like_human(robot,target_location)
  
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
   target.move_to_target_pixel_like_human(robot,target_location)
    for i in (1..2)  
      robot.delay(150)
      robot.mousePress(InputEvent::BUTTON1_MASK)
      robot.delay(150)
      robot.mouseRelease(InputEvent::BUTTON1_MASK)
   end
end

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
        "605617" => "jtarget",
        "635A14" => "jtarget",
        "483D1C" => "jtarget",
        "796B25" => "jtarget",
        "A8A013" => "jtarget",
        "A29B11" => "jtarget",
        "514420" => "jtarget",
        "B4AEF"  => "jtarget",
        "B3ADF"  => "jtarget",
        "FFFFFF" => "white_icon"}

#test area for above class
robot = Robot.new
mytarget=Findtarget.new

my_json_file=("/var/tmp/locations.json")
if File.exist?(my_json_file)
  #puts "file exits. opening file..."
  file = File.read(my_json_file)
  data_hash = JSON.load(file) #load in json file holding locations
fi

#variables come from json
ref_point=data_hash["screen_center"]
align_to_bottom=data_hash["align_to_bottom"]
align_to_top=data_hash["align_to_top"]
warp_to_bottom=data_hash["warp_to_bottom"]
warp_to_top=data_hash["warp_to_top"]
jump_button_top=data_hash["jump_button_top"]
jump_button_bottom=data_hash["jump_button_bottom"]
white_i_icon_top=data_hash["white_i_icon_top"]
white_i_icon_bottom=data_hash["white_i_icon_bottom"]
blue_speed_top=data_hash["blue_speed_top"]
blue_speed_bottom=data_hash["blue_speed_bottom"]
yellow_icon_left_top=data_hash["yellow_icon_left_top"]
yellow_icon_right_bottom=data_hash["yellow_icon_right_bottom"]
gold_undock=data_hash["gold_undock"]


location=mytarget.color_pixel_scan_in_range(robot,"jtarget",yellow_icon_left_top,yellow_icon_right_bottom,rgb_color_map)

if location != [0,0]
    mytarget.move_to_target_pixel_like_human(robot,location)
    single_click(robot,target_location)
end
