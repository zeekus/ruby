# This program calculates monthly expenses

require 'csv'

# Create a file to store the expenses
expenses_file = File.open('expenses.csv', 'w')

# Create a hash to store the expenses
expenses = {}

# Get the user's input
puts 'Enter the expense name:'
expense_name = gets.chomp

puts 'Enter the expense amount:'
expense_amount = gets.chomp.to_f

# Add the expense to the hash
expenses[expense_name] = expense_amount

# Write the expenses to the file
CSV.open(expenses_file, 'w') do |csv|
  expenses.each do |expense_name, expense_amount|
    csv << [expense_name, expense_amount]
  end
end

# Close the file
expenses_file.close

# Create a menu to let the user edit, delete, add, or list the expenses
loop do
  puts 'Select an option:'
  puts '1. Edit an expense'
  puts '2. Delete an expense'
  puts '3. Add an expense'
  puts '4. List expenses'
  puts '5. Quit'

  option = gets.chomp

  case option
  when '1'
    # Edit an expense
    puts 'Enter the expense name to edit:'
    expense_name = gets.chomp

    if expenses.key?(expense_name)
      puts 'Enter the new expense amount:'
      new_expense_amount = gets.chomp.to_f

      expenses[expense_name] = new_expense_amount

      puts 'Expense updated successfully!'
    else
      puts 'Expense not found!'
    end
  when '2'
    # Delete an expense
    puts 'Enter the expense name to delete:'
    expense_name = gets.chomp

    if expenses.key?(expense_name)
      expenses.delete(expense_name)

      puts 'Expense deleted successfully!'
    else
      puts 'Expense not found!'
    end
  when '3'
    # Add an expense
    puts 'Enter the expense name:'
    expense_name = gets.chomp

    puts 'Enter the expense amount:'
    expense_amount = gets.chomp.to_f

    expenses[expense_name] = expense_amount

    puts 'Expense added successfully!'
  when '4'
    # List expenses
    puts 'Expenses:'
    expenses.each do |expense_name, expense_amount|
      puts "#{expense_name}: #{expense_amount}"
    end
  when '5'
    # Quit
    break
  else
    puts 'Invalid option!'
  end
end
