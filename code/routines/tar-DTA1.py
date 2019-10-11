#!/usr/bin/env python
# coding: utf8
import os
import sys

# this function looks into a folder-path and searches for dicoms.
def is_dcm( folderpath ):
	for folder in os.listdir( folderpath ):
		if ".DS_Store" in folder or ".json" in folder or ".nii" in folder:
			continue
		for file in os.listdir( folderpath + folder ):
			if ".dcm" in file:
                        	return True
	return False


# the main function generates mkdir and find commands for creating tars per subjects in the outputPath.
def main():
	inputPath  = "/data/BnB_USER/Plaeschke/DTA_Studie/MRI_Data/MultiState_072015/DATA/DTAGE/"
	outputPath = "/data/BnB_TEMP/Kadelka/sourcedata_DTA/"

	for subject in os.listdir(inputPath):
		# just folders with T-values (is in DTAGE2 T2 as the start-str possible?)
		if not "T1" == subject[:2]:
			continue
		# just folders with dicoms
		elif is_dcm(inputPath + subject + "/scans/2/"):
			# print the command-lines so they can be redirected into a file
			print ("mkdir -p " + outputPath + subject + "/")
			print ("find " + inputPath + subject + "/scans/ -name \"*.dcm\" | tar -cvf " + outputPath + subject + "/" + subject + ".tar -T -")

main()
