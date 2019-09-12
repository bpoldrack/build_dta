#!/usr/bin/env bash
dataset=${1}
subject=${2}

for phase1_json in sub-DTA*/*/fmap/*phase1*.json ; do
	if [ ! -z $(cat ${phase1_json} | jq .AcqisitionTime ) ]; then

		phase1_time = $(cat ${phase1_json} | jq .AcqisitionTime )
		phase2_json = "${phase1_json/phase1/phase2}"
		phase2_time = $(cat ${phase2_json} | jq .AcqisitionTime )
		echo phase1 $phase1_time \t phase2 $phase2_time
	fi
done

