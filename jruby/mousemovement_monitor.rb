

require 'java'

java_import 'java.awt.Robot'            #robot class
#java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
#java_import 'java.awt.Color'            #get color of pixel at location on screen
#java_import 'java.awt.event.KeyEvent'   #presing keys
#java_import 'java.awt.Toolkit'          #gets screens size
#java_import 'java.awt.event.MouseEvent' 

def get_time_and_loc(robot)
   mytime=Time.now.getutc.to_i
   x=MouseInfo.getPointerInfo().getLocation().x
   y=MouseInfo.getPointerInfo().getLocation().y
   #check_mouse_button(robot)
   return "#{mytime}:#{x},#{y}" 
end

#10 seconds in the future
in_future=(Time.now.getutc.to_i)+10

robot=Robot.new
until in_future == Time.now.getutc.to_i
  tlocation1=get_time_and_loc(robot) #time and location
  tlocation2=get_time_and_loc(robot) #time and location
  loc1=tlocation1.split(':')[1] #location 1
  loc2=tlocation2.split(':')[1] #location 2
  if loc1 != loc2 #display if movement 
    puts "Pointer location is [#{loc1}]" 
  end
end
