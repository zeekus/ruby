#!/usr/bin/ruby
#language: Ruby
#filename: argv.rb
#descripiton: parsing data from argv with ruby 

debug=0


def help(command=$0)
    puts "help was called"
    puts "#{command} use: -c for cloaking"
end

puts "length of the 'ARGV' array is: " + ARGV.length.to_s  if debug==1

for i in 0 ... ARGV.length
  puts "MAIN DEBUG#{i}: '#{ARGV[i].chomp}'" if debug==1
  if ARGV[i] =~ /-/ and ARGV[i] !~ /-help/ #alternate run 'help' is found
    puts "DEBUG#{i}: flag detected '#{ARGV[i].chomp}'" if debug==1
    arg_count=i+1
    puts "DEBUG#{i}: associated with'#{ARGV[arg_count].chomp}'" if debug==1
  elsif ARGV[i].chomp =~ /-help/ or ARGV[i] =~ /\s+/ #need help
    puts "DEBUG3: 'help command received'" if debug==1
    help(command)
  else
    puts ""
  end
 end

for string in ARGV
   puts "You typed `#{string}` as your argument(s)."
end

