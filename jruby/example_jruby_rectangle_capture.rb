#filename: ruby_rectangle_capture.rb
#description: get a location on the screen and store as an image.

#source: Alvin Alexander. Last updated: June 4, 2016
require 'java'

java_import 'java.awt.Rectangle'
java_import 'java.awt.Robot'
java_import 'javax.imageio.ImageIO'


x=1687
y=68
robot = Robot.new
rectangle = Rectangle.new(x, y, 45, 75) # start x,y, followed by width height
image = robot.createScreenCapture(rectangle)
f = java::io::File.new('test.png')
ImageIO::write(image, "png", f)