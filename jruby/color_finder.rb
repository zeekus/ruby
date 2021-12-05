#!/usr/bin/jruby
#filename: color_finder.rb
#description: looks gets locations from under the pointer and returns both the position and the r,g,b color and hex
require 'java'

java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
java_import 'java.awt.event.KeyEvent'   #presing keys

rgb_hex_map={ "1E1E1E" => "pale_black" }

def speak(message)
  wait_delay=2 # 2 seconds 
  system("echo #{message} | espeak > /dev/null 2> /dev/null") #supress messages
  sleep wait_delay
end

def find_color_match(robot,x,y,target_color,rgb_hex_map)
  mycolors=robot.getPixelColor(x,y)
  r = mycolors.red
  g = mycolors.green
  b = mycolors.blue
  hex_string=(r.to_s(16) + g.to_s(16) + b.to_s(16)).upcase #RGB color to HEX format
  print "test: find_color_match: at [#{x},#{y}] color is #{hex_string} while target color is #{target_color}\n"    
  if rgb_hex_map["1E1E1E"] == target_color and rgb_hex_map != nil
     puts "successful match"
  end
end

def get_color_of_pixel(robot,x,y)
  mycolors=robot.getPixelColor(x,y)
  r = mycolors.red
  g = mycolors.green
  b = mycolors.blue
  print "get_color_of_pixel: at [#{x},#{y}] color is r=#{r},g=#{g},b=#{b}\n"
  return r,b,g
end

def get_mouse_loc(robot)
    my_x=MouseInfo.getPointerInfo().getLocation().x
    my_y=MouseInfo.getPointerInfo().getLocation().y
    puts "[#{my_x},#{my_y}]"
    return my_x,my_y
end


robot=Robot.new

counter = 1
stop_number = 3 
array_of_colors=[]
#loop to get the color of 10 different points on the screen

while counter <= stop_number  do
 x,y=get_mouse_loc(robot)
 r,b,g=get_color_of_pixel(robot,x,y)
 hex_string=("#" + r.to_s(16) + g.to_s(16) + b.to_s(16)).upcase #RGB color to HEX format
 array_of_colors.push(hex_string)
 print "while loop: location [#{x},#{y}] has the color r=#{r},g=#{g},b=#{b} and the hex of #{hex_string}\n"
 #find_color_match(robot,x,y,target_color="pale_black",rgb_hex_map)
 sleep 5
 counter +=1
end

#sample of colors sorted
for line in array_of_colors.uniq
   puts line
end
