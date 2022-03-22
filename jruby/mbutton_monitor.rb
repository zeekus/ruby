

require 'java'

java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
java_import 'java.awt.event.KeyEvent'   #presing keys
java_import 'java.awt.Toolkit'          #gets screens size
java_import 'java.awt.event.MouseEvent'

def get_clickcount(robot)
   mytime=Time.now.getutc.to_i
  #  mouseEvent.getButton().equals(MouseButton.PRIMARY
   clickcount=java.awt.event.mouseEvent.getClickCount()
   return "#{mytime}:#{clickcount}" 
end

#10 seconds in the future
in_future=(Time.now.getutc.to_i)+10

robot=Robot.new
until in_future == Time.now.getutc.to_i
  count1=get_clickcount(robot)
  #puts loc1
  count2=get_clickcount(robot)
  #puts loc2
  first_count=count1.split(':')[1]
  second_count=count2.split(':')[1]
  if first_count == second_count 
    #not moving
    puts java.awt.event.mouseEvent.getClickCount()
  else
    puts "Pointer location is [#{first_count}]"
  end
end
