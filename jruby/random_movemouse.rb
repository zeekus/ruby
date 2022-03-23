#!/usr/bin/jruby
#filename: mouse_move.rb
#description: moves the mouse around on the screen like a human. Creates curved movements. 
$debug=0 #global

require 'java'

java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
java_import 'java.awt.event.KeyEvent'   #presing keys
java_import 'java.awt.Toolkit'          #gets screens size

#use http://www.drpeterjones.com/colorcalc to verify colors
#blue range r(70-134),g(130-180),b(170-200)

class Findtarget


  def speak(message)
    wait_delay=2 # 2 seconds 
    system("echo #{message} | espeak > /dev/null 2> /dev/null") #supress messages
    sleep wait_delay
  end


  def get_current_mouse_location(robot)
    return MouseInfo.getPointerInfo().getLocation().x,MouseInfo.getPointerInfo().getLocation().y
  end

  #test function
  def generate_random_location 
    screenSize = Toolkit.getDefaultToolkit().getScreenSize();
    width = screenSize.getWidth();
    height = screenSize.getHeight();
    x = rand(width) 
    y = rand(height)
    self.mydebugger("generate_random_location", "future location is", [x,y] ) 
    return x,y
  end# end generate_random_location

  def mydebugger(myfuncname,myfillerstring,mylocations,debug=1)
    if debug==1
      print "\nFuture:#{myfuncname} #{myfillerstring} #{mylocations}\n" 
    end
  end

  def animated_message(message,counter)
    if counter==1
      print "\n#{message}:"
    else
      print "."
    end
  end

  def move_to_target_pixel_like_human(robot,target_location,debug=1) 
    x,y=get_current_mouse_location(robot)
    mydebugger("move_to_target_pixel_like_human", "mouse location", [x,y] ) 

    counter=0
    until [x,y]==target_location do   
      if ( x > target_location[0] and y > target_location[1] ) #moving pointer up and left
        counter=counter+1
        animated_message("up and left",counter) if debug==1
        x=x-1
        y=y-1
      elsif ( x< target_location[0] and y < target_location[1] ) #moving pointer down and right
        counter=counter+1
        animated_message("down and right",counter) if debug==1
        x=x+1
        y=y+1
      elsif ( x> target_location[0] and y < target_location[1] ) #moving pointer down and left
        counter=counter+1
        animated_message("down and left",counter) if debug==1
        x=x-1
        y=y+1
      elsif ( x< target_location[0] and y > target_location[1] ) #moving pointer up and right
        counter=counter+1
        animated_message("up and right",counter) if debug==1
        x=x+1
        y=y-1
      elsif ( x< target_location[0]) #move right only
        counter=counter+1
        animated_message("only right",counter) if debug==1
        x=x+1
      elsif ( x> target_location[0]) #move left only
        counter=counter+1
        animated_message("only left",counter) if debug==1
        x=x-1
      elsif ( y< target_location[1]) #move up only 
        counter=counter+1
        animated_message("only up",counter) if debug==1
        y=y+1
      elsif ( y> target_location[1]) #move down only
        counter=counter+1
        animated_message("only down",counter) if debug==1
        y=y-1
      else
	     my_tmp_location=self.get_current_mouse_location(robot)
	     self.mydebugger("move_to_target_pixel_like_human", "target location", "#{target_location[0]},#{target_location[1]}" ) 
       robot.delay(1)
       return(1)
      end #end if
      robot.mouseMove(x,y)
      robot.delay(0.1) #mouse move is based on loop (0.1 for faster)
    end #end of until loop
  end #end function move_to_target_pixel_like_human
end #end class

#test area for above class
robot = Robot.new
mytarget=Findtarget.new

targetloc=[]
for x in 1..100
  #mytarget.speak("moving to location #{x}")
  location=mytarget.get_current_mouse_location(robot)
  print "===================== move #{x} ================================\n"
  print "Prior To move: my current mouse location is #{location}\n"
  targetloc=mytarget.generate_random_location()
  mytarget.move_to_target_pixel_like_human(robot,targetloc)
  location=mytarget.get_current_mouse_location(robot)
  print "\n" #extra return
  print "After move: my current mouse location is #{location}\n"
  robot.delay(5000)
end
