#!/usr/bin/ruby
#filename: argv.rb
#descripiton: parsing data from argv with ruby 

debug=1

def help()
    puts "help was called"
end

puts "length of ARGV array is: " + ARGV.length.to_s  if debug==1

for i in 0 ... ARGV.length
  puts "MAIN DEBUG#{i}: '#{ARGV[i].chomp}'" if debug==1
  if ARGV[i] =~ /-/ and ARGV[i] !~ /-help/ #alternate run 'help' is found
    puts "DEBUG#{i}: flag detected '#{ARGV[i].chomp}'" if debug==1
    i2=i+1
    puts "DEBUG#{i}: associated with'#{ARGV[i2].chomp}'" if debug==1
  elsif ARGV[i].chomp =~ /-help/ or ARGV[i] =~ /\s+/ #need help
    puts "DEBUG3: 'help command received'" if debug==1
    help()
  else
    puts "need some error checking here. last line ?  #{ARGV[i].chomp}'" if debug==1
  end
 end

for string in ARGV
   puts string
end

