 #!/usr/bin/env bash

# runs spec2bids manually for all studyspec.json, in case something
# interrupted it or something was changed.
for d in ./T* ; do
	datalad hirni-spec2bids $d/studyspec.json
done
