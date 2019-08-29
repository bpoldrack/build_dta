for d in /data/BnB_USER/Kadelka/BIDS_DATALAD/test_dta/T* ; do
		datalad hirni-spec2bids $d/studyspec.json
	done
done

