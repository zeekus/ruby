require 'java'
java_import java.awt.event.MouseListener
java_import java.Listener


nameEdit = MouseListener.new
listener = Proc.new do |k|
  puts '---------------------------'
  puts k.getKey().toString()
  puts '---------------------------'
end
#listener = listener.to_java
listener = listener.to_java Signal1::Listener.java_class.to_java
nameEdit.keyPressed.addListener(self, listener)
page_layout.addWidget(nameEdit)