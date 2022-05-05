#filename: example_jruby_find_colors_at_mouse_coords.rb
#description: finds the colors of a pixel under the mouse.

require 'java'
java_import 'java.awt.Robot'
java_import 'java.awt.MouseInfo'
java_import 'java.awt.Color'

robot = Robot.new
puts "move your mouse to the location you want to check"
sleep 3
puts "getting mouse location"
coords= MouseInfo.getPointerInfo.getLocation()
puts "getting colors from #{coords.x},#{coords.y}"
color = robot.getPixelColor(coords.x,coords.y)

puts "RGB  : #{color.rGB}" 
puts "red  : #{color.red}"
puts "green: #{color.green}"
puts "blue : #{color.blue}"
puts "alpha: #{color.alpha}" # this appears invalid or always 255 in java.awt.Robot


