#source: Alvin Alexander. Last updated: June 4, 2016
require 'java'

java_import 'java.awt.Dimension'
java_import 'java.awt.Rectangle'
java_import 'java.awt.Robot'
java_import 'java.awt.Toolkit'
java_import 'java.awt.event.InputEvent'
java_import 'java.awt.image.BufferedImage'
java_import 'javax.imageio.ImageIO'

toolkit = Toolkit::getDefaultToolkit()
screen_size = toolkit.getScreenSize()
puts "screen_size is #{screen_size}"
rect = Rectangle.new(screen_size)
robot = Robot.new
image = robot.createScreenCapture(rect)
f = java::io::File.new('test.png')
ImageIO::write(image, "png", f)