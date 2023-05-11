#file: ec2_az_fact.rb
#description: This Puppet code creates a new custom fact called "ec2_placement_availability_zone" using the Facter.add method. The fact is defined using a block of code that sets the fact's value using the setcode method.
#The setcode block runs a shell command using the backtick syntax and the %x{} construct. The command being run is "curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone", which retrieves the availability zone of the EC2 instance.
#The chomp method is then called on the output of the command to remove any trailing newline characters.
#When Puppet runs on an EC2 instance, it will retrieve the availability zone of the instance and set the value of the "ec2_placement_availability_zone" fact accordingly.
source="custom-fact origin - ec2_awstools: ec2_za_fact.rb"
Facter.add("ec2_placement_availability_zone") do
        setcode do
                az = Facter::Core::Execution.exec('/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/')
                if az.include? "404 - Not Found"
                  'None - Error - ec2_availability zone is undefined'
                else
                   az.chomp
                end
                puts "#{source}  ec2_placement_availablity_zone is '#{az}'"
                az
                #%x{curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone}.chomp
        end
end

