#filename: nagios_server_fact.rb
#Description: This Puppet code creates a new custom fact called "nagios_server_fact" using the Facter.add method. The fact is defined using a block of code that sets the fact's value using the setcode method.
#The setcode block runs a shell command using the Facter::Core::Execution.exec method. 
#The command being run is hostname and Facter.value('os.family')
#
#
#NOTE this needs to be in a lib\facter directory for puppet to pick it up.
require 'socket'
require 'facter'

source="custom-fact origin - nagios-cims : nagios_server_fact.rb"
hostname=Socket.gethostname.chomp
puts "debug 1 #{hostname}"
Facter.add('nagios_custom') do
   setcode do
     if hostname.include? "nag"
        puts "debug 2 #{hostname}"
        puts "got nag"
        family= Facter.value('os.family')
        myvalue="#{hostname}:#{family}"
        puts "debug 3: #{myvalue}"
        myvalue
     end
   end
end
