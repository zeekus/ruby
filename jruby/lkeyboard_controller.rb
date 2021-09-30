#copied source https://gist.githubusercontent.com/efi/ecd4742de203a4c724be/raw/e6076f35283c2aa619991b6f6a7c88bf09e61cf5/keyboard_controller.rb

class KeyboardController
    def initialize
      @robot = java.awt.Robot.new
    end
    def type *args
      [args].flatten.map(&:to_s).map{|s|s.split(/\s+/)}.flatten.map(&:upcase).each do |n|
        press, name = (n[0]=="-") ? [false,n[1..-1]] : [true,n]
        press ? @robot.key_press(@code) : @robot.key_release(@code) if @code = java.awt.event.KeyEvent.const_get("VK_#{name}")
      end
      self
    end
  end
  
  kc = KeyboardController.new
  kc.type(%w[a b c d shift e f -shift g h]); kc.type("i","j"); kc.type(:k,"L M"); kc.type(:"N SHIFT O P -SHIFT Q r s")
  # types: => abcdEFghijklmnOPqrs