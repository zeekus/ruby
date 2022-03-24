

class Invoice
  #class method
  def self.print_out
    puts "class method ex - Printed Invoice"
  end

  #Instance Method
  def convert_to_pdf
     puts "intance method - ex Converted to PDF"
  end

end

 Invoice.print_out # class method call

 #instance method
 i=Invoice.new
 i.convert_to_pdf
