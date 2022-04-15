# open a file (in current directory)
# display each line
my_file = File.open("./lines.txt")
myarray=[] #array of lines
 
# loop through the file = while not at end of file
while ! my_file.eof?
	myline = my_file.gets.chomp #get each line
    myarray.push(myline) #push value into array
	# display each line from the file
	puts myline
end
 
# close the file
my_file.close


puts "..everything in myarray"
puts myarray
