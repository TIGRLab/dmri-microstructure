#!/bin/bash -l
module load ANTS/2.3.3

# $1 - Study name ie. TAY
# $2 - path to study subject list ie. /scratch/mjoseph/bids/TAY/code/subject_list.txt
# $3 - User possessing qsiprep temp working directory (from 02-run_qsiprep.sh)
# $4 - User possessing NODDI outputs (from 04-run_NODDI.sh)
STUDY=$1

sublist=`cat $2`

USER1=$3

USER2=$4

for subject in $sublist; do

	FMRIPREP_DIR="/archive/data/${STUDY}/pipelines/in_progress/baseline/fmriprep/${subject}/ses-01/anat" #FMRIPREP anatomical directory

	T1_ACPC_TRANSFORM="/scratch/${USER1}/tmp/${STUDY}/qsiprep/qsiprep_wf/${subject/sub-/single_subject_}_wf/anat_preproc_wf/skullstrip_wf/rigid_acpc_align/transform0GenericAffine.mat" #qsiprep t1 to acpc transform 

	T1_MNI_TRANSFORM="${FMRIPREP_DIR}/${subject}_ses-01_from-T1w_to-MNI152NLin6Asym_mode-image_xfm.h5" #fmriprep t1 to MNI transform

	AMICO_DIR="/scratch/${USER2}/dmri-microstructure/amico/qsirecon/${subject}/ses-01/dwi" #amico subject directory

	OUTPUT_DIR="/scratch/${USER2}/dmri-microstructure/amico_resampled_MNI152NLin6/${subject}/ses-01/dwi" #new directory name of transformed NODDI outputs

	mkdir -p $OUTPUT_DIR

	for i in ICVF ISOVF OD; do
		
		antsApplyTransforms   -d 3   -r "${FMRIPREP_DIR}/${subject}_ses-01_space-MNI152NLin6Asym_desc-preproc_T1w.nii.gz"   -t ${T1_MNI_TRANSFORM}   -t [ ${T1_ACPC_TRANSFORM}, 1 ]   -n NearestNeighbor   -i "${AMICO_DIR}/${subject}_ses-01_space-T1w_desc-preproc_space-T1w_desc-${i}_NODDI.nii.gz"   -o "${OUTPUT_DIR}/${subject}_ses-01_space-MNI152NLin6Asym_desc-${i}_NODDI.nii.gz"   -v

	done

done