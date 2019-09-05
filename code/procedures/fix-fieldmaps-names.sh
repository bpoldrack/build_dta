#!/usr/bin/env bash
dataset=${1}
subject=${2}

cd ${dataset}

# I know, this code looks shitty and one loop would be enough,
# but robert wants his data and I need to clean this anyways.
for file in sub-${subject}/*/fmap/*magnitude12*.nii.gz; do
	echo $file "${file/magnitude12/magnitude2}"
done

for file in sub-${subject}/*/fmap/*magnitude11*.nii.gz; do
        echo $file "${file/magnitude11/magnitude1}"
done

for file in sub-${subject}/*/fmap/*phase12*.nii.gz; do
        echo $file "${file/phase12/phase2}"
done

for file in sub-${subject}/*/fmap/*phase11*.nii.gz; do
        echo $file "${file/phase11/phase1}"
done




for file in sub-${subject}/*/fmap/*magnitude21*.nii.gz; do
        echo $file "${file/magnitude21/magnitude2}"
done

for file in sub-${subject}/*/fmap/*magnitude11*.nii.gz; do
        echo $file "${file/magnitude11/magnitude1}"
done

for file in sub-${subject}/*/fmap/*phase12*.nii.gz; do
        echo $file "${file/phase12/phase2}"
done

for file in sub-${subject}/*/fmap/*phase11*.nii.gz; do
        echo $file "${file/phase11/phase1}"
done
