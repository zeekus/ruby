#filename: mousemovement_monitor.rb
#description: monitors mouse movement. Upon movemement the new mouse location is displayed.

require 'java'
java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.MouseInfo'        #get location of mouse

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
end

#10 seconds in the future
in_future=(Time.now.getutc.to_i)+10

robot=Robot.new
until in_future == Time.now.getutc.to_i
  tlocation1=Utility.get_time_and_loc(robot) #time and location
  tlocation2=Utility.get_time_and_loc(robot) #time and location
  loc1=tlocation1.split(':')[1] #location 1
  loc2=tlocation2.split(':')[1] #location 2
  if loc1 != loc2 #display if movement
    x,y=loc1.split(',') 
    puts "x is #{x}"
    puts "y is #{y}"
    r,g,b=Utility.get_color_of_pixel(robot,x.to_i,y.to_i,debug=0) #RGB color
    puts "Pointer location is [#{loc1}] color is #{r},#{g},#{b}" 
  end
end