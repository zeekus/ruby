#filename: delta_time.rb
require 'time'
t1=Time.now
sleep 1
t2=Time.now
puts "Delta Time: #{(t2 - t1)}"

