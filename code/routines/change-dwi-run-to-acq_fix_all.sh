#!/usr/bin/env bash

# this script changes the dwi-file-names
# for example from run-120dir to acq-120dir.
for old_file in sub-DTA*/*/dwi/*run* ; do

		new_file="${old_file/run/acq}"
		git mv $old_file $new_file

done
