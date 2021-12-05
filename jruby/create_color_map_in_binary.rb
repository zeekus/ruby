 #!/usr/bin/jruby
#filename: create_color_map.rb
#description: takes in input and generates a color map
require 'java'

java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
java_import 'java.awt.event.KeyEvent'   #presing keys

def speak(message)
  wait_delay=2 # 2 seconds 
  system("echo #{message} | espeak > /dev/null 2> /dev/null") #supress messages
  sleep wait_delay
end

def countdown()
    speak("1")
    speak("hold")
end

def get_color_of_pixel(robot,x,y)
  mycolors=robot.getPixelColor(x,y)
  r = mycolors.red
  g = mycolors.green
  b = mycolors.blue
  print "get_color_of_pixel: at [#{x},#{y}] color is r=#{r},g=#{g},b=#{b}\n"
  return r,b,g
end

def get_mouse_loc(robot)
    my_x=MouseInfo.getPointerInfo().getLocation().x
    my_y=MouseInfo.getPointerInfo().getLocation().y
    puts "[#{my_x},#{my_y}]"
    return my_x,my_y
end


robot=Robot.new

counter = 1
stop_number = 10
array_of_colors=[]
#loop to get the color of 10 different points on the screen

puts "use: type a color identifier [label] - i.e. 'blue_fast'"

for string in ARGV
  puts "You typed `#{string}` as your argument(s)."
end

if ARGV.length == 0 
    puts "error: no data received. We expected a string."
    exit
elsif ARGV.length > 1
    puts "warning: too much data receieved. We expected 1 string."
else 
    puts "running.."
    speak("mapping #{string}")
    countdown
    label=string
end

while counter <= stop_number  do
 x,y=get_mouse_loc(robot)
 r,b,g=get_color_of_pixel(robot,x,y) #RGB color 
 #hex_string=(r.to_s(16) + g.to_s(16) + b.to_s(16)).upcase #RGB color to HEX format
 #binary string conversion helper
 #9.to_s(2) #=> "1001"
 #"1001".to_i(2) #=> 9
 binary_color_string=r.to_s(2)+g.to_s(2)+b.to_s(2)
 color_map_steing="\"#{binary_color_string} => #{label}\""
 array_of_colors.push(color_map_string)
 print "while loop: location [#{x},#{y}] has the color r=#{r},g=#{g},b=#{b}\n"
 speak("move to a different pixel")
 countdown
 counter +=1
end


#sample of colors sorted
for line in array_of_colors.uniq
   puts line
end

