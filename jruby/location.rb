require 'java'

java_import 'java.awt.Robot'            #robot class
java_import 'java.awt.event.InputEvent' #moves mouse and typing
java_import 'java.awt.MouseInfo'        #get location of mouse
java_import 'java.awt.Color'            #get color of pixel at location on screen
java_import 'java.awt.event.KeyEvent'   #presing key

robot = Robot.new
$debug=0

def color_pixel_scan_in_range(robot,color,top_left_pixel,bottom_right_pixel) 
  count=0
  mycolors=[] #color
  mybreak =0
  found_icon_coord=[]
  found_icon_coord =[0,0] #array location
  pixel_match_count=0

  #scan on x axis main loop
  for x in top_left_pixel[0]..bottom_right_pixel[0]

    #scan on y axis inner loop
    for y in top_left_pixel[1]..bottom_right_pixel[1]

      count = count + 1
      tloc=[x,y] #tmp location
      mycolors=get_color_of_pixel(robot,tloc)
      print "debugb1: color is #{mycolors}\n" if $debug==1
      mycolor=mycolors.split(":")[0]
      print "debugb2: color is #{mycolor}\n" if $debug==1
      if color== mycolor
	       pixel_match_count = pixel_match_count + 1
         print "debugb3: match #{pixel_match_count} :  #{color} is #{mycolors}\n" if $debug==1
         if pixel_match_count>10
           return pixel_match_count
	         break
	       end
      end

  end #end inter while y
 end #end outer while x 
 return pixel_match_count
end

def round_by_ten(i)
  base10=i/10.0
  base10=base10.round()
  i=(base10*10)
  return i
end

def shade_math(bv,lv)
 result=bv-lv #big value - little value
 print  "bv-lv = #{result}\n" if $debug==1
 return result
end

def determine_color_shade(dh,d,r,g,b)
  #yellow = (red-12) = green
  #orange = 
  print "determine_color_shade dh #{dh} d #{d}\n" if $debug==1

  if dh == "red"
     rg=shade_math(r,g)
     rb=shade_math(r,b)
     if (rg<11 and rb>=110)
       dh = "yellow"
     elsif (rg<=70 and rb >=110)
       dh = "orange"
     end
  elsif dh == "blue"
     bg=shade_math(b,g)
     br=shade_math(b,r)
     dh="blue"
  elsif dh == "green"
     gr=shade_math(g,r)
     gb=shade_math(g,b)
     #if (rg<11 and rb>=110)
     dh="green"
  else
    dh = determine_shade_of_gray(dh,d,r,g,b)
  end

  print "determine_color_shade 2 dh #{dh} d #{d}\n" if $debug==1
  return dh
end

def determine_shade_of_gray(dh,d,r,g,b)
   print "determine shade of gray determine_color_shade dh #{dh} d #{d}\n" if $debug==1

   if (r > 240)
     acolor="white"
   elsif ( r >209) 
     acolor="gray209" #light gray
   elsif ( r >162) 
     acolor="gray162" 
   elsif ( r >87) 
     acolor="gray87"
   elsif ( r >50) 
     acolor="gray50" #dark gray
   else
     acolor="black"
   end

   return acolor
end

def math_dominate_color(r,g,b)
   #look for a rgb color
   colors=[r,g,b]
   red=r
   green=g
   blue=b
   colors=colors.sort()
   dominate=colors[2]

   if dominate>12
     df=12#difference
   elsif dominate>6
     df=6#difference
   else
     mycolor="black"
     dominate=0
     cd=2
     return "#{dominate}:#{cd}:#{mycolor}"
   end

   cd=0 #close to dominate
   mycolor=""

   if dominate==red
     mycolor="red"
     cd=cd+1 if green+df>=dominate
     cd=cd+1 if blue+df>=dominate
   elsif dominate==green
     mycolor="green"
     cd=cd+1 if red+df>=dominate
     cd=cd+1 if blue+df>=dominate
   else dominate==blue
     mycolor="blue"
     cd=cd+1 if red+df>=dominate
     cd=cd+1 if green+df>=dominate
   end

   return "#{dominate}:#{cd}:#{mycolor}"

