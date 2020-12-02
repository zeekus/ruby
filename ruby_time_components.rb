#!/usr/bin/ruby
#filename: ruby_time_components.rb
#decription: maps out time elements ruby can see by default
require 'time'

time=Time.now

# Components of a Time
puts "Current Time : #{time}"
puts "year       :#{time.year}"    # => Year of the date 
puts "month      :#{time.month}"   # => Month of the date (1 to 12)
puts "day        :#{time.day}"     # => Day of the date (1 to 31 )
puts "wday       :#{time.wday}"    # => 0: Day of week: 0 is Sunday
puts "yday       :#{time.yday}"    # => 365: Day of year
puts "hour       :#{time.hour}"    # => 23: 24-hour clock
puts "min        :#{time.min}"     # => 59
puts "sec        :#{time.sec}"     # => 59
puts "time usec  :#{time.usec}"    # => 999999: microseconds
puts "zone       :#{time.zone}"    # => "UTC": timezone name
