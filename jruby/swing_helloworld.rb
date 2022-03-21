java_import javax.swing.JFrame
java_import javax.swing.JButton

f = JFrame.new("Swing Demo")
f.set_size 300,300
f.layout = java.awt.FlowLayout.new
button = JButton.new("Hello World")
f.add(button)
f.show
