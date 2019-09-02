for d in ./T* ; do
	for b in $d/* ; do
		echo $b
		datalad hirni-dicom2spec -s $d/studyspec.json $d/dicoms/data/BnB_USER/Plaeschke/DTA_Studie/MRI_Data/MultiState_072015/DATA/DTAGE/$d/scans/
	done
done
