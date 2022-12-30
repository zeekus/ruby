#!/usr/bin/jruby
#filename: example_open_cv.rb
require 'opencv-java'
#installation requirements for arch-linux
#pacman -S jruby; pacman -S opencv-java
image = Java::OrgOpencvCore::Mat.imread('image.png')
Java::OrgOpencvHighGui::HighGui.imshow('image', image)
Java::OrgOpencvHighGui::HighGui.waitKey(0)
