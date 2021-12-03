#!/usr/bin/jruby
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
  return "#{r},#{b},#{g}"
end

def write_file_for_configuration(filename,a)
  file = File.new(filename,"w")                                                      
  a.each do |x|
	  file.puts x
  end
  file.close
end

def get_mouse_loc(robot)
  my_x=MouseInfo.getPointerInfo().getLocation().x
  my_y=MouseInfo.getPointerInfo().getLocation().y
  puts "[#{my_x},#{my_y}]"
  return my_x,my_y
end

robot = Robot.new
my_array=[]

speak("setup screen")
sleep 1

#check color at location
speak("move the mouse to location on the screen that is black")
my_x,my_y=get_mouse_loc(robot)
my_array.push("black_icon=[#{my_x},#{my_y}]")
rgb_color=get_color_of_pixel(robot,my_x,my_y)
print "black color of pixel is #{rgb_color}\n"
my_array.push("black_color_is=#{rgb_color}")

speak("move the mouse to location on the screen that has a white icon")
my_x,my_y=get_mouse_loc(robot)
my_array.push("white_icon=[#{my_x},#{my_y}]")
rgb_color=get_color_of_pixel(robot,my_x,my_y)
print "white color of pixel is #{rgb_color}\n"
my_array.push("white_color_is=#{rgb_color}")

speak("Configure Yellow search area. move the mouse to the top left corner.")
my_x,my_y=get_mouse_loc(robot)
my_array.push("top_left_pixel=[#{my_x},#{my_y}]")

speak("Configure Yellow search area. move mouse to the Bottom Right corner")
my_x,my_y=get_mouse_loc(robot)
my_array.push("bottom_right_pixel=[#{my_x},#{my_y}]")

speak("define the buttons on the warp interface")
speak("move your mouse to the top corner of the left align to button")
my_x,my_y=get_mouse_loc(robot)
my_array.push("button1_top=[#{my_x},#{my_y}]")


speak("move your mouse to the botom right corner of the left align to button")
my_x,my_y=get_mouse_loc(robot)
my_array.push("button1_bottom=[#{my_x},#{my_y}]")

speak("move your mouse to the top left of the Warp 2 button")
my_x,my_y=get_mouse_loc(robot)
my_array.push("button2_top=[#{my_x},#{my_y}]")


speak("move your mouse to the bottom right of the Warp 2 button")
my_loc=get_mouse_loc(robot)
my_array.push("button2_bottom=[#{my_x},#{my_y}]")

speak("move your mouse to the top left of the Jump 2 button")
my_loc=get_mouse_loc(robot)
my_array.push("button3_top=[#{my_x},#{my_y}]")

speak("move your mouse to the bottom right of the Jump 2 button")
my_loc=get_mouse_loc(robot)
my_array.push("button3_bottom=[#{my_x},#{my_y}]")


speak("move your mouse to the top left of the show info button")
my_loc=get_mouse_loc(robot)
my_array.push("button4_top=[#{my_x},#{my_y}]")

speak("move your mouse to the bottom right of the show info button")
my_loc=get_mouse_loc(robot)
my_array.push("button4_bottom=[#{my_x},#{my_y}]")

#colors Blue
speak("move your mouse to the top right of the blue fast area")
my_loc=get_mouse_loc(robot)
my_array.push("blue_fast_top=[#{my_x},#{my_y}]")

speak("move your mouse to the bottom right of the blue fast area")
my_loc=get_mouse_loc(robot)
my_array.push("blue_fast_bottom=[#{my_x},#{my_y}]")

#colors Blue slow
speak("move your mouse to the top right of the blue slow area")
my_loc=get_mouse_loc(robot)
my_array.push("blue_slow_top=[#{my_x},#{my_y}]")

speak("move your mouse to the bottom right of the blue slow area")
my_loc=get_mouse_loc(robot)
my_array.push("blue_slow_bottom=[#{my_x},#{my_y}]")

write_file_for_configuration("locations.txt",my_array)
speak("finished thanks")