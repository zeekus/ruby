require 'java'
java_import 'java.awt.Robot'  #robot class
list_of_methods=Robot.instance_methods('false')


for methods in list_of_methods
     print p methods
end