#!/usr/bin/env bash

for old_json in sub-DTA*/*/fmap/*fieldmap*.json ; do
	# looks into the json-files of the fieldmaps-files.

	# this line has to read the ImageType-array from a json-file
	# (example: [ND, ORIGINAL, PRIMARY, P]) and filters it
	# until there is just a "P" or "M" for phase or magnitude.
	if [ ! -z $(cat ${old_json} | jq .ImageType  | grep -v "ND" | grep -v "ORIGINAL"| grep -v "PRIMARY" | grep "P" ) ]; then

		# if it founds a "P" for Phase, it changes the fieldmap-part of the filename
		# to phase, otherwise it checks for "M" for magnitude in the elif-case.
		new_json="${old_json/fieldmap/phase}"
		old_nifti="${old_json/.json/.nii.gz}"
		new_nifti="${old_nifti/fieldmap/phase}"

		# the actual renaming for the json and nifti-file
		mv $old_json $new_json
		mv $old_nifti $new_nifti

	elif [ ! -z $(cat ${old_json} | jq .ImageType  | grep -v "ND" | grep -v "ORIGINAL"| grep -v "PRIMARY" | grep "M" ) ]; then

		new_json="${old_json/fieldmap/magnitude}"
                old_nifti="${old_json/.json/.nii.gz}"
                new_nifti="${old_nifti/fieldmap/magnitude}"

                mv $old_json $new_json
                mv $old_nifti $new_nifti
	fi
done
