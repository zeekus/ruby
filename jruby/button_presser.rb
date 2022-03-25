#!/usr/bin/jruby
#filename: button_presser.rb
#description: sometimes you need a robot to press buttons for you. 

require 'java'

java_import 'java.awt.Robot'            #robot class


def press_enter(robot,name)
    @code = java.awt.event.KeyEvent.const_get("VK_#{name}") #translates button to machine reference
    robot.key_press(@code)
    robot.key_release(@code)
end

robot = Robot.new
counter=0
BUTTON="ENTER" #button to press

while true
  puts "pressing #{BUTTON} #{counter}"
  press_enter(robot,BUTTON)
  sleep 5
  counter +=1
end