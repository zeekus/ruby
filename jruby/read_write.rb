
#Read lines from file text.txt
def read
  File.open('text.txt') do |f1|
  while line = f1.gets
    return line
  end
 end
end

#Write data to file text.txt
def write(data)
  File.open('text.txt') do |f2|
    f2.puts data
  end
end
