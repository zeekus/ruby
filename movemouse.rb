#!/usr/bin/jruby
#filename: mouse_move.rb
#
$debug=0 #global

require 'java'

java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
java_import 'java.awt.event.KeyEvent'   #presing keys

#use http://www.drpeterjones.com/colorcalc to verify colors
#blue range r(70-134),g(130-180),b(170-200)

class Findtarget


   def get_current_mouse_location(robot)
     curr=[]
     x1=MouseInfo.getPointerInfo().getLocation().x
     y1=MouseInfo.getPointerInfo().getLocation().y
     curr=[x1,y1]
     self.mydebugger("get_current_mouse_location", "under mouse location", curr) 
     return curr
   end

   #test function
   def generate_random_location 
     myloc=[]
     x = rand(1000) 
     y = rand(1000)
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
    
       if ( x > target_location[0] and y > target_location[1] )
	if ( x-10 > target_location[0] && y-10 > target_location[1]) 
          #-- #moving to up and left by 1
          x=x-10
          y=y-10
	else
          #-- #moving to up and left by 1
          x=x-1
          y=y-1
        end
       elsif ( x< target_location[0] and y < target_location[1] )
        if ( x+10 > target_location[0] && y+10> target_location[1]) 
          #++ #moving down and right x 10
          x=x+10
          y=y+10
	else
          #++ #moving down and right
          x=x+1
          y=y+1
        end
       elsif ( x> target_location[0] and y < target_location[1] )
        if ( x-10 > target_location[0] && y+10> target_location[1]) 
          #-+ #moving down and left by 10
          x=x-10
          y=y+10
        else
          #-+ #moving down and left
          x=x-1
          y=y+1
        end
       elsif ( x< target_location[0] and y > target_location[1] )
        if ( x+10 > target_location[0] && y-10> target_location[1]) 
          #+- #moving up and right by 10
          x=x+10
          y=y-10
	else
          #+- #moving up and right
          x=x+1
          y=y-1
	end
       elsif ( x< target_location[0])
        if ( x+10 > target_location[0] ) 
          #+ #moving right by 10
          x=x+10
        else
          #+ #moving right
          x=x+1
        end
       elsif ( x> target_location[0])
        if ( x-10 > target_location[0] ) 
          #- #moving left by 10
          x=x-10
        else
          #- #moving left 
          x=x-1
        end
       elsif ( y< target_location[1])
        if ( y+10 > target_location[1] ) 
          #- #moving up by 10
          y=y+10
        else
          #+ #moving up
          y=y+1
        end
       elsif ( y> target_location[1])
        if ( y-10 > target_location[1] ) 
          #- #moving down by 10
          y=y-10
	else
          #- #moving down
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
   end #end function
end #end class

#test area for above class
robot = Robot.new
mytarget=Findtarget.new

targetloc=[]
for x in 1..10
  location=mytarget.get_current_mouse_location(robot)
  print "===================== move #{x} ================================\n"
  print "Prior To move: my current mouse location is #{location}\n"
  targetloc=mytarget.generate_random_location()
  mytarget.move_to_target_pixel_like_human(robot,targetloc)
  location=mytarget.get_current_mouse_location(robot)
  print "After move: my current mouse location is #{location}\n"
end
