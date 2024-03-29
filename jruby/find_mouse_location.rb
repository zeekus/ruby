#!/usr/bin/jruby
#filename: move_mouse.rb
#description: gets the current mouse location. This gets the X,Y from MouseInfo.getpointer
#summary gets one X,Y point

require 'java'

java_import 'java.awt.event.InputEvent'  #typing class and 
java_import 'java.awt.MouseInfo'         #gets mouse location class
java_import 'java.awt.Color'             #gets pixel color at mouse  location


def get_mouse_loc(robot)
    return MouseInfo.getPointerInfo().getLocation().x, MouseInfo.getPointerInfo().getLocation().y
end


puts "loading robot super class. and sleeping 5\n"
robot= java.awt.robot.new
sleep 5

x,y=get_mouse_loc(robot)
puts "returned value - current mouse location is [#{x},#{y}]"

