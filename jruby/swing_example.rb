require 'java'

java_import javax.swing.JFrame


class Example < JFrame
  
    def initialize
        super "Simple"
        
        self.initUI
    end
      
    def initUI
        
        self.setSize 300, 200
        self.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
        self.setLocationRelativeTo nil
        self.setVisible true
    end
end

SwingUtils = javax.swing.SwingUtilities

Example.new
event_thread = nil
SwingUtils.invokeAndWait { event_thread = java.lang.Thread.currentThread }
event_thread.join