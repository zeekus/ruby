#description: get active screen size.
#filename: getscreen_size.rb

require 'java'
java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.Toolkit'

screenSize = Toolkit.getDefaultToolkit().getScreenSize();
width = screenSize.getWidth();
height = screenSize.getHeight();

print "screen size is #{width},#{height}\n"

cw = width.to_i/2
ch = height.to_i/2
print "center is #{cw},#{ch}\n"

robot = Robot.new
robot.mouseMove(cw,ch) #reset state of mouse



