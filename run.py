from camera import DSLR

exp = ['1','1/4','1/15','1/60']
aperture = '5.6'
ISO = '100'
cam = DSLR()
output_file = 'temp'

cam.capture_HDR_image(output_file, exp, aperture, ISO)
