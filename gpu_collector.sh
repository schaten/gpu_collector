#!/bin/bash
# Copyright 2026. Philip Schaten
# All rights reserved. Use of this source code is governed by
# a BSD-style license which can be found in the LICENSE file.

set -euo pipefail

outfile=/tmp/text_metrics/test.prom
waiting_period=5

format() {
	echo "$1{pci=\"$gpu\"} $2"
}

describe() {
	echo "# TYPE $1 gauge"
	[ $# -eq 2 ] && echo "# HELP $1 $2" || true
}

write_metrics() {
	describe nvsmi_gpu_index "Index used in CUDA_VISIBLE_DEVICE"
	describe nvsmi_gpu_temp_celsius "GPU Temperature in °C"
	describe nvsmi_gpu_utilization "GPU utilization in %"
	describe nvsmi_gpu_jobs "Active jobs on GPU"

	declare -A gpu_jobs

	while IFS=, read gpu idx util temp; do
		gpu=$(echo $gpu | cut -d: -f2)
		gpu_jobs[$gpu]=""

		format nvsmi_gpu_index $idx
		format nvsmi_gpu_temp_celsius $temp
		format nvsmi_gpu_utilization $util
	done < <(nvidia-smi --format=csv --query-gpu=\
pci.bus_id,index,utilization.gpu,temperature.gpu |\
	tail -n+2)


	while IFS=, read gpu name pid; do
		gpu=$(echo $gpu | cut -d: -f2)
		gpu_jobs[$gpu]+="$name "
	done < <(nvidia-smi --format=csv --query-compute-apps=\
gpu_bus_id,name,pid |\
	tail -n+2)


	for gpu in "${!gpu_jobs[@]}"; do
		jobs0="${gpu_jobs[$gpu]}"
		njobs=$(echo "${jobs0}" | wc -w)
		format nvsmi_gpu_jobs $njobs
	done
}



while true; do

	mkdir -p $(dirname "${outfile}")
	write_metrics > $outfile.TMP
	mv $outfile.TMP $outfile
	sleep $waiting_period;
done
