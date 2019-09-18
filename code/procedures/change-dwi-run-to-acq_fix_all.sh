#!/usr/bin/env bash

# this script changes the dwi-file-names
# for example from run-120dir to acq-120dir.

# Ben: Where does the "DTA" in "sub-DTA*" come from? Is that really how the subjects are named? What about anonymized
#      subject identifiers? Will they also contain "DTA"? And if so - why?
#      This procedure is to be called after initial conversion, so "sub-*" should be sufficient.
for old_file in sub-DTA*/*/dwi/*run* ; do

		new_file="${old_file/run/acq}"
		git mv $old_file $new_file

done

# Ben: TODO: datalad-save missing afterwards.
