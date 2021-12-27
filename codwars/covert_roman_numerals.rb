#filename: convert_roman_numerals.rb
#description convert roman numerals to decimal and from decimal to roman numerals.

#work in progress.
#source: https://www.tutorialspoint.com/roman-to-integer-in-python


class number_converters(object):

def roman_to_decimal(self, s)
    """
    :type s: str
    :rtype: int
    """
    roman={ 'I':1, 'II':2, 'III':3 , 'IV':4 'V':5, 
            'VI':6, 'VII':7, 'VIII':8, 'IX':9, 'X':10, 
            'XL':40, 'L':50, 'XC':90, 'C':100, 'CD':400,
            'D':500, 'M':1000 }

    i=0
    num=0
    #while i < 
end

def convert_decimal_to_portable_format()
    thousands=0
    hundreds=0
    tens=0
    ones=0

    puts "original: #{number}"
    number=number.to_i

    if number >= 1000
        thousands,remaining = number.divmod(1000)
        puts "1000: #{thousands}"
    end

    if  number >=100
       hundreds,remaining =  (number-(1000 * thousands )).divmod(100)
       puts "100: #{hundreds}"
    end

    if number >= 10
        tens,remaining =  (number-(1000 * thousands)-(100 * hundreds)).divmod(10)
        puts "10: #{tens}"
    end

    if number  >=1
        ones,remaining =  (number-(1000 * thousands[0])-(100 * hundreds) - (10 * tens)).divmod(1)
        puts "1: #{ones}"
    end

    return thousands,hundreds,tens,ones
end

 
decimal_to_roman=roman_to_decimal.invert 


puts "roman_to_decimal:  #{roman_to_decimal}"
puts "roman_to_decimal keys  #{roman_to_decimal.keys}"
puts "roman_to_decimal values  #{roman_to_decimal.values}"

puts "decimal_to_roman:  #{decimal_to_roman}"
puts "decimal_to_roman keys  #{decimal_to_roman.keys}"
puts "decimal_to_roman values  #{roman_to_decimal.values}"

puts "value of i from roman_to_decimal: #{roman_to_decimal[:i]}"
puts "check to see if value of i exists: #{roman_to_decimal.value?(:i)}" #false
puts "check to see if value of i exists: #{decimal_to_roman.value?(:i)}" #true
puts "value of 1: from decimal_to_roman: #{roman_to_decimal.key("1")}"


mydecimals=["1000","1001","13","10232"]

for num in mydecimals 
    result= converter_logic(num)
    puts "#{num}: #{result}"
    puts "thousands: "
end


#for key,value in roman_to_decimal
   #puts key,value
#end
