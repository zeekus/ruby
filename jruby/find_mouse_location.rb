#!/usr/bin/jruby
#filename: move_mouse.rb

require 'java'
#system("export DISPLAY=localhost:0.0") #windows


#gets mouse location class


java_import 'java.awt.event.InputEvent' #moves mouse and typing class
java_import 'java.awt.MouseInfo'        #gets mouse location class
java_import 'java.awt.Color'            #gets pixel color at mouse  location
java_import 'java.awt.event.KeyEvent'    #keyboard input class

#ref http://drpeterjones.com/colorcalc/ for color codes

def get_current_mouse_location(robot)
    cur=[]
    #my_x=java.awt.MouseInfo.getPointerInfo().getLocation().x
    my_x=MouseInfo.getPointerInfo().getLocation().x
    #my_y=java.awt.MouseInfo.getPointerInfo().getLocation().y
    my_y=MouseInfo.getPointerInfo().getLocation().y

    #get current mouse
    puts my_x
    puts my_y
    cur=[my_x,my_y]
    return cur
end

puts "loading robot super class"
robot= java.awt.robot.new

puts "getting loc"
location=get_current_mouse_location(robot)
puts location.to_s
