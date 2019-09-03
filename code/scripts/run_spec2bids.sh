for d in ./T* ; do
	datalad hirni-spec2bids $d/studyspec.json
done
