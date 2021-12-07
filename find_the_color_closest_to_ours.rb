#!/usr/bin/ruby
#filename: find_the_color_closest_to_ours.rb

def match_color(map_basic_colors,rgb_hex_query)
  puts "debug: rgb_hex_query is #{rgb_hex_query}"
  for k,v in map_basic_colors
    return "#{k}" if v == rgb_hex_query
  end
  return "no match found"
end

map_basic_colors={
    "black"  => "000000",
    "white"  => "FFFFFF",
    "red"    => "FF0000",
    "lime"   => "00FF00",
    "blue"   => "00FF00",
    "yellow" => "FFFF00",
    "cyan"   => "00FFFF",
    "mangeta"=> "FF00FF",
    "silver" => "C0C0C0",
    "gray"   => "808080",
    "maroon" => "800000",
    "olive"  => "808000",
    "green"  => "008000",
    "puple"  => "800080",
    "teal"   => "008080",
    "navy"   => "000080" }

#convert rgb numbers to HEX
rgb=[0,0,0]
puts "we received rgb color #{rgb}"
for color in rgb
   hex=color.to_s(16).upcase
   hex = "00" if hex == "0" #length should be 2 for Hex numbers but they don't always translate right
   rgb_hex="#{rgb_hex}#{hex}"
end

match_result=match_color(map_basic_colors,rgb_hex) #get the exact match
puts "match #{match_result}"


