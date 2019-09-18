#!/usr/bin/env bash

# looks into the json-files of fieldmaps.
# Ben: TODO: See change-dwi-run-to-acq_fix.py
for old_json in sub-DTA*/*/fmap/*fieldmap*.json ; do
	# this line looks complicated, but it just reads the ImageType-array
	# from the json (example: [ND, ORIGINAL, PRIMARY, P]) and filters it
	# til there is just a "P" or "M" for phase or magnitude.
	# Ben: TODO: Actually it doesn't. ;-) It just looks for that P and simply assumes M otherwise. Better not go for a
	#      simple "else", but a proper second condition looking for that M. What if something else accidentally ends up
	#      as a file named fieldmap? Better not treat it as if it was a magnitude image, so you can tell afterwards that#
	#      something's wrong.
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

