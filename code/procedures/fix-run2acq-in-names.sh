#!/usr/bin/env bash
dataset=${1}
subject=${2}

for old_file in sub-DTA*/*/dwi/*run* ; do

		new_file="${old_file/run/acq}"
		echo $old_file $new_file
		#git mv old_file new_file

done

