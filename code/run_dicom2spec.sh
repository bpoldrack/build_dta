for d in /data/BnB_USER/Kadelka/BIDS_DATALAD/test_dta/T* ; do
	for b in $d/* ; do
		echo $b
		datalad hirni-dicom2spec -s $d/studyspec.json $d/dicoms/data/BnB_USER/Plaeschke/DTA_Studie/MRI_Data/MultiState_072015/DATA/DTAGE/$d/scans/
	done
done



#/data/BnB_USER/Kadelka/test_dta/source_data/dicoms/data/BnB_USER/Plaeschke/DTA_Studie/MRI_Data/MultiState_072015/DATA/DTAGE/data/BnB_USER/Kadelka/test_dta/source_data/scans
