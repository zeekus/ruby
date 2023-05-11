#ec2_instanceID_fact.rb
#file: ec2_instance_fact.rb
#description: gets the current instance we are on. Requires to be on AWS EC2. 
source="custom-fact origin - ec2_awstools: ec2_instanceid_fact.rb"


Facter.add("ec2_instance_id") do 
  setcode do
    instance = Facter::Core::Execution.exec('/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id/')
    if instance.include? "404 - Not Found"
      'None'
    else
      instance.chomp
    end
    source="custom-fact origin - ec2_awstools: ec2_instanceid_fact.rb"
    puts "#{source} generated instance-id: '#{instance}'"
    instance
  end
end
