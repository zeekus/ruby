#filename: detect_a_button.rb
#description: detects buttons on a screen. 
#  Most buttons are dynamic and change color when a mouse is moved  
#  This works on most standard buttons. Howerver, games use a transparency layer. 
#  It appears java.awt.Robot can not see the transparent layers as of 5/22. 


require 'java'
java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse

class Utility 
    def self.get_time_and_loc(robot)
      mytime=Time.now.getutc.to_i
      robot.delay(0.1)
      x,y=get_current_mouse_location(robot)  
      return "#{mytime}:#{x},#{y}" 
    end
  
    def self.get_color_of_pixel(robot,x,y,debug)
      mycolors=robot.getPixelColor(x,y)
      r = mycolors.red
      g = mycolors.green
      b = mycolors.blue
      a=  mycolors.alpha
      print "get_color_of_pixel: at [#{x},#{y}] color is r=#{r},g=#{g},b=#{b},a=#{a}\n" if debug==1
      return r,g,b,a
    end

    def self.get_current_mouse_location(robot)
      x=MouseInfo.getPointerInfo().getLocation().x
      y=MouseInfo.getPointerInfo().getLocation().y
      #puts "mouse location is #{x},#{y}"
      return x,y
    end

    def self.color_intensity (r,g,b)
      colori = ( r + g + b ) / 3.0
      return colori 
    end

  def self.button_check(robot,x,y)
    
    
    #start location
    r,g,b,a=get_color_of_pixel(robot,x,y,debug=1) #with mouse on location
    hue1=color_intensity(r,g,b)
    puts "hue with mouse on is #{hue1}"
    
    #move mouse up
    y1=y
    until (y1==y-50) #50 pixel offset should work
      robot.mouseMove(x,y1) #move mouse off button in upward direction
      robot.delay(0.1)
      get_current_mouse_location(robot)
      y1=y1-1
    end

    #revist start location
    r1,g1,b1,a1=get_color_of_pixel(robot,x,y,debug=1) #with mouse off location
    hue2=color_intensity(r1,g1,b1)
    puts "hue with mouse off is #{hue2}"

    
    
    if (hue1 >  hue2 )
        mydiff= hue1 - hue2
        puts "hue difference is #{mydiff}"
        puts "button is darker with mouse moved off"
        return "yes"
    elsif ( hue2 > hue1)
        mydiff= hue2 - hue1
        puts "hue difference is #{mydiff}"
        puts "button is lighter with mouse moved off"
        return "yes" 
    else
        puts "hue is the same. not a clickable"
        return "no"
    end
  end
end #class Utility



robot = Robot.new
puts "move mouse to the button"
sleep 5
x,y=Utility.get_current_mouse_location(robot)
are_we_a_button=Utility.button_check(robot,x,y)
if are_we_a_button=="yes"
    puts "we found a clickable button"
end



