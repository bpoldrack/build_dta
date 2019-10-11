#!/usr/bin/env bash

# This script has to remove all the run-1 and run-2 parts
# in all the filenames of DTA.
for old_file in sub-DTA*/*/*/*run* ; do

		tmp_file="${old_file/_run-1_/_}"
		new_file="${tmp_file/_run-2_/_}"
		git mv $old_file $new_file

done
