#!/usr/bin/env python
# coding: utf8

# In this script, I correct the order of phase1/phase2-files (also for magnitude)
# based on the AcquisitionTime from the json-files.

import os
import json
import sys

def main():

	# because of the messed up color-highlighting when using an empty string in the editor, I have this:
	no_value = ""

	# while swapping file names, I need a temp-file-name.
	temp = "temp_fileName.json"
#	inputPath = os.getcwd()
#	inputPath = "/data/BnB1/Datalad/BIDS_DTA/"
	inputPath = sys.argv[1]
	# we collect the fmap-folder in a list. TODO: This is shitty and could be faster.
	list_of_fmaps = []
	for root, dirs, files in os.walk( inputPath ):
		dirs[:] = [ os.path.join(root, dir)  for dir in dirs[:] ]
		for dir in dirs:
			if not "fmap" in dir or not "sub-" in dir:
				continue
			elif dir not in list_of_fmaps:
				list_of_fmaps.append( dir + "/" )

	# check the fmap-folders, read AcquisitionTime from json-files
	# and swap the order of phase1/phase2 + magnitude1/magnitude2
	# if that is necessary
	for dir in sorted( list_of_fmaps ) :
			magnitude1_time = no_value; magnitude2_time = no_value; phase1_time = no_value; phase2_time = no_value ;
			this_phase = True ; this_magnitude = True
			magnitude1_json = ""
			magnitude2_json = ""
			phase1_json     = ""
			phase2_json     = ""
			for file in sorted( os.listdir( dir ) ):
				if "magnitude1" in file and ".json" in file:
					magnitude1_time = json.load( open( dir + file ) )["AcquisitionTime"]
					magnitude1_json = dir + file
				if "magnitude2" in file and ".json" in file:
					magnitude2_time = json.load( open( dir + file ) )["AcquisitionTime"]
					magnitude2_json = dir + file
				if "phase1" in file and ".json" in file:
					phase1_time = json.load( open( dir + file ) )["AcquisitionTime"]
					phase1_json = dir + file
				if "phase2" in file and ".json" in file:
					phase2_time = json.load( open( dir + file ) )["AcquisitionTime"]
					phase2_json = dir + file
				# when we have the AcquisitionTime for all fmap-files in the folder, we can check if they are switched (relative to phase1/phase2)
				if magnitude1_time != no_value and magnitude2_time != no_value and phase1_time != no_value and phase2_time != no_value:
					# if the AcquisitionTime is switched and we didn't changed the filenames:
					if ( magnitude1_time > magnitude2_time and this_magnitude ):

						# for swapping the names of jsons for magnitudes
						print("mv " + magnitude1_json + " " + dir + temp)
						print("mv " + magnitude2_json + " " + magnitude1_json)
						print("mv " + dir + temp + " " + magnitude2_json)

						# for swapping the names of niftis for magnitudes
						print("mv " + magnitude1_json.replace(".json", ".nii.gz") + " " + dir + temp.replace(".json", ".nii.gz"))
						print("mv " + magnitude2_json.replace(".json", ".nii.gz") + " " + magnitude1_json.replace(".json", ".nii.gz"))
						print("mv " + dir + temp.replace(".json", ".nii.gz") + " " + magnitude2_json.replace(".json", ".nii.gz"))

						# otherwise it switches the names an even number of times (...)
						this_magnitude = False

					if ( phase1_time > phase2_time and this_phase ):

						# for swapping the names of jsons for phases
						print("mv " + phase1_json + " " + dir + temp)
						print("mv " + phase2_json + " " + phase1_json)
						print("mv " + dir + temp + " " + phase2_json)

						# for swapping the names of niftis for phases
						print("mv " + phase1_json.replace(".json", ".nii.gz") + " " + dir + temp.replace(".json", ".nii.gz"))
						print("mv " + phase2_json.replace(".json", ".nii.gz") + " " + phase1_json.replace(".json", ".nii.gz"))
						print("mv " + dir + temp.replace(".json", ".nii.gz") + " " + phase2_json.replace(".json", ".nii.gz"))

						# we switch just 1 time per folder.
						this_phase = False

main()
