#filename: ec2_iam_fact.rb
#Description: This Puppet code creates a new custom fact called "ec2_iam_role" using the Facter.add method. The fact is defined using a block of code that sets the fact's value using the setcode method.
#The setcode block runs a shell command using the Facter::Core::Execution.exec method. The command being run is '/usr/bin/curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/', which retrieves the name of the IAM role associated with the EC2 instance.
#
#The code then checks if the output of the command includes the string "404 - Not Found". If it does, it sets the value of the "ec2_iam_role" fact to the string 'None'. Otherwise, it removes any trailing newline characters from the output using the chomp method and sets the value of the "ec2_iam_role" fact to the role name.
#When Puppet runs on an EC2 instance, it will retrieve the name of the IAM role associated with the instance and set the value of the "ec2_iam_role" fact accordingly. If there is no IAM role associated with the instance, the fact will be set to 'None'.
source="custom-fact origin - ec2_awstools: ec2_iam_fact.rb"

Facter.add("ec2_iam_role") do
  setcode do
    role = Facter::Core::Execution.exec('/usr/bin/curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/')
    if role.include? "404 - Not Found"
      'None'
    else
      role.chomp
    end
    source="custom-fact origin - ec2_awstools: ec2_iam_fact.rb"
    puts "#{source} generated custom fact ec2_iam_fact role is '#{role}'"
    role
  end
end

