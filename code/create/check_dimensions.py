#!/usr/bin/env python
# coding: utf8
import os
import sys
import nibabel

#       Tobias Kadelka
#       Data and Platforms
#       INM-7 - Brain and Behaviour

# iterates over a given path and checks the dimensions of a file.
def main():
	inputPath = sys.argv[1]

	for root, dirs, files in os.walk( inputPath ):
		files[:] = [ os.path.join(root, file) for file in files[:] ]
		files.sort()
		for file in files:
			if (file[-7:] == ".nii.gz" and "task" in file):
				img = nibabel.load( file )
				print( "\n\n" + str(img.shape) )
				if "exp1" in file and img.shape[-1] < 600:
					print( "rm " + file )
					print( "rm " + file.replace(".nii.gz", ".json") )
					print( "rm " + file.replace("_bold.nii.gz", "_events.tsv") )
				elif "rest" in file and img.shape[-1] < 200:
					print( "rm " + file )
					print( "rm " + file.replace(".nii.gz", ".json") )
					print( "rm " + file.replace("_bold.nii.gz", "_events.tsv") )


main()
