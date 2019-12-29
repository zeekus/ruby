#!/usr/bin/env ruby
$version="0.1"
#filename: ticket_helper2.rb
#description: takes arguments and generates recurring text that is used on a help-desk job.

class Recurring_text_generation

  def main_class(menu_item,sr,c_email,t_title,task_id,th_email,sys,c_tel,desc)
  #main class takes all the variables even if nil
    if $debug==1
      puts "debug is on we made it to main_class"
      puts "menu_item is #{menu_item}"
      puts "sr is #{sr}"
      puts "customer email is #{c_email}"
      puts "t_title is #{t_title}"
      puts "task_id #{task_id}"
      puts "task holder is #{th_email}"
      puts "systems are #{sys}"
      puts "telephone number is #{c_tel}"
      puts "description: is #{desc}"
    end
    if c_email != nil
      court_unit=get_court_unit_from_email(c_email)
      puts "court unit is #{court_unit}" if $debug==1
      c_name=get_name_from_email(c_email)
      puts "Customer name is #{c_name}" if $debug==1
    end
    if th_email != nil
      th_name=get_name_from_email(th_email)
      puts "Task Holder name #{th_name}" if $debug==1
    end

    case menu_item.to_i #use integers

    when 1 #service ticket picked up
       puts "service Ticket picked up" if $debug==1
       if ( sr != nil and t_title != nil)
         self.generic_opening_response(sr,t_title)
       else
         puts "error nil value for sr:#{sr} or t_title:#{t_title}"
         exit 1
       end
    when 2 # Access to servers requested
      puts "Request access to server" if $debug==1
      if ( sr != nil and sys != nil)
        self.generic_request_access_to_server(sr,sys)
      else
        puts "error nil value for sr:#{sr} or sys:#{sys}"
        exit 1
      end
    when 3 #cyberark message
       puts "cyberark request"
       self.cyberark_message(c_name, sr, t_title)
    when 4 #check status on task ( nag task holder)
       puts  "nag task holder"
       nag_task_holder(th_email,th_name,task_id,c_name,court_unit,sr,t_title)
    when 5 #check status with customer
       puts "check status with customer"
       if ( sr != nil and t_title != nil and c_email != nil and court_unit != nil )
         self.generic_status_check_with_customer(c_name,sr,c_email,t_title,court_unit)
       else
         puts "error nil values for sr,c_email,t_title,court_unit"
       end
    when 6 #request task closure
       puts "request task closure"
       self.close_completed_task(th_email,th_name,task_id,c_name,court_unit,sr,t_title)
    when 7 # task Escalation   ce sr ti tel --desc
       puts "task Escalation"

       self.task_escalation(c_email,c_name,court_unit,sr,t_title,c_tel,desc)
    end
  end

  def task_escalation(c_email,c_name,c_unit,sr,t_title,c_tel,desc)
    tel=c_tel.to_s.unpack('A3A3A4').join('-') #phone conversion
    puts "#{c_unit} is requesting assistance with #{t_title}"
    puts "-------------------------------------------------"
    printf "Customer      %-1s\n", c_name
    printf "Court Unit     %-1s\n", c_unit
    printf "Customer email %-1s\n", c_email
    printf "Customer tel   %-1s\n", tel
    printf "Parent ID      %-1s\n", sr
    printf "Ticket Title   %-1s\n", t_title
    #printf "%-14s %-35sn","Dotted Decimal","#{ips}"
    printf "Summary        %-1s is requesting assistance with %s\n", c_unit, t_title
    printf "Description    %-1s\n", desc
  end

  def generic_status_check_with_customer(c_name,sr,email,title,unit)
  #description email customer generic status check

    puts "\nI am writing to check the status on Ticket #{sr}."
    puts "In the ticket, you reported '#{title}'."
    puts "How would you like to proceed with this ticket ? "
    puts "Do you need further assistance ? \n"

    puts "==============================="
    puts "request updated for #{c_name} #{unit}"
    puts "==============================="
    puts "emailed #{unit} customer at #{email}."
    puts "requested status update."

  end

  def generic_opening_response(sr,title)
   #description: general notification upon ticket ownership
   puts "The CM/ECF National Support Desk Team has received your Heat Ticket and begun investigating."
   puts "If you discover any additional information that will help with our troubleshooting efforts, please add this info to the ticket."
   puts "Information can be added to the \'notes\' section of the Heat ticket. "
   puts "Additionally, to record your notes, you can simply respond to this email with a 'respond to all' "
   puts "The status of ticket #{sr} with the title of #{title} is 'active'."
   puts "==============================="
   puts "ticket action"
   puts "==============================="
   puts "notified customer of ticket activation"
  end


  def close_completed_task(th_email,th_name,task_id,c_name,court_unit,sr,t_title)
   #description Close task request. email sent to task holder asking them to close/complete a task
   puts "Dear #{th_name}"
   puts "Thank you for your assistance with task #{task_id}. "
   puts "Your assistance with #{court_unit} was greatly appreciated."
   puts "Have you found any additional information regarding this problem ? "
   puts "If not, can you close task #{task_id} in ticket #{sr} with the title '#{t_title}'."
   puts "==============================="
   puts "task holder thanked"
   puts "==============================="
   puts "thanked task holder #{th_name} at #{th_email}"
   puts "requested task closure."
  end

  def nag_task_holder(th_email,th_name,task_id,c_name,court_unit,sr,t_title)
    #description Close task request. email sent to task holder asking them to close/complete a task
    puts "Dear #{th_name}"
    puts "Thank you for your assisting with task #{task_id}. "
    puts "Our mutual customer #{c_name} from #{court_unit} is requesting an update."
    puts "Have you found any new information regarding this problem ? "
    puts "If so, can you please update your task #{task_id} in ticket #{sr} with the title '#{t_title}'."
    puts "==============================="
    puts "task holder update request"
    puts "==============================="
    puts "requested task holder #{th_name} to update task #{task_id}"
    puts "emailed: #{th_email}"
  end

  def cyberark_message(c_name, sr, title)
    #Description cyberark message
    puts "\nInvestigating #{title} in regards to #{sr}. Working with #{c_name}.\n"
  end

  def generic_request_access_to_server(ticket_num,servers)
    #description Request access to server
    puts "In order to process your request, in Ticket  #{ticket_num}, the National Support desk"
    puts "will need explicit written permission to access your server(s)."
    puts "Can we get permission to log into server(s) : #{servers} ? "
    puts "Your prompt reply granting access permission would be greatly appreciated."
  end

  def sig_field()
    #signature field
    puts "*>*>*>*>*>*>"
    puts "Teddy Knab"
    puts "Enterprise Support Desk (NSD)"
    puts "Office: 210-536-5000 Option 5, Option 2"
    puts "For more information on our Phone Queue and other changes, check us out on JNET:"
    puts "http://jnet.ao.dcn/information-technology/support"
    puts "\r\n"
  end

  ###############################
  #future functions
  ###############################
  #def transforming_service_request_to_incident()
  #description: convert service ticket to incident information

  # def transforming_incident_to_service_request()
  #Description: convert incident to service request information

  #json logging for recording data and quicker retrieval
