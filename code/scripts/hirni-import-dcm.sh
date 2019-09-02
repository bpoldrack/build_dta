export DATALAD_LOG_TRACEBACK=collide
for d in ./source_data/* ; do
	for b in $d/* ; do
		echo $b
		datalad hirni-import-dcm $b
	done
done

