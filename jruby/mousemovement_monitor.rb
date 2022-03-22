

require 'java'

java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
java_import 'java.awt.event.KeyEvent'   #presing keys
java_import 'java.awt.Toolkit'          #gets screens size

def get_time_and_loc(robot)
   mytime=Time.now.getutc.to_i
   x=MouseInfo.getPointerInfo().getLocation().x
   y=MouseInfo.getPointerInfo().getLocation().y
   return "#{mytime}:#{x},#{y}" 
end


#10 seconds in the future
in_future=(Time.now.getutc.to_i)+10

robot=Robot.new
until in_future == Time.now.getutc.to_i
  loc1=get_time_and_loc(robot)
  #puts loc1
  loc2=get_time_and_loc(robot)
  #puts loc2
  first_loc=loc1.split(':')[1]
  sec_loc=loc2.split(':')[1]
  if first_loc == sec_loc 
    #not moving
  else
    puts "Pointer location is [#{first_loc}]"
  end
end