end #end class

def get_court_unit_from_email(email)
  #Description get court unit form email
  if ( email =~ /_/ and email =~ /@/ )
    puts "...attempting to format #{email} in to a readable name" if $debug==1
    second_part_of_email=email.split('@')[1] #first part
    puts "second_part_of_email #{second_part_of_email}" if $debug==1
    court_unit=second_part_of_email.split(".")[0]# split by dot
    puts "court_unit is #{court_unit}" if $debug==1
    if  court_unit.length > 1  # two or more names found
      puts "returning value #{court_unit.upcase}" if $debug==1
      return court_unit.upcase
    else
      puts "...court unit string is too short."
      exit
    end
  end
end

def get_name_from_email(email)
  #description format name from email
  if ( email =~ /_/ and email =~ /@/ )
    puts "...attempting to format email in to a readable name" if $debug==1
    first_part_of_email=email.split('@')[0] #first part
    name_parts=first_part_of_email.split('_')# split by underscore
    if  name_parts.length > 1  # two or more names found
      for name in name_parts
        name=name.gsub(/\s+/,'')#remove spaces in name string
        name=name.capitalize
        if name_parts[0] == name
          new_name="#{name}" #first part
        else
          new_name="#{new_name} #{name}" #append name
        end
      end
      return new_name
    else
      puts "...name_parts array is too short."
      exit
    end

  else
    puts "no underscore found in email. We can't parse this '#{email}'"
    exit 1
  end
end




def help()
  #description help functions
  puts "--------------------------------------------"
  puts "valid arguments for '" + $0 + "'"
  puts "--------------------------------------------"
  puts "-mi  MENUITEM_NUMBER"
  puts "-ce  c_email"
  puts "-sr  SERVICE_REQUEST or INCIDENT"
  puts "-ti  TITLEOFREQUEST"
  puts "-ta  TASKID"
  puts "-te  TASKHOLDER_EMAIL"
  puts "-sys SERVERNAMES"
  puts "-help  Detailed help"
  puts "--------------------------------------------"
end