end

def guess_color_using_math(r,g,b)

  acolor="" #color

  simple_color=math_dominate_color(r,g,b)
  mycolor=simple_color.split(/:/)[0] #dominate color number
  scount=simple_color.split(/:/)[1]  #similar count
  acolor=simple_color.split(/:/)[2]  #dominate color human readable

  mycolor=round_by_ten(mycolor.to_i) if mycolor.to_i > 0 
  r=round_by_ten(r.to_i) if r.to_i>0
  g=round_by_ten(g.to_i) if g.to_i>0
  b=round_by_ten(b.to_i) if b.to_i>0

  print "guess_color_using_math #{r},#{g},#{b}\n" if $debug==1

  #looking of shades of gray
  if ( ( r==g and g==b and b==r) or (scount==2) )
    print "debug1: math: A shade of gray: \'#{acolor}\'\n"
    acolor = determine_shade_of_gray(acolor,mycolor,r,g,b)
    print "debug2: math: A shade of gray: \'#{acolor}\'\n"
  else
   #look for a rgb color try and guess color
   if scount ==0
     print "debug: math: red,green,blue: \'#{acolor}\ '#{mycolor}'\n"
   else
     acolor=determine_color_shade(acolor,mycolor,r,g,b)
     print "debug: math: shade: \'#{acolor}\' \'#{mycolor}\ #{r},{#{g},#{b}'\n"
   end
	
  end
  return "#{acolor}:#{mycolor}"
end

def guess_color(r,g,b)
 acolor = "unknown"
 hue = color_intensity(r,g,b)
 percent=hue

 acolor ="red" if ( r > 200 and g < 50 and b <50 ) #red
 acolor ="yellow" if ( 
  ( r > 117 and  g > 117 and b < 50 ) and
   ( (r == g) or ( ( (g - 50) > b) and ( ( r - 50)  > b ) )) 
 ) #yellow 
 acolor ="blue" if ( r < 90 and g < 90 and b > 120)  #blue
 acolor ="green" if ( r<90 and g>120 and b <90) #green
 acolor ="white" if ( r>160 and g> 100 and b > 150 ) #white
 acolor ="black" if ( r <  40  and g < 40 and b < 40 ) #black
 acolor ="blue speed" if ( 
  ( r> 65 and r<145) and ( g > 124 and g < 155) and ( b > 155 and b < 200 )
 )  
 acolor ="grey speed or button" if ( 
  ( r> 65 and r<190) and ( g > 65 and g < 190) and ( b > 65 and b < 190 ) and 
  ( 
    ( hue > (r - 5)) and ( hue > (g - 5)) and (hue > (b - 5 )) 
  ) 
)
 acolor = "#{acolor}:#{hue}"
 return acolor
end

def get_color_of_pixel(robot,destination)
  x=destination[0]
  y=destination[1]
  mycolors=robot.getPixelColor(x,y)
  r = mycolors.red
  g = mycolors.green
  b = mycolors.blue
  print "debug: color is r=#{r},g=#{g},b=#{b}\n"
  mycolor = guess_color_using_math(r,g,b)
  return mycolor
end

def color_intensity (r,g,b)
 colori = ( r + g + b ) / 3.0
  return colori 
end

myms=1
print "delay #{myms} seconds...\n"
print "HUMAN  Move your mouse to the \'Target location\'\n"
dy=myms*1000
robot.delay(dy)
x1=MouseInfo.getPointerInfo().getLocation().x
y1=MouseInfo.getPointerInfo().getLocation().y

print "Current mouse location is #{x1},#{y1}\n"
location=[x1,y1]
my_c=get_color_of_pixel(robot,location)
print "color of pixel is #{my_c}\n"

color="a"
color=ARGV[0] 

if ( color == "blue" or "orange" )
 print "my input was \'#{color}\'"
 top_left_pixel=[443,339]
 bottom_right_pixel=[453,369]

 print "debug 1: scanning for \'#{color}\'\n"
 count_hits=color_pixel_scan_in_range(robot,color,top_left_pixel,bottom_right_pixel) 
 print "debug 2: we had \'#{count_hits}\' color matches\n"
end
