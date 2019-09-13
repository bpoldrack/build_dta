# this script imports the tars from a given sourcedata-directory

source_dir=$1
for d in $source_dir/* ; do
                datalad hirni-import-dcm $d
done

