#filename: stopwatch.rb
start=Time.now.to_i #get time in secs
seconds=0
counter=0

while true and seconds < 10
    seconds=Time.now.to_i-start
    #puts "count #{counter}"
    counter=counter+1
end

puts "we made #{counter} iterations waiting for 10 seconds"
