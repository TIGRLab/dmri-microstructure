#!/bin/bash -l

module load FSL/6.0.1

# $1 - Study name ie. TAY
# $2 - path to study subject list ie. /scratch/mjoseph/bids/TAY/code/subject_list.txt
# $3 - User possessing NODDI outputs (from 04-run_NODDI.sh)

STUDY=$1
sublist=`cat $2`
USER1=$3

for subject in $sublist; do

	AMICO_RESAMPLED_DIR="/scratch/${USER1}/dmri-microstructure/amico_resampled_MNI152NLin6/${subject}/ses-01/dwi" #directory created in 05-transform_NODDItoMNI.sh
	FMRIPREP_DIR="/archive/data/${STUDY}/pipelines/in_progress/baseline/fmriprep/${subject}/ses-01/anat" #fmriprep anatomical directory
	OUTPUT_DIR="/scratch/${USER1}/dmri-microstructure/NODDI_volume_space_masked/${subject}/ses-01/dwi"	#new directory to place GM and WM NODDI masks
	
	mkdir -p ${OUTPUT_DIR}

	for i in ICVF ISOVF OD; do
		for mask in GM WM; do

			fslmaths \
			  ${AMICO_RESAMPLED_DIR}/${subject}_ses-01_space-MNI152NLin6Asym_desc-${i}_NODDI.nii.gz \
			  -mul ${FMRIPREP_DIR}/${subject}_ses-01_space-MNI152NLin6Asym_label-${mask}_probseg.nii.gz \
			  ${OUTPUT_DIR}/${subject}_ses-01_space-MNI152NLin6Asym_desc-${i}_NODDI_label-${mask}.nii.gz
	
		done
	done
done