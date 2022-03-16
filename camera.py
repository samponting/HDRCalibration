import cv2, rawpy, numpy as np
import logging

import subprocess, os, logging
from time import sleep
from fractions import Fraction

logger = logging.getLogger(__name__)


class DSLR(object):
	def __init__(self):
		out = subprocess.check_output(['gphoto2', '--auto-detect'])
		logger.info(f'gphoto2 init returned:\n{out.decode()}')

	def set_shutter_speed(self, shutter_speed):
		if not hasattr(self, 'shutter_speed') or shutter_speed != self.shutter_speed:
			gp_command = f'gphoto2 --set-config /main/capturesettings/shutterspeed={str(shutter_speed)}'
			self.shutter_speed = shutter_speed

			logger.info(f'gphoto2 command: {gp_command}')
			subprocess.call([gp_command], shell=True)


	def capture_image(self, filename, shutter_speed='1', aperture='5.6', iso='100'):
		raw_file = filename + '.arw'
		logger.info(f'Setting the following: exp:{shutter_speed}, iso:{iso}, aperture:{aperture}')
		gp_command = 'gphoto2'

		# Update camera parameters only as needed
		if not hasattr(self, 'shutter_speed' ) or shutter_speed != self.shutter_speed:
			gp_command += f' --set-config /main/capturesettings/shutterspeed={str(shutter_speed)}'
			self.shutter_speed = shutter_speed

		if not hasattr(self, 'iso' ) or iso != self.iso:
			gp_command += f' --set-config /main/imgsettings/iso={str(iso)}'
			self.iso = iso

		if not hasattr(self, 'aperture' ) or aperture != self.aperture:
			gp_command += f' --set-config /main/capturesettings/f-number={str(aperture)}'
			self.aperture = aperture

		gp_command += ' --capture-image-and-download --force-overwrite'

		logger.info(f'gphoto2 command: {gp_command}')
		subprocess.call([gp_command], shell=True)

		#subprocess.call([f'gphoto2 --set-config /main/capturesettings/shutterspeed={str(shutter_speed)}'], shell=True)
		#subprocess.call([f'gphoto2 --set-config /main/imgsettings/iso={str(iso)}'], shell=True)
		#subprocess.call([f'gphoto2 --set-config /main/capturesettings/f-number={str(aperture)}'], shell=True)
		#subprocess.call(['gphoto2 --capture-image-and-download --force-overwrite'], shell=True)
		logger.info(f'Captured image: {raw_file}')
		subprocess.call(['mv', 'capt0000.arw', raw_file])

	def capture_HDR_image(self, filename, exposures,  aperture='5.6', iso='100'):
		for i, e in enumerate(exposures):
			self.capture_image(filename + '_' + str(i), shutter_speed=e, aperture=aperture, iso=iso)


# We don't need IDS camera currently
use_ids = False

