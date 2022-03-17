#
# devdaily.com
# ruby/jruby code to create an image/screenshot of your desktop
#
require 'java'

include_class 'java.awt.Dimension'
include_class 'java.awt.Rectangle'
include_class 'java.awt.Robot'
include_class 'java.awt.Toolkit'
include_class 'java.awt.event.InputEvent'
include_class 'java.awt.image.BufferedImage'
include_class 'javax.imageio.ImageIO'

toolkit = Toolkit::getDefaultToolkit()
screen_size = toolkit.getScreenSize() #get screen size
rect = Rectangle.new(screen_size) 
robot = Robot.new
image = robot.createScreenCapture(rect) #take screenshot 
f = java::io::File.new('test.png')
ImageIO::write(image, "png", f)