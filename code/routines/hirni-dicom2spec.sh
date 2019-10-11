 #!/usr/bin/env bash 

# datalad hirni-import-dcm should run the hirni-dicom2spec anyways.
# This script was for testing the steps after importing the dcm manually.
for d in ./T* ; do
	for b in $d/* ; do
		datalad hirni-dicom2spec -s $d/studyspec.json $d/dicoms/data/BnB_USER/Plaeschke/DTA_Studie/MRI_Data/MultiState_072015/DATA/DTAGE/$d/scans/
	done
done
