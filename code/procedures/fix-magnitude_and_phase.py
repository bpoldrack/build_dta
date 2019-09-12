##!/usr/bin/env python
# coding: utf8
import os
import json


def main():

	# because of the messed up color-highlighting when using an empty string in the editor.
	no_value = ""
	temp = "temp_fileName.json"
	inputPath = os.getcwd()
	inputPath = "/data/BnB1/Datalad/BIDS_DTA/"
	list_of_fmaps = []

	for root, dirs, files in os.walk( inputPath ):
		dirs[:] = [ os.path.join(root, dir)  for dir in dirs[:] ]
		for dir in dirs:
			if not "fmap" in dir or not "sub-" in dir:
				continue
			elif dir not in list_of_fmaps:
				list_of_fmaps.append( dir + "/" )

#	func( list_of_fmaps )

	for dir in sorted( list_of_fmaps ) :
			magnitude1_time = no_value; magnitude2_time = no_value; phase1_time = no_value; phase2_time = no_value ;
			this_phase = True ; this_magnitude = True
			for file in sorted( os.listdir( dir ) ):
				if "magnitude1" in file and ".json" in file:
					magnitude1_time = json.load( open( dir + file ) )["AcquisitionTime"]
					magnitude1_json = dir + file
				if "magnitude2" in file and ".json" in file:
					magnitude2_time = json.load( open( dir + file ) )["AcquisitionTime"]
					magnitude2_json = dir + file
				# or elif
				if "phase1" in file and ".json" in file:
					phase1_time = json.load( open( dir + file ) )["AcquisitionTime"]
					phase1_json = dir + file
				if "phase2" in file and ".json" in file:
					phase2_time = json.load( open( dir + file ) )["AcquisitionTime"]
					phase2_json = dir + file

				if magnitude1_time != no_value and magnitude2_time != no_value and phase1_time != no_value and phase2_time != no_value:
					if ( magnitude1_time > magnitude2_time and this_magnitude):
						print("mv " + magnitude1_json + " " + dir + temp)
						print("mv " + magnitude2_json + " " + magnitude1_json)
						print("mv " + dir + temp + " " + magnitude2_json)

						print("mv " + magnitude1_json.replace(".json", ".nii.gz") + " " + dir + temp.replace(".json", ".nii.gz"))
						print("mv " + magnitude2_json.replace(".json", ".nii.gz") + " " + magnitude1_json.replace(".json", ".nii.gz"))
						print("mv " + dir + temp.replace(".json", ".nii.gz") + " " + magnitude2_json.replace(".json", ".nii.gz"))

						this_magnitude = False

						#os.rename(magnitude1_json, dir + temp)
						#os.rename(magnitude2_json, magnitude1_json)
						#os.rename(dir + temp, magnitude2_json)

						#os.rename(magnitude1_json.replace(".json", ".nii.gz"), dir + temp.replace(".json", ".nii.gz"))
						#os.rename(magnitude2_json.replace(".json", ".nii.gz"), magnitude1_json.replace(".json", ".nii.gz"))
						#os.rename(dir + temp.replace(".json", ".nii.gz"), magnitude2_json.replace(".json", ".nii.gz"))

					if ( phase1_time >     phase2_time and this_phase):
						print("mv " + phase1_json + " " + dir + temp)
						print("mv " + phase2_json + " " + phase1_json)
						print("mv " + dir + temp + " " + phase2_json)

						print("mv " + phase1_json.replace(".json", ".nii.gz") + " " + dir + temp.replace(".json", ".nii.gz"))
						print("mv " + phase2_json.replace(".json", ".nii.gz") + " " + phase1_json.replace(".json", ".nii.gz"))
						print("mv " + dir + temp.replace(".json", ".nii.gz") + " " + phase2_json.replace(".json", ".nii.gz"))

						this_phase = False

						#os.rename(phase1_json, dir + temp)
						#os.rename(phase2_json, phase1_json)
						#os.rename(dir + temp, phase2_json)

						#os.rename(phase1_json.replace(".json", ".nii.gz"), dir + temp.replace(".json", ".nii.gz"))
						#os.rename(phase2_json.replace(".json", ".nii.gz"), phase1_json.replace(".json", ".nii.gz"))
						#os.rename(dir + temp.replace(".json", ".nii.gz"), phase2_json.replace(".json", ".nii.gz"))

main()

