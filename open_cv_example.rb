#!/usb/bin/ruby
#filename: open_cv_example.rb
#description: find a pointer on a screen wth open ai.
#requirements: pointer.png image gem install opencv

#capture the screen 
capture = CvCapture.open
frame = capture.query

#identify the target image
pointer = CvMat.load('pointer.png')

#find the location of the pointer on the screen
result = cvMatchTemplate(frame, pointer, :CV_TM_CCOEFF_NORMED)
min_val, max_val, min_loc, max_loc = result.minMaxLoc
