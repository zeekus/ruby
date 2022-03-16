#! /usr/bin/jruby

# Count the number of times the user clicks some buttons. 
require "java"
 
java_import "java.awt.GridLayout"
java_import "java.awt.event.ActionListener"
java_import "java.awt.event.WindowListener"
java_import "java.lang.System"
java_import "javax.swing.JButton"
java_import "javax.swing.JFrame"

class ClickButton < JButton
   include ActionListener

   def initialize(text)
     @count = 0
     @text = text
     super "#{@text} (0)"
     add_action_listener self
   end

   def actionPerformed(event)
     @count += 1
     self.text = "#{@text} (#{@count})"
   end
 end

 class MainWindow < JFrame
   include WindowListener
   include ActionListener

   def initialize
     super "Click Counter"
     set_layout GridLayout.new(5, 1)
     @total = 0

     1.upto 5 do |n|
       button = ClickButton.new "Button #{n}"
       button.add_action_listener self
       add button
     end

     add_window_listener self
     pack
   end

   def actionPerformed(event)
     @total += 1
   end

   # Bah, humbug!
   def windowActivated(event); end
   def windowClosed(event); end
   def windowDeactivated(event); end
   def windowDeiconified(event); end
   def windowIconified(event); end
   def windowOpened(event); end

   def windowClosing(event)
     puts "Total clicks: #{@total}"
     System::exit 0
   end
 end

MainWindow.new.set_visible(true)