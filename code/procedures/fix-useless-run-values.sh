#!/usr/bin/env bash

# This script has to remove all the run-1 and run-2 parts
# in all the filenames of DTA.
for old_file in sub-DTA*/*/*/*run* ; do

		tmp_file="${old_file/_run-1_/_}"
		tmp2_file="${tmp_file/_run-2_/_}"
		tmp3_file="${tmp2_file/_run-3_/_}"
		tmp4_file="${tmp3_file/_run-4_/_}"
		tmp5_file="${tmp4_file/_run-5_/_}"
		tmp6_file="${tmp5_file/_run-6_/_}"
		new_file="${tmp6_file/_run-7_/_}"

		git mv $old_file $new_file

done
