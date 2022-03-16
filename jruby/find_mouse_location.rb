#!/usr/bin/jruby
#filename: move_mouse.rb
#description: gets the current mouse location

require 'java'

java_import 'java.awt.event.InputEvent'  #typing class and 
java_import 'java.awt.MouseInfo'         #gets mouse location class
java_import 'java.awt.Color'             #gets pixel color at mouse  location


def get_mouse_loc(robot)
    my_x=MouseInfo.getPointerInfo().getLocation().x
    my_y=MouseInfo.getPointerInfo().getLocation().y
    puts "function - get_mouse_location [#{my_x},#{my_y}]"
    return my_x,my_y
end

def get_clicks(robot)
    count = MouseInfo.getClickCount()
    puts "mouse click was #{count}"
end

puts "loading robot super class"
robot= java.awt.robot.new

x,y=get_mouse_loc(robot)
puts "returned value - current mouse location is [#{x},#{y}]"
