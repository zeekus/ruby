#
# devdaily.com
#source: Alvin Alexander. Last updated: June 4, 2016
# ruby/jruby code to create an image/screenshot of your desktop
#
#filename: example_takescreenshot.rb
#description: takes a screens shot of screen 0 [ the first screen ]
require 'java'

java_import 'java.awt.Rectangle'
java_import 'java.awt.Robot'
java_import 'java.awt.Toolkit'
java_import 'javax.imageio.ImageIO'

toolkit = Toolkit::getDefaultToolkit()
screen_size = toolkit.getScreenSize() #get screen size
puts "screen_size is #{screen_size}"
rect = Rectangle.new(screen_size) 
robot = Robot.new
image = robot.createScreenCapture(rect) #take screenshot 
f = java::io::File.new('test.png')
ImageIO::write(image, "png", f)