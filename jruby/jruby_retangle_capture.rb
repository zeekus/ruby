#source: Alvin Alexander. Last updated: June 4, 2016
require 'java'

#java_import 'java.awt.Dimension'
java_import 'java.awt.Rectangle'
java_import 'java.awt.Robot'
#java_import 'java.awt.event.InputEvent'
java_import 'java.awt.image.BufferedImage'
java_import 'javax.imageio.ImageIO'


x=75
y=52
robot = Robot.new
rectangle = Rectangle.new(x, y, x, y+5)
image = robot.createScreenCapture(rectangle)
f = java::io::File.new('test.png')
ImageIO::write(image, "png", f)