#filename: class_example_with_attr_accessor.rb
#source http://johnelder.org/code/ruby.php#class3
# Delete the Getter and Setter from above, replace it with attr_accessor
# Note: Doesn't write your initialize method instance variables!
class Product
  attr_accessor :description
 
 
  # Always Initialize It First
  def initialize( description, price)
    @id = rand(100...999)
    @description = description
    @price = price
  end
 
  
  def to_s
    # return by rewriting to_s :-p and add tabs with \t
    return "#{@id}\t#{@description}\t#{@price}"
  end
end
 
# Set it up... Instantiate our class
book = Product.new( "Ruby On Rails For Web Development", 26.95 )
book2 = Product.new( "Intro To Ruby", 25.95 )
 
# Call the thing!
puts book
puts book2
 
# Call The Description Getter
puts book.description
# Call the Setter, set a different Description
puts book.description= "I Like Cheese!"
					
