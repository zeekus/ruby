#filename: json_file_creater.rb
#description: create a simple json file

require 'json'

#read json file in

my_json_file=("/var/tmp/my_first_json_file.json")
if File.exist?(my_json_file)
  puts "file exits. opening file..."
  file = File.read(my_json_file)
  data_hash = JSON.parse(file)
  for key,value in data_hash
     puts "#{key}:#{value}"
  end

  #data_hash = JSON.load(file) #raw data
else
  puts "json file is missing at #{my_json_file}. We are creating one."
  tmp_Hash={
        "location1" => "[125,577]",
        "location2" => "[0,0]" }
  File.open(my_json_file,'w') do |f| 
    f.write(tmp_Hash.to_json)
  end
end



