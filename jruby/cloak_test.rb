#!/usr/bin/jruby
#filename: json_setup_screen_points.rb
#description: gets screen points and puts them in json file for later. The values and keys are used in auto_jump_loop.rb
require 'java'


java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
java_import 'java.awt.event.KeyEvent'   #presing keys





def press1(robot)
    #cloak module
    #my_action=Action.new
    #my_action.speak("cloaking")
    robot.keyPress(KeyEvent::VK_1)
    robot.delay(50)
    robot.keyRelease(KeyEvent::VK_1)
 end

 #test area for above class
robot = Robot.new
press1(robot)