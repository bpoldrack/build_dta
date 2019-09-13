#!/usr/bin/env bash
dataset=${1}
subject=${2}

for old_file in sub-DTA*/*/*/*run* ; do

		tmp_file="${old_file/_run-1_/_}"
		new_file="${tmp_file/_run-2_/_}"
		git mv $old_file $new_file

done
