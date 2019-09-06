#!/usr/bin/env bash
dataset=${1}
subject=${2}

cd /data/BnB_USER/Kadelka/DTA/

for file in sub-DTA*/*/fmap/*fieldmap*.json ; do
	if [ ! -z $(cat ${file} | jq .ImageType  | grep -v "ND" | grep -v "ORIGINAL"| grep -v "PRIMARY" | grep "P" ) ]; then
		echo $file is Phase
		mv $file "${file/fieldmap/phase}"
	else
		echo $file is Magnitude
                mv $file "${file/fieldmap/magnitude}"
	fi
done
