#!/usr/bin/env bash
dataset=${1}
subject=${2}

cd /data/BnB_USER/Kadelka/DTA/

for old_json in sub-DTA*/*/fmap/*fieldmap*.json ; do
	if [ ! -z $(cat ${old_json} | jq .ImageType  | grep -v "ND" | grep -v "ORIGINAL"| grep -v "PRIMARY" | grep "P" ) ]; then
		new_json="${old_json/fieldmap/phase}"
		old_nifti="${old_json/.json/.nii.gz}"
		new_nifti="${old_nifti/fieldmap/phase}"

		echo $old_json
		echo $new_json

		mv $old_json $new_json
		mv $old_nifti $new_nifti

	else
		new_json="${old_json/fieldmap/magnitude}"
                old_nifti="${old_json/.json/.nii.gz}"
                new_nifti="${old_nifti/fieldmap/magnitude}"

                echo $old_json
                echo $new_json

                mv $old_json $new_json
                mv $old_nifti $new_nifti
	fi
done
