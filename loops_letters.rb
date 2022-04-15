#one liners
puts "one line"
('a'..'z').each{ |letter| puts letter }

puts "print doesn't add eol characters like puts"
('a'..'z').each{ |letter| print letter }

#cleaner code
#('a'..'z').each{ |letter| 
#   puts letter 
#}

letters=[] #array

#for loop
puts "\nfor loop example:"
for i in 'a'..'z'
  puts i
  letters << i
end

count=0
while count != (letters.length)
  puts letters[count]
  count=count+1
end 
