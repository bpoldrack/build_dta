# this script imports the tars from a given sourcedata_test-directory.
for d in $1/*/* ; do
		echo $d
                datalad hirni-import-dcm $d
done

