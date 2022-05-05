#description: find number of screens on the machine in use.
#filename: find_number_of_screens.rb

require 'java'
java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.Toolkit'
java_import 'java.awt.Dimension'
java_import 'java.awt.GraphicsEnvironment'
java_import 'java.awt.GraphicsDevice'



#find number of screens
env = GraphicsEnvironment.getLocalGraphicsEnvironment()
devices = env.getScreenDevices()
puts ("We have #{devices.length} screens.")
for dev in devices
    puts (dev)
end

puts ("\ntotal size of screen real estate")
tk= Toolkit.getDefaultToolkit()
d = tk.getScreenSize()
puts ("Screen width  = " + (d.width).to_s)
puts ("Screen height = " + (d.height).to_s)