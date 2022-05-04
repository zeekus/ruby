
require 'java' 
java_import 'java.awt.Robot'
java_import 'java.awt.Dimension'
java_import 'java.awt.Rectangle'
java_import 'java.awt.image.BufferedImage'
java_import 'javax.imageio.ImageIO'

robot = Robot.new
width=100
height=100
rectangle = Rectangle.new(100, 100, width, height)
image = robot.createScreenCapture(rectangle)
f = java::io::File.new('test.png')
ImageIO::write(image, "png", f)