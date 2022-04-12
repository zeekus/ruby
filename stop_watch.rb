#filename: stopwatch.rb
start=Time.now.to_i #get time in secs
x=2 #seconds
puts "...starting timer at #{start} for #{x} secs"
seconds=0
counter=0

#credits: Rick Moore
#source https://dirklo.medium.com/formatting-number-strings-in-ruby-4da35d5282e3
def format_number(number)
    whole, decimal = number.to_s.split(".")
    num_groups = whole.chars.to_a.reverse.each_slice(3)
    whole_with_commas = num_groups.map(&:join).join(',').reverse
    [whole_with_commas, decimal].compact.join(".")
end


while true and seconds < x
    seconds=Time.now.to_i-start
    counter=counter+1
end
formatted_num=format_number(counter)

puts "we made #{formatted_num} loop iterations in #{x} seconds"
