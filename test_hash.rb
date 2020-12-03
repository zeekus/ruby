require 'time'
holidays= Hash.new( "holidays" )
holidays= {"12-31-2020" => "New Years", "01-14-2021" => "MLK"}
holidays.store("12-25-2020",  "Christmas")

holidays.each { |elem| 
   puts "#{elem[0]}, #{elem[1]}"
}


holidays=holidays.sort


holidays.each { |elem| 
   puts "#{elem[0]}, #{elem[1]}"
}
