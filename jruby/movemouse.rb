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
    my_xy=[]
    x1=MouseInfo.getPointerInfo().getLocation().x
    y1=MouseInfo.getPointerInfo().getLocation().y
    my_xy=[x1,y1]
    self.mydebugger("get_current_mouse_location", "under mouse location", my_xy) 
    return my_xy
  end

  #test function
  def generate_random_location 
    myloc=[]
    #screenSize = Toolkit.getDefaultToolkit().getScreenSize();
    screenSize = Toolkit.getDefaultToolkit().getScreenSize();
    width = screenSize.getWidth();
    height = screenSize.getHeight();
    # screenSize = Toolkit.getDefaultToolkit().getScreenResolution();
    # width = screenSize.getWidth();
    # height = screenSize.getHeight();
    x = rand(width) 
    y = rand(height)
    myloc=[x,y]
    self.mydebugger("generate_random_location", "future location is", myloc ) 
    return myloc
  end# end generate_random_location

  def mydebugger(myfuncname,myfillerstring,mylocations)
    if $debug==1
      puts "DEBUG 1:#{myfuncname} #{myfillerstring} #{mylocations}" 
    end
  end

  def move_to_target_pixel_like_human(robot,target_location)
    myloc=[] 
    myloc=get_current_mouse_location(robot)
    mydebugger("move_to_target_pixel_like_human", "mouse location", myloc ) 

    x=myloc[0]
    y=myloc[1]

    until myloc==target_location do
    
      #moving pointer up and left
      if ( x > target_location[0] and y > target_location[1] )
	        if ( x-10 > target_location[0] && y-10 > target_location[1]) 
            #fast moving to up and left by 10 
            x=x-10
            y=y-10
	        else
            #slow moving to up and left by 1
            x=x-1
            y=y-1
          end
      #moving pointer down and right 
      elsif ( x< target_location[0] and y < target_location[1] )
          if ( x+10 > target_location[0] && y+10> target_location[1]) 
            #fast moving down and right x 10
            x=x+10
            y=y+10
	        else
            #slow moving down and right
            x=x+1
            y=y+1
          end
      #moving pointer down and left 
      elsif ( x> target_location[0] and y < target_location[1] )
        if ( x-10 > target_location[0] && y+10> target_location[1]) 
          #fast moving down and left by 10
          x=x-10
          y=y+10
        else
          #slow moving down and left
          x=x-1
          y=y+1
        end
      #moving pointer up and right
      elsif ( x< target_location[0] and y > target_location[1] )
        if ( x+10 > target_location[0] && y-10> target_location[1]) 
          #fast moving up and right by 10
          x=x+10
          y=y-10
	      else
          #slow moving up and right by 1
          x=x+1
          y=y-1
	      end
      #move right only 
      elsif ( x< target_location[0])
        if ( x+10 > target_location[0] ) 
          #+ #moving right by 10
          x=x+10
        else
          #+ #moving right
          x=x+1
        end
      #move left only 
      elsif ( x> target_location[0])
        if ( x-10 > target_location[0] ) 
          #fast moving left by 10
          x=x-10
        else
          #slow moving left 
          x=x-1
        end
      #move up only 
      elsif ( y< target_location[1])
        if ( y+10 > target_location[1] ) 
          #- #moving up by 10
          y=y+10
        else
          #+ #moving up
          y=y+1
        end
      #move down only 
      elsif ( y> target_location[1])
        if ( y-10 > target_location[1] ) 
          #fast moving down by 10
          y=y-10
	      else
          #slow moving down
          y=y-1
        end
      else
	     my_tmp_location=self.get_current_mouse_location(robot)
	     self.mydebugger("move_to_target_pixel_like_human", "target location", "#{target_location[0]},#{target_location[1]}" ) 
       robot.delay(10)
       return(1)
      end #end if
      robot.mouseMove(x,y)
      robot.delay(1)
    end #end of until loop
  end #end function move_to_target_pixel_like_human
end #end class

#test area for above class
robot = Robot.new
mytarget=Findtarget.new

targetloc=[]
for x in 1..10000
  #mytarget.speak("moving to location #{x}")
  location=mytarget.get_current_mouse_location(robot)
  print "===================== move #{x} ================================\n"
  print "Prior To move: my current mouse location is #{location}\n"
  targetloc=mytarget.generate_random_location()
  mytarget.move_to_target_pixel_like_human(robot,targetloc)
  location=mytarget.get_current_mouse_location(robot)
  print "After move: my current mouse location is #{location}\n"
end
