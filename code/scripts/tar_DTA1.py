#!/usr/bin/env python
# coding: utf8
import os
import sys

def is_dcm( folderpath ):
	for folder in os.listdir( folderpath ):
		if ".DS_Store" in folder or ".json" in folder or ".nii" in folder:
			continue
		for file in os.listdir( folderpath + folder ):
			if ".dcm" in file:
                        	return True
	return False


# the main function generates mkdir and find commands for creating tar balls per subjects in the outputPath.
def main():
	inputPath = "/data/BnB_USER/Plaeschke/DTA_Studie/MRI_Data/MultiState_072015/DATA/DTAGE/"
	outputPath = sys.argv[1] + "/source_data/" #"/home/homeGlobal/tkadelka/test_dta/source_data/"
	for subject in os.listdir(inputPath):
		if not "T1" == subject[:2]:
			continue
		elif is_dcm(inputPath + subject + "/scans/2/"):
			print ("mkdir -p " + outputPath + subject + "/")
			print ("find " + inputPath + subject + "/scans/ -name \"*.dcm\" | tar -cvf " + outputPath + subject + "/" + subject + ".tar -T -")

main()
