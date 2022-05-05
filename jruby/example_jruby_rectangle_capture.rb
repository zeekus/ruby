#filename: example_ruby_rectangle_capture.rb
#description: get a location on the screen and store as an image.

require 'java'

java_import 'java.awt.Rectangle'
java_import 'java.awt.Robot'
java_import 'javax.imageio.ImageIO'
java_import 'java.awt.MouseInfo'

def wait_timer(delay)
    count=0
    while count<delay
      print "."
      sleep 1
      count=count+1
    end
end

robot = Robot.new
puts "move mouse to start of capture corner."
wait_timer(3)
coords1= MouseInfo.getPointerInfo.getLocation()
puts "coords are #{coords1.x},#{coords1.y}"

puts "move mouse to end location corner"
wait_timer(3)
coords2= MouseInfo.getPointerInfo.getLocation()

height=coords2.y-coords1.y
width= coords2.x-coords1.x
puts "width is #{width} height is #{height}"

#rectangle = Rectangle.new(coords1.x, coords1.y, 45, 75) # start x,y, followed by width height
rectangle = Rectangle.new(coords1.x, coords1.y, width, height) # start x,y, followed by width height
image = robot.createScreenCapture(rectangle)
f = java::io::File.new('test.png')
ImageIO::write(image, "png", f)