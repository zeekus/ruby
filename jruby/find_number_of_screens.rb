

require 'java'
java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.Toolkit'
java_import 'java.awt.Dimension'
java_import 'java.awt.GraphicsEnvironment'
java_import 'java.awt.GraphicsDevice'

tk= Toolkit.getDefaultToolkit()
d = tk.getScreenSize()
puts ("Screen width = " + d.width.to_s)
puts ("Screen height = " + d.height.to_s)


#find number of screens
env = GraphicsEnvironment.getLocalGraphicsEnvironment()
devices = env.getScreenDevices()
puts "graphic devices are #{devices}"

numberOfScreens = devices.length
puts "we have #{numberOfScreens} screens"
