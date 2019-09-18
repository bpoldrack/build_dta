#!/usr/bin/env bash

# looks into the json-files of fieldmaps.
for old_json in sub-DTA*/*/fmap/*fieldmap*.json ; do
	# this line looks complicated, but it just reads the ImageType-array
	# from the json (example: [ND, ORIGINAL, PRIMARY, P]) and filters it
	# til there is just a "P" or "M" for phase or magnitude.
	if [ ! -z $(cat ${old_json} | jq .ImageType  | grep -v "ND" | grep -v "ORIGINAL"| grep -v "PRIMARY" | grep "P" ) ]; then

		# if it founds a "P" for Phase, it changes the fieldmap-part of the
		# filename to phase, otherwise to magnitude in the else-case.
		new_json="${old_json/fieldmap/phase}"
		old_nifti="${old_json/.json/.nii.gz}"
		new_nifti="${old_nifti/fieldmap/phase}"

		# the actual renaming for the json and nifti-file
		mv $old_json $new_json
		mv $old_nifti $new_nifti

	else
		new_json="${old_json/fieldmap/magnitude}"
                old_nifti="${old_json/.json/.nii.gz}"
                new_nifti="${old_nifti/fieldmap/magnitude}"

                mv $old_json $new_json
                mv $old_nifti $new_nifti
	fi
done
