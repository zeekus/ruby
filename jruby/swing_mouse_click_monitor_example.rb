# -*- encoding: utf-8 -*-
include Java

java_import java.awt.event.MouseListener
java_import java.awt.Dimension
java_import javax.swing.JPanel
java_import javax.swing.JButton
java_import javax.swing.JTextField

class MainPanel < JPanel
                include MouseListener
  def initialize
    super
    field = JTextField.new 32
    button = JButton.new "add a"
    button.add_action_listener {
      field.text = field.text + "a"
    }

#     # https://blogs.oracle.com/nishigaya/entry/tips_for_accessing_java_objects2
#     button.add_mouse_listener do |ev|
#       p ev
#     end

#     #:1 warning: singleton on non-persistent Java type #<Class:0x103bdaa8>
#     #            (http://wiki.jruby.org/Persistence)
#     class << listener = java.awt.event.MouseListener.new
#       def mouseEntered(e)
#         puts "mouseEntered"
#       end
#       def mouseExited(e)
#         puts "mouseExited"
#       end
#       def mousePressed(e)
#         puts "mousePressed"
#       end
#       def mouseClicked(e)
#         puts "mouseClicked"
#       end
#       def mouseReleased(e)
#         puts "mouseReleased"
#       end
#     end
#     button.add_mouse_listener listener

    # puts self.java_kind_of?(MouseListener)
    button.add_mouse_listener self

    self.add field
    self.add button
    self.preferred_size = Dimension.new(320, 240)
  end

  # MouseListener
  def mouseEntered(e)
    puts "mouseEntered"
  end
  def mouseExited(e)
    puts "mouseExited"
  end
  def mousePressed(e)
    puts "mousePressed"
  end
  def mouseClicked(e)
    puts "mouseClicked"
  end
  def mouseReleased(e)
    puts "mouseReleased"
  end
end

java_import javax.swing.UIManager
java_import javax.swing.WindowConstants
def create_and_show_GUI
  begin
    UIManager.look_and_feel = UIManager.system_look_and_feel_class_name
  rescue Exception => e
    proxied_e = JavaUtilities.wrap e.cause
    proxied_e.print_stack_trace
  end
  frame = javax.swing.JFrame.new "JRuby Swing JButton ActionListener"
  frame.default_close_operation = WindowConstants::EXIT_ON_CLOSE
  frame.content_pane.add MainPanel.new
  frame.pack
  frame.location_relative_to = nil
  frame.visible = true
end
def run
  create_and_show_GUI
end
java.awt.EventQueue.invokeLater self