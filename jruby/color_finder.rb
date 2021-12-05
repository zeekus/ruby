#!/usr/bin/jruby
#filename: color_finder.rb
#description: looks gets locations from under the pointer and returns both the position and the r,g,b color
require 'java'

java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
java_import 'java.awt.event.KeyEvent'   #presing keys

def speak(message)
  wait_delay=2 # 2 seconds 
  system("echo #{message} | espeak > /dev/null 2> /dev/null") #supress messages
  sleep wait_delay
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


# robot = Robot.new
# my_array=[]
# get_mouse_loc(robot)

robot=Robot.new

counter = 1
stop_number = 10
while counter <= stop_number  do
 x,y=get_mouse_loc(robot)
 r,b,g=get_color_of_pixel(robot,x,y)
 print "while loop: location [#{x},#{y}] has the color r=#{r},g=#{g},b=#{b}\n"
 sleep 5
 counter +=1
end