if use_ids:
	from pyueye import ueye

	class IDSUeyeCamera(object):

		def __init__(self, camera_matrix=None, dist_coeff=None, shape=None):
			self.hCam = ueye.HIDS(0)
			self.sInfo = ueye.SENSORINFO()
			self.pcImageMemory = ueye.c_mem_p()
			self.memID = ueye.int()
			self.bitsPerPixel = 12
			self.colorMode = ueye.IS_CM_SENSOR_RAW12
			self.fileParams = ueye.IMAGE_FILE_PARAMS()

			# Start the driver and establish the connection to the camera
			nRet = ueye.is_InitCamera(self.hCam, None)
			if nRet != ueye.IS_SUCCESS:
				print("is_InitCamera ERROR")

			# Query additional information about the sensor type used in the camera
			ueye.is_GetSensorInfo(self.hCam, self.sInfo)
			self.width = self.sInfo.nMaxWidth
			self.height = self.sInfo.nMaxHeight

			# Set the desired color mode
			ueye.is_SetColorMode(self.hCam, self.colorMode)

			try:
				self.calibration = True
				self.camera_matrix = camera_matrix
				self.dist_coeff = dist_coeff
				self.new_camera_matrix = cv2.getOptimalNewCameraMatrix(camera_matrix, dist_coeff, shape, 0, shape)[0]
			except Exception as e:
				self.calibration = False
				print('Camera calibration not provided')

			self.allocate_memory()

		# TODO: Maybe OpenCV can access the image directly 
		# https://stackoverflow.com/questions/19120198/ueye-camera-and-opencv-memory-access
		# https://docs.opencv.org/2.4.13.2/modules/core/doc/old_basic_structures.html#cv.CreateImageHeader
		def allocate_memory(self):
			# Allocate an image memory for a single image
			nRet = ueye.is_AllocImageMem(self.hCam, self.width, self.height, self.bitsPerPixel, self.pcImageMemory, self.memID)
			if nRet != ueye.IS_SUCCESS:
				print("is_AllocImageMem ERROR")

			# Make the specified image memory the active memory
			nRet = ueye.is_SetImageMem(self.hCam, self.pcImageMemory, self.memID)
			if nRet != ueye.IS_SUCCESS:
				print("is_SetImageMem ERROR")

			# Set up the parameters required for storing images on the PC
			self.fileParams.nFileType = ueye.IS_IMG_PNG
			self.fileParams.ppcImageMem = None
			self.fileParams.pnImageID = None
			self.fileParams.nQuality = 0

			# Set Frame rate
			targetFPS = ueye.double(1) # insert here which FPS you want
			actualFPS = ueye.double(0)
			nret = ueye.is_SetFrameRate(self.hCam,targetFPS,actualFPS)

		def capture_image(self, filename, exposure=10, gain=0):
			nRet = ueye.is_SetAutoParameter(self.hCam, ueye.IS_SET_ENABLE_AUTO_GAIN, ueye.double(0), ueye.double(0))
			nRet += ueye.is_SetAutoParameter(self.hCam, ueye.IS_SET_ENABLE_AUTO_SHUTTER, ueye.double(0), ueye.double(0))
			if nRet != ueye.IS_SUCCESS:
				print("is_SetAutoParameter ERROR")

			# Set exposure time in ms, and gain in %
			targetEXP= ueye.c_double(exposure)
			nRet = ueye.is_Exposure(self.hCam, ueye.IS_EXPOSURE_CMD_SET_EXPOSURE, targetEXP, 8)
			nRet += ueye.is_SetHardwareGain(self.hCam, gain, 0, 0, 0)
			if nRet != ueye.IS_SUCCESS:
				print("is_Exposure or is_SetHardwareGain ERROR")

			# Take a snapshot
			nRet = ueye.is_FreezeVideo(self.hCam, ueye.IS_WAIT)
			nRet = ueye.is_FreezeVideo(self.hCam, ueye.IS_WAIT)
			if nRet != ueye.IS_SUCCESS:
				print("Error capturing image")

			self.fileParams.pwchFileName = filename
			nRet = ueye.is_ImageFile(self.hCam, ueye.IS_IMAGE_FILE_CMD_SAVE, self.fileParams, ueye.sizeof(self.fileParams))
			if nRet != ueye.IS_SUCCESS:
				print('Error saving image', filename)
				exit(1)
			# print('Image', filename, 'captured and saved')
			raw = cv2.imread(filename, -1)
			color = cv2.cvtColor(raw, cv2.COLOR_BayerBG2RGB)
			return color.mean(axis=(0,1))

			if self.calibration:
				img = cv2.imread(filename)
				corrected = cv2.undistort(img, self.camera_matrix, self.dist_coeff, None, self.new_camera_matrix)
				cv2.imwrite(filename, corrected)

		def __del__(self):
			# Release the image allocated image memory
			ueye.is_FreeImageMem(self.hCam, self.pcImageMemory, self.memID)

			# Disable the camera handle and exit
			ueye.is_ExitCamera(self.hCam)
