
require 'date'


def host_entry (my_device,template,myalias)
  puts "define host {"
  puts "  host_name  #{myalias}"
  puts "  use        #{template}"
  puts "  alias      #{myalias}"
  puts "  address    #{my_device}"
  puts "  hostgroups ups"
  puts "}"
end

devices=["ups-rc.example.net", "pdu-c1.example.net", "pdu-c2.example.net"] #variables 
service_array=[]

#header
puts " # nagios ups object file"
puts " # created #{Date.today}, Theodore Knab, myexample company LLC"
puts " # formated by Ruby generate_ups.rb"

#create device list for nagios
for my_ups in devices do
   myalias=my_ups.gsub(/\..*/,"") #remove everything after the first dot
   host_entry(my_ups,"host-template",myalias)
   service_array.push(myalias)
end

hosts=service_array.join(",") #put all the hosts in a string

#create the service entry
puts "define service {"
puts "  service_description     ping-ups"
puts "  use                     service-template"
puts "  contact_groups          switchadmins"
puts "  host_name               #{hosts}"
puts "  check_command           check_ping!200.0,20%!600.0,60%"
puts "}"