def menu_list()
  #description extended help
  puts "Extended help with examples"
  puts "----------------------------------"
  puts "-mi NUMBER(1-7)"
  puts "----------------------------------"
  puts "1) Service Ticket Picked up:"
  puts "...use example: " + $0 + " -mi 1 -sr 32316 -ti 'locked out of servers'"
  puts "----------------------------------"
  puts "2) Access to server:"
  puts "...use example:"  + $0 + " -mi 2 -ce ted_knab@mdb.uscourts.gov -sr 32316 -ti 'locked out of servers' -sys 'mdbdb,mdbweb'"
  puts "----------------------------------"
  puts "3) Cyberark message:" #3 cyberark message         -ce -sr -ti -sys)
  puts "...use example: " + $0 + " -mi 3 -ce ted_knab@mdb.uscourts.gov -sr 32316 -ti 'locked out of servers'"
  puts "----------------------------------"
  puts "4) Check status on task - nag taskholder. *** generic status check ***"
  puts "...use example: " + $0 + " -mi 4 -ce ted_knab@mdb.uscourts.gov -sr 32316 -ti 'firewall issue' -ta 82488 -te steve_barks@aotx.uscourts.gov"
  puts "----------------------------------"
  puts "5) Check status with customer:  *** generic status check ***"
  puts "...use example: " + $0 + " -mi 5 -ce ted_knab@mdb.uscourts.gov -sr 32316 -ti 'firewall issue'"
  puts "----------------------------------"
  puts "6) Request Task closure: Problem resolved, but task open."
  puts "...use example: " + $0 + " -mi 6 -ce ted_knab@mdb.uscourts.gov -sr 32316 -ti 'firewall issue' -ta 82488 -te steve_barks@aotx.uscourts.gov"
  puts "----------------------------------"
  puts "7) Task Escalation:"
  puts "...use example: " + $0 + " -mi 7 -ce ted_knab@mdb.uscourts.gov -sr 32316 -ti 'firewall issue' -tel 4109627807 --desc 'customer is getting timed out on server'"
end

#1 service ticket picked up -sr -ti
#2 access to servers        -ce -sr -ti -sys
#3 cyberark message         -ce -sr -ti -sys
#4 check status on task ( nag task holder) -ce -sr -ti -te -ta
#5 check status with customer              -ce -sr -ti
#6 request task closure                    -ce -sr -ti -te -ta
#7 task Escalation   ce sr ti tel --desc


def parsing_args(args_w_strings)
  #description parsing_args subset of main
  for line in args_w_strings
    if line =~ /-help /
      help()
      menu_list()
      exit 0
    end
    if line =~ /-ce/
       c_email=line.split(/-ce /)[1]
    elsif line =~ /-sr/
       sr=line.split(/-sr /)[1]
    elsif line =~ /-ti/
       title=line.split(/-ti /)[1]
    elsif line =~ /-ta/
       task=line.split(/-ta /)[1]
    elsif line =~ /-te/
       t_email=line.split(/-te /)[1]
    elsif line =~ /-mi/
       menu_item=line.split(/-mi /)[1]
    elsif line =~ /-sys/
      sys=line.split(/-sys /)[1]
    elsif line =~ /-ph/
      ctel=line.split(/-ph /)[1]
    elsif line =~ /-desc /
      desc=line.split(/-desc /)[1]
    end
  end

  if $debug ==1
    puts "menu item:        #{menu_item}"
    puts "Ticket:  	        #{sr}"
    puts "Title:            #{title}"
    puts "Customer email:   #{c_email}"
    puts "Task:             #{task}"
    puts "Task holder email #{t_email}"
    puts "systems:          #{sys}"
    puts "telephone         #{ctel}"
    puts "description       #{desc}"
  end
  ticket_helper=Recurring_text_generation.new
  ticket_helper.main_class(menu_item,sr,c_email,title,task,t_email,sys,ctel,desc)
  puts "debug: #{line}" if $debug==1
end #end parsing


#################################
#parse arguments from command line or error
#################################
#MAIN FUNCTION
$debug=0 #debug switch 1=on
#################################
args_w_strings=[]
for i in 0 ... ARGV.length
  if ARGV[i] =~ /-/ and ARGV[i] !~ /-help/ #look for flags ignore help
    puts "DEBUG1: '#{ARGV[1]}'" if $debug==1
    arg_no_white_space=ARGV[i].chomp
    puts "DEBUG1B:'#{arg_no_white_space}'" if $debug==1
  elsif ARGV[i] !~ /-help/ #ignore help
    puts "DEBUG2: '#{ARGV[1]}'" if $debug==1
    args_w_strings.push("#{arg_no_white_space} #{ARGV[i]}")
    puts "DEBUG2B: '#{arg_no_white_space} #{ARGV[i]}'" if $debug==1
  else #must want help
    help() #help called
    menu_list()
    exit
  end
end

if args_w_strings.length < 1
  puts "We did not get enough arguments..."
  help
else
  parsing_args(args_w_strings)
end
