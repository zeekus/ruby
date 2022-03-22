
require 'java'
java_import 'javax.swing.JFrame'
java_import 'java.awt.Paint'


frame = javax.swing.JFrame.new
frame.title = "MouseTest"
frame.set_size(300, 200)
frame.add_window_listener do |evt|
  if evt.getID == java.awt.event.WindowEvent::WINDOW_CLOSING
    java.lang.System.exit(0)
  end
end

class MousePanel < Java::JavaxSwing::JPanel

   SQUARELENGTH = 10; MAXNSQUARES = 100;

  def initialize
    super
    @squares = []; @current = nil
    add_mouse_listener self
    add_mouse_motion_listener self
  end

  def add(x, y)
    if @squares.size < MAXNSQUARES
       @current = @squares.size
       @squares << Point.new(x, y)
       repaint
    end
  end

  def remove(n)
    return if (n < 0 || n >= @squares.size)
    @squares.pop
    @squares[n] = @squares[@squares.size];
    @current = nil if @current == n
    repaint
  end

  def paintComponent(graphics)
    super
    @squares.each { |square| do_draw(graphics, square) }
  end

  def do_draw(graphics, square)
    graphics.drawRect(
      square.x - SQUARELENGTH / 2,
      square.y - SQUARELENGTH / 2,
      SQUARELENGTH, SQUARELENGTH
    )
  end
  private :do_draw

  include java.awt.event.MouseListener

  [ 'mouseEntered', 'mouseExited', 'mouseReleased' ].each do |method|
    class_eval "def #{method}(evt); end"
  end

  def mousePressed(evt)
    puts "mousePressed #{evt}"
  end

  def mouseClicked(evt)
    puts "mouseClicked #{evt}"
  end

  include java.awt.event.MouseMotionListener

  def mouseMoved(evt)
    puts "mouseMoved #{evt}"
  end

  def mouseDragged(evt)
    puts "mouseDragged #{evt}"
  end

end

frame.content_pane.add MousePanel.new
frame.show