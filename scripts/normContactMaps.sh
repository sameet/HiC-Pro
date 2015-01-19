#!/bin/bash
## Nicolas Servant
## normContactMaps.sh
## Launcher for normalization scripts

dir=$(dirname $0)

#. $dir/hic.inc.sh

################### Initialize ###################

while [ $# -gt 0 ]
do
    case "$1" in
	(-c) conf_file=$2; shift;;
	(-h) usage;;
	(--) shift; break;;
	(-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
	(*)  break;;
    esac
    shift
done

################### Read the config file ###################

#read_config $ncrna_conf
CONF=$conf_file . $dir/hic.inc.sh

################### Define Variables ###################

DATA_DIR=${MAPC_OUTPUT}/data/

################### Combine Bowtie mapping ###################

for RES_FILE_NAME in ${DATA_DIR}/*
do
    RES_FILE_NAME=$(basename $RES_FILE_NAME)
    echo $RES_FILE_NAME
    if [ -d ${DATA_DIR}/${RES_FILE_NAME} ]; then
	NORM_DIR=${MAPC_OUTPUT}/matrix/${RES_FILE_NAME}/iced
	for bsize in ${BIN_SIZE}
	do
	    mkdir -p ${NORM_DIR}/${bsize}
	    INPUT_MATRIX=${MAPC_OUTPUT}/matrix/${RES_FILE_NAME}/raw/${bsize}/${RES_FILE_NAME}_${bsize}.matrix
	    ln -s ${MAPC_OUTPUT}/matrix/${RES_FILE_NAME}/raw/${bsize}/${RES_FILE_NAME}_${bsize}_abs.bed ${NORM_DIR}/${bsize}/${RES_FILE_NAME}_${bsize}_abs.bed
	    ln -s ${MAPC_OUTPUT}/matrix/${RES_FILE_NAME}/raw/${bsize}/${RES_FILE_NAME}_${bsize}_ord.bed  ${NORM_DIR}/${bsize}/${RES_FILE_NAME}_${bsize}_ord.bed
	    ${SCRIPTS}/ice --results_filename ${NORM_DIR}/${bsize}/${RES_FILE_NAME}_${bsize}_iced.matrix --filtering_perc ${SPARSE_FILTERING} --max_iter ${MAX_ITER} --eps ${EPS} --verbose 1 ${INPUT_MATRIX} &

	done
    fi
    wait
done