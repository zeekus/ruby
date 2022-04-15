#class inheritance example
#source: http://johnelder.org/code/ruby.php#class3
# Our Lion Class Inherits All the stuff from our Animal Class
class Animal
  attr_accessor :color, :name
  def initialize ( name, color )
    @name = name
    @color = color
  end
end
 
class Lion < Animal		# Inherit by using < Animal 
  def speak
    return "RAWR!"
  end

end

 
#  Instantiate our class
lion = Lion.new( "lion", "golden" )
 
# Inspect
puts lion.inspect
 
# Speak
puts lion.speak

# Color inherited from Animal class!
puts lion.color
