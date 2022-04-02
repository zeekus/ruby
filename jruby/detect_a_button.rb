#filename: detect_a_button.rb
#description: detects buttons on a screen. 
#  Most buttons are dynamic and change color when a mouse is moved  


require 'java'
java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
# java_import 'java.awt.Color'            #get color of pixel at location on screen
# java_import 'java.awt.event.KeyEvent'   #presing keys
# java_import 'java.awt.Toolkit'          #gets screens size

class Utility 
    def self.get_time_and_loc(robot)
      mytime=Time.now.getutc.to_i
      x=MouseInfo.getPointerInfo().getLocation().x
      y=MouseInfo.getPointerInfo().getLocation().y
      #check_mouse_button(robot)
      return "#{mytime}:#{x},#{y}" 
    end
  
    def self.get_color_of_pixel(robot,x,y,debug)
      mycolors=robot.getPixelColor(x,y)
      r = mycolors.red
      g = mycolors.green
      b = mycolors.blue
      print "get_color_of_pixel: at [#{x},#{y}] color is r=#{r},g=#{g},b=#{b}\n" if debug==1
      return r,g,b
    end

    def self.get_current_mouse_location(robot)
        return MouseInfo.getPointerInfo().getLocation().x,MouseInfo.getPointerInfo().getLocation().y
    end

    def self.button_check(robot,x,y)
        robot.mouseMove(x,y) #button location
        r,g,b=get_color_of_pixel(robot,x,y,debug=1) #with mouse on location
        puts r,g,b
        rgb_total=r+g+b

        robot.mouseMove(x,y-15) #move mouse off button in upward direction
        r1,g1,b1=get_color_of_pixel(robot,x,y,debug=1) #with mouse off location
        puts r1,g1,b1
        rgb1_total = r1+g1+b1

        if rgb1_total >  rgb_total
            return "yes"
        else
            return "no"
        end
    end
  end
  


robot = Robot.new
puts "move mouse to the button"
sleep 5
x,y=Utility.get_current_mouse_location(robot)
are_we_a_button=Utility.button_check(robot,x,y)
if are_we_a_button=="yes"
    puts "we found a clickable button"
end


