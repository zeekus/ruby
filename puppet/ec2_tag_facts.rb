
#filename: ec2_tag_facts.rb
#description: gets a bunch of facts
#This Puppet code retrieves the tags associated with an EC2 instance and sets them as facts in Puppet. 
#The code starts by requiring the "net/http" and "uri" libraries, and sets the source variable to "ec2_tag_facts.rb". 

#Then, the code attempts to retrieve the instance ID from the EC2 metadata endpoint using a HTTP GET request. 
#The instance ID is stored in the instance_id variable.

# If there was an exception raised during the retrieval of the instance ID, the code does nothing.
# If the instance_id is not a string, the code also does nothing. 
# Otherwise, it parses the JSON data stored in the jsonString variable using the JSON.parse method, 
# and checks if the resulting hash is a Hash object. If it is, the code checks if the hash has a "Tags" key. 

# If it does, the code iterates over each child in the "Tags" array, converts the fact name to lowercase using the downcase! method,
# and sets the value of the fact to the child's "Value" property using the setcode method. 
# If the hash does not have a "Tags" key, the code does nothing.


#source="ec2_tag_facts.rb"
source="custom-fact origin - ec2_awstools: ec2_tags_facts.rb"
require 'json'
require 'facter'

DEFAULT_REGION = "us-east-1".freeze

# Retrieves the instance ID from the EC2 metadata endpoint.
# def get_instance_id
#require "uri"
#require "net/http"
#   uri = URI.parse("http://169.254.169.254")
#   http = Net::HTTP.new(uri.host, uri.port)
#   http.open_timeout = 10
#   http.read_timeout = 10
#   request = Net::HTTP::Get.new("/latest/meta-data/instance-id")
#   response = http.request(request)
#   response.body
# rescue Net::OpenTimeout, Net::ReadTimeout
#   nil
# end

# Retrieves the AWS EC2 instance tags as a hash.
def get_instance_tags(instance_id, region)
  jsonString = `aws ec2 describe-tags --filters "Name=resource-id,Values=#{instance_id}" --region #{region}`
  JSON.parse(jsonString)["Tags"]
rescue JSON::ParserError
  nil
end

# Sets the EC2 tags as Facter facts.
def set_ec2_tags(tags)
  tags.each do |tag|
    fact_name = "ec2_tag_#{tag['Key'].downcase.gsub(/\s+/, '_')}"
    Facter.add(fact_name) { setcode { tag['Value'] } }
    puts "... debug: fact key: '#{fact_name}' fact value: '#{tag['Value']}'"
  end
end

# Get the availability zone and region.
az = Facter.value('ec2_placement_availability_zone')
region = if az.nil? || az.empty? 
  DEFAULT_REGION
else
  az.gsub(/[a-z]$/, "") #remove extra charcters on avail zone
end

puts "Fact query - #{source} ec2_placement_availability_zone: '#{az}'"

# Retrieve the instance ID and tags.
instance_id=Facter.value('ec2_instance_id')
puts "Fact query - #{source} ec2_instance_id: '#{instance_id}'"

if instance_id
  #puts "Instance ID: #{instance_id}"
  tags = get_instance_tags(instance_id, region)
  if tags
    #puts "#{source} Instance tags: #{tags}"
    set_ec2_tags(tags)
  else
    puts "No tags found for instance #{instance_id} in region #{region}."
  end
else
  puts "Unable to retrieve instance ID from metadata endpoint."
end
