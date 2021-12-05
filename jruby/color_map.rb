#!/bin/jruby
#rgb_color_map.rb
#description: this attempts to map the screen colors in a map file then converts the rgb stuff into the color

require 'java'

java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
java_import 'java.awt.event.KeyEvent'   #presing keys



rgb_color_map={ "r=0,g=0,b=0"       => "black",
                "r=80,g=143,b=195"  => "fast_blue",
                "r=80,g=143,b=197"  => "fast_blue",
                "r=81,g=142,b=195"  => "fast_blue",
                "r=81,g=144,b=197"  => "fast_blue",
                "r=82,g=142,b=194"  => "fast_blue",
                "r=82,g=143,b=196"  => "fast_blue",
                "r=83,g=143,b=193"  => "fast_blue",
                "r=83,g=144,b=195"  => "fast_blue",
                "r=84,g=142,b=194"  => "fast_blue",
                "r=88,g=85,b=16"    => "yellow_icon",
                "r=85,g=82,b=14"    => "yellow_icon",
                "r=87,g=84,b=15"    => "yellow_icon",
                "r=91,g=69,b=6"     => "undock_gold",
                "r=92,g=70,b=7"     => "undock_gold",
                "r=93,g=70,b=7"     => "undock_gold",
                "r=149,g=150,b=149" => "slow_gray",
                "r=150,g=150,b=149" => "slow_gray",
                "r=147,g=147,b=147" => "slow_gray",
                "r=152,g=152,b=151" => "slow_gray",
                "r=154,g=154,b=153" => "slow_gray",
                "r=136,g=133,b=11"  => "yellow_icon",
                "r=150,g=148,b=11"  => "yellow_icon",
                "r=150,g=148,b=12"  => "yellow_icon",
                "r=150,g=148,b=13"  => "yellow_icon",
                "r=168,g=166,b=10"  => "yellow_icon",
                "r=169,g=167,b=10"  => "yellow_icon",
                "r=255,g=255,b=255" => "white_button"
}

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
    rgb_string="r=#{r},g=#{g},b=#{b}"
    print "get_color_of_pixel: at [#{x},#{y}] color is #{rgb_string} \n"
    hex_string=("#" + r.to_s(16) + g.to_s(16) + b.to_s(16)).upcase #upper case HEX
    puts hex_string
    return r,b,g,rgb_string
end
  
def get_mouse_loc(robot)
    my_x=MouseInfo.getPointerInfo().getLocation().x
    my_y=MouseInfo.getPointerInfo().getLocation().y
    puts "[#{my_x},#{my_y}]"
    return my_x,my_y
end

robot=Robot.new
x,y=get_mouse_loc(robot)
r,b,g,rgb_string=get_color_of_pixel(robot,x,y)
if rgb_color_map[rgb_string] != nil 
   puts "The pixel could be part of the " + rgb_color_map[rgb_string]
else
  #nulls will break things
  puts "The pixel is not mapped"
end

